defmodule Krihelinator.Scraper do

  @moduledoc """
  General github scraping logic. Usefull for repo page scraping and pulse page
  scraping.
  """

  require Logger

  @doc """
  Scrape repo home and pulse pages.
  """
  def scrape(name) do
    with {:ok, map} <- scrape_repo_page(%{name: name}),
         {:ok, map} <- scrape_pulse_page(map)
    do
      {:ok, %{map | name: "#{map.user_name}/#{map.repo_name}"}}
    end
  end

  @basic_elements [
    {:user_name, ~s{span[itemprop="author"]}, :string},
    {:repo_name, ~s{strong[itemprop="name"]}, :string},
    {:fork_of, ~s{span[class="fork-flag"]}, :string},
    {:description, ~s{span[itemprop="about"]}, :string},
    {:language_name, ~s{span[class="lang"]}, :string},
  ]

  @pulse_elements [
    {:merged_pull_requests, ~s{a[href="#merged-pull-requests"]}, ~r/(?<value>\d+) Merged Pull Requests/},
    {:proposed_pull_requests, ~s{a[href="#proposed-pull-requests"]}, ~r/(?<value>\d+) Proposed Pull Requests/},
    {:closed_issues, ~s{a[href="#closed-issues"]}, ~r/(?<value>\d+) Closed Issues/},
    {:new_issues, ~s{a[href="#new-issues"]}, ~r/(?<value>\d+) New Issues/},
    {:commits, "div.section.diffstat-summary", ~r/pushed (?<value>\d+) commits to/},
    {:authors, "div.section.diffstat-summary", ~r/(?<value>\d+) author/},
    {:forks, "ul.pagehead-actions", ~r/Fork (?<value>\d+)/},
  ]

  @doc """
  Scrape statistics about a repository from it's homepage.
  """
  def scrape_repo_page(map) do
    scrape(map, "", @basic_elements)
  end

  @doc """
  Scrape statistics about a repository from github's pulse page.
  """
  def scrape_pulse_page(map) do
    scrape(map, "/pulse", @pulse_elements)
  end

  @doc """
  Common scraping function.
  """
  def scrape(map, suffix, elements) do
    with {:ok, resp} <- http_get("https://github.com/#{map.name}#{suffix}"),
         {:ok, new_data} <- handle_response(resp, elements)
    do
      {:ok, Map.merge(map, new_data)}
    end
  end

  @doc """
  A wrapper around `HTTPoison.get` with extra options.
  """
  def http_get(url) do
    headers = []
    options = [recv_timeout: 10_000, follow_redirect: true]
    case HTTPoison.get(url, headers, options) do
      {:ok, resp} -> {:ok, resp}
      {:error, error} -> {:error, error.reason}
    end
  end

  @doc """
  Analyze the HTTPoison response, returns a map to update the repo with.
  Several errors are ignorable, collect them, the callers will have to decide
  what to do with them.
  """
  def handle_response(%{status_code: 200, body: body}, elements) do
    {:ok, parse(body, elements)}
  end
  def handle_response(%{status_code: 404}, _elements), do: {:error, :page_not_found}
  def handle_response(%{status_code: 451}, _elements), do: {:error, :dmca_takedown}
  def handle_response(%{status_code: 500}, _elements), do: {:error, :github_server_error}
  def handle_response(%{status_code: code}, _elements) do
    Logger.error "Unknown scraping error occurred (#{code})."
    {:error, :unknown_scraping_error}
  end

  @doc """
  Use [floki](https://github.com/philss/floki) to parse the page and return
  a map for that repo.
  """
  def parse(body, elements) do
    floki = Floki.parse(body)
    for {key, css_selector, regex_pattern} <- elements, into: %{} do
      {key, general_extractor(floki, css_selector, regex_pattern)}
    end
  end

  @doc """
  Extracts information from the "floki-parsed" html using css selectors and
  regex matching on the resulting text.
  """
  def general_extractor(floki, css_selector, :string) do
    case basic_text_extraction(floki, css_selector) do
      "" -> :nil
      string -> string
    end
  end
  def general_extractor(floki, css_selector, regex_pattern) do
    floki
    |> basic_text_extraction(css_selector)
    |> String.replace(",", "")  # Numbers are comma separated
    |> (&Regex.named_captures(regex_pattern, &1)).()
    |> case do
         %{"value" => value} -> String.to_integer(value)
         _ -> 0
       end
  end

  def basic_text_extraction(floki, css_selector) do
    case Floki.find(floki, css_selector) do
      [] -> ""
      otherwise ->
        otherwise
        |> hd
        |> Floki.text
        |> to_one_line
    end
  end

  @doc """
  Remove new lines and extra spaces from strings.

  Example:

    iex> import Krihelinator.Scraper, only: [to_one_line: 1]
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
