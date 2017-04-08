defmodule Krihelinator.Scraper do

  @moduledoc """
  General github scraping logic. Usefull for repo page scraping and pulse page
  scraping.
  """

  @doc """
  Scrape repo home and pulse pages.
  """
  def scrape_repo(changeset) do
    changeset
    |> scrape_repo_page()
    |> scrape_pulse_page()
    |> add_error_if_fork()
    |> combine_full_name()
  end

  @doc """
  If a repo is a fork (indicated near the repo name on github) add an error.
  """
  def add_error_if_fork(%{valid?: false} = changeset), do: changeset
  def add_error_if_fork(changeset) do
    case Ecto.Changeset.get_change(changeset, :fork_of) do
      :nil -> changeset
      fork_text -> Ecto.Changeset.add_error(changeset, :is_fork, fork_text)
    end
  end

  @doc """
  Scraping the repo page will return the user name and the repo name.
  Combine them together to get the full name.
  """
  def combine_full_name(%{valid?: false} = changeset), do: changeset
  def combine_full_name(changeset) do
    {:changes, user_name} = Ecto.Changeset.fetch_field(changeset, :user_name)
    {:changes, repo_name} = Ecto.Changeset.fetch_field(changeset, :repo_name)
    Ecto.Changeset.put_change(changeset, :name, "#{user_name}/#{repo_name}")
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
    {_data_or_changes, repo_name} = Ecto.Changeset.fetch_field(changeset, :name)

    "https://github.com/#{repo_name}#{suffix}"
    |> http_get
    |> handle_response(elements)
    |> case do
         %{error: error} ->
           Ecto.Changeset.add_error(changeset, :scraping_error, error)
         new_data ->
           Ecto.Changeset.change(changeset, new_data)
       end
  end

  @doc """
  A wrapper around `HTTPoison.get` with extra timeout.
  """
  def http_get(url) do
    headers = []
    HTTPoison.get(url, headers, recv_timeout: 10_000)
  end

  @doc """
  Analyze the HTTPoison response, returns a map to update the repo with.
  Several errors are ignorable, collect them, the callers will have to decide
  what to do with them.
  """
  def handle_response({:ok, %{status_code: 200, body: body}}, elements) do
    parse(body, elements)
  end
  def handle_response({:ok, %{status_code: 301, headers: headers}}, elements) do
    headers
    |> Enum.into(%{})
    |> Map.fetch!("Location")
    |> http_get
    |> handle_response(elements)
  end
  def handle_response({:ok, %{status_code: 404}}, _elements), do: %{error: "page_not_found"}
  def handle_response({:ok, %{status_code: 451}}, _elements), do: %{error: "dmca_takedown"}
  def handle_response({:ok, %{status_code: 500}}, _elements), do: %{error: "github_server_error"}
  def handle_response({:ok, %{status_code: code, body: body}}, _elements) do
    # Some unknown failure: elaborate!
    %{error: "Request failed with status_code #{code}:\n#{Floki.text(body)}"}
  end
  def handle_response({:error, %{reason: reason}}, _elements) do
    %{error: Atom.to_string(reason)}
  end

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
