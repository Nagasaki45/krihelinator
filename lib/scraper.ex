defmodule Krihelinator.Scraper do

  @moduledoc """
  General github scraping logic. Usefull for repo page scraping and pulse page
  scraping.
  """

  @basic_elements [
    {:name, ~s{h1[class="public "]}, :string},
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
  def scrape_repo_page(changeset) do
    scrape(changeset, "", @basic_elements)
  end

  @doc """
  Scrape statistics about a repository from github's pulse page.
  """
  def scrape_pulse_page(changeset) do
    scrape(changeset, "/pulse", @pulse_elements)
  end

  @doc """
  Common scraping function.
  """
  def scrape(%Ecto.Changeset{valid?: false} = changeset, _suffix, _elements) do
    changeset
  end
  def scrape(changeset, suffix, elements) do
    repo_name = Krihelinator.GithubRepo.fetch_name(changeset)
    new_data =
      "https://github.com/#{repo_name}#{suffix}"
      |> HTTPoison.get
      |> handle_response(elements)
    case new_data do
      %{error: error} ->
        Ecto.Changeset.add_error(changeset, :scraping_error, inspect(error))
      _otherwise ->
        Ecto.Changeset.change(changeset, new_data)
    end
  end

  @doc """
  Analyze the HTTPoison response, returns a map to update the repo with.
  Several errors are ignorable, collect them, the callers will have to decide
  what to do with them.
  """
  def handle_response({:ok, %{status_code: 200, body: body}}, elements) do
    body
    |> parse(elements)
  end
  def handle_response({:ok, %{status_code: 301, headers: headers}}, elements) do
    headers
    |> Enum.into(%{})
    |> Map.fetch!("Location")
    |> HTTPoison.get
    |> handle_response(elements)
  end
  def handle_response({:ok, %{status_code: 404}}, _elements), do: %{error: :page_not_found}
  def handle_response({:ok, %{status_code: 451}}, _elements), do: %{error: :dmca_takedown}
  def handle_response({:ok, %{status_code: code, body: body}}, _elements) do
    # Some unknown failure: elaborate!
    body_text = Floki.text(body)
    %{error: "GET request failed with status_code #{code}:\n#{body_text}"}
  end
  def handle_response({:error, %{reason: reason}}, _elements), do: %{error: reason}

  @doc """
  Use [floki](https://github.com/philss/floki) to parse the page and return
  a map for that repo.
  """
  def parse(body, elements) do
    floki = Floki.parse(body)
    for {key, css_selector, regex_pattern} <- elements, into: %{} do
      {key, general_extractor(floki, css_selector, regex_pattern)}
    end
  end

  @doc """
  Extracts information from the "floki-parsed" html using css selectors and
  regex matching on the resulting text.
  """
  def general_extractor(floki, css_selector, :string) do
    case basic_text_extraction(floki, css_selector) do
      "" -> :nil
      string -> string
    end
  end
  def general_extractor(floki, css_selector, regex_pattern) do
    text =
      floki
      |> basic_text_extraction(css_selector)
      |> String.replace(",", "")  # Numbers are comma separated
    case Regex.named_captures(regex_pattern, text) do
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
  Remove new lines and extra spaces from strings.

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
