alias Experimental.GenStage

defmodule Krihelinator.Pipeline.StatsScraper do
  use GenStage
  require Logger

  @moduledoc """
  GenStage that scrape statistics for each new repo.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    repos =
      repos
      |> Stream.map(&scrape/1)
      |> Enum.filter(fn repo -> repo != :error end)
    {:noreply, repos, state}
  end

  @doc """
  Scrape statistics about a repository from github's pulse page.
  """
  def scrape(repo) do
    case HTTPoison.get("https://github.com/#{repo.name}/pulse") do
      {:ok, %{body: body, status_code: 200}} ->
        repo
        |> Map.merge(parse(body))
      otherwise ->
        handle_failure(otherwise, repo.name)
        :error  # Filter them later
    end
  end

  @to_parse [
    {:merged_pull_requests, ~s{a[href="#merged-pull-requests"]}, ~r/(?<value>\d+) Merged Pull Requests/},
    {:proposed_pull_requests, ~s{a[href="#proposed-pull-requests"]}, ~r/(?<value>\d+) Proposed Pull Requests/},
    {:closed_issues, ~s{a[href="#closed-issues"]}, ~r/(?<value>\d+) Closed Issues/},
    {:new_issues, ~s{a[href="#new-issues"]}, ~r/(?<value>\d+) New Issues/},
    {:commits, "div.section.diffstat-summary", ~r/(?<value>\d+) commits to all branches/},
    {:authors, "div.section.diffstat-summary", ~r/(?<value>\d+) author/},
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
           |> String.replace(",", "")  # Numbers are comma separated
    case Regex.named_captures(regex_pattern, text) do
      %{"value" => value} -> String.to_integer(value)
      _ -> 0
    end
  end

  @doc """
  Remove new lines and extra spaces from strings.

  Example:

    iex> import Krihelinator.Pipeline.StatsScraper, only: [to_one_line: 1]
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
  Several failures are ignorable. Log them for debugging and let the process
  crash otherwise.
  """
  def handle_failure(httpoison_response, repo_name) do
    msg = case httpoison_response do
      {:ok, %{status_code: 404}} ->
        "Page not found (404)"
      {:ok, %{status_code: 451}} ->
        "Repository unavailable due to DMCA takedown"
    end
    Logger.debug "Failed to scrape #{repo_name}: #{msg}"
  end

end
