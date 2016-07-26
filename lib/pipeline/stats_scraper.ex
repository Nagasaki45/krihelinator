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
      |> Enum.filter(fn repo -> is_nil(repo.error) end)
    {:noreply, repos, state}
  end

  @doc """
  Scrape statistics about a repository from github's pulse page.
  """
  def scrape(repo) do
    result =
      HTTPoison.get("https://github.com/#{repo.name}/pulse")
      |> handle_response

    Map.merge(repo, result)
  end

  @doc """
  Analyze the HTTPoison response, returns a map to update the repo with.
  Several errors are ignorable, collect them, the callers will have to decide
  what to do with them.
  """
  def handle_response({:ok, %{body: body, status_code: 200}}) do
    body
    |> parse
    |> Map.put(:error, :nil)
  end
  def handle_response({:ok, %{status_code: 404}}), do: %{error: :page_not_found}
  def handle_response({:ok, %{status_code: 451}}), do: %{error: :dmca_takedown}

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
end
