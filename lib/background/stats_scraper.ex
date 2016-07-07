defmodule Krihelinator.Background.StatsScraper do
  alias Krihelinator.Background
  require Logger

  @moduledoc """
  Fire up a new task to process statistics for each new repo. Than, push
  the info down to the `DataHandler` sink GenServer.
  """

  @doc """
  Starts a new task to fetch statistics about a repository and send it
  down to the persistance layer.
  """
  def process({user, repo}) do
    Task.start(fn ->
      path = build_path(user, repo)
      case HTTPoison.get(path) do
        {:ok, %{body: body, status_code: 200}} ->
          body
          |> parse
          |> Map.merge(%{user: user, repo: repo})
          |> Background.DataHandler.process
        otherwise ->
          handle_failure(otherwise, user, repo)
      end
    end)
  end

  @host "https://github.com"

  @doc """
  The path to the github pulse page.
  """
  def build_path(user, repo) do
    @host <> "/#{user}/#{repo}/pulse"
  end

  @to_parse [
    {:merged_pull_requests, ~s{a[href="#merged-pull-requests"]}, ~r/(?<value>\d+) Merged Pull Requests/},
    {:proposed_pull_requests, ~s{a[href="#proposed-pull-requests"]}, ~r/(?<value>\d+) Proposed Pull Requests/},
    {:closed_issues, ~s{a[href="#closed-issues"]}, ~r/(?<value>\d+) Closed Issues/},
    {:new_issues, ~s{a[href="#new-issues"]}, ~r/(?<value>\d+) New Issues/},
    {:commits, "div.section.diffstat-summary", ~r/(?<value>\d+) commits to all branches/},
  ]

  @doc """
  Use [floki](https://github.com/philss/floki) to parse the page and return
  a map for that repo.
  """
  def parse(body) do
    floki = Floki.parse(body)
    for {key, css_selector, regex_pattern} <- @to_parse do
      {key, general_extractor(floki, css_selector, regex_pattern)}
    end
    |> Enum.into(%{})
  end

  @doc """
  Extracts information from the "floki-parsed" html using css selectors and
  regex matching on the resulting text.
  """
  def general_extractor(floki, css_selector, regex_pattern) do
    text = floki
           |> Floki.find(css_selector)
           |> Floki.text
           |> to_one_line
    case Regex.named_captures(regex_pattern, text) do
      %{"value" => value} -> String.to_integer(value)
      _ -> 0
    end
  end

  @doc """
  Remove new lines and extra spaces from strings.

  Example:

    iex> import Krihelinator.Background.StatsScraper, only: [to_one_line: 1]
    iex> to_one_line("hello\\nworld")
    "hello world"
    iex> to_one_line("   too\\n many    spaces ")
    "too many spaces"
  """
  def to_one_line(text) do
    text
    |> String.split
    |> Enum.join(" ")
  end

  @doc """
  When HTTPoison fails, log the failure in the most indicative way.
  """
  def handle_failure(httpoison_response, user, repo) do
    msg = case httpoison_response do
      {:ok, %{status_code: 404}} ->
        "Page not found (404)"
      {:ok, %{body: body, status_code: status_code}} ->
        "Status code: #{status_code}\n#{Floki.text(body)}"
      {:error, httpoison_error} ->
        inspect(httpoison_error)
    end
    Logger.warn "Failed to scrape #{user}/#{repo}: #{msg}"
  end

end
