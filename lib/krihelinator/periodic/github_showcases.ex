defmodule Krihelinator.Periodic.GithubShowcases do
  require Logger

  @moduledoc """
  Scrape github's showcases pages.
  """

  @doc """
  Scrape github's showcases. Returns a map when keys are names of showcases
  and values are lists of repo names.
  """
  def scrape() do
    showcases = scrape_showcases()
    showcases
    |> Stream.map(&Map.put(&1, :repos, scrape_showcase(&1)))
  end

  @doc """
  Go through the showcases pages and get all of the categories.
  """
  def scrape_showcases() do
    0  # First page
    |> Stream.unfold(&get_showcases/1)
    |> Stream.concat
  end

  @doc """
  Scrape the showcase page and return the list of repos.
  """
  def scrape_showcase(%{href: href}) do
    url = "https://github.com/showcases/#{href}"
    Logger.debug "Getting #{url}"
    %{body: body, status_code: 200} = HTTPoison.get!(url)
    parse_showcase_page(body)
  end

  @doc """
  Scrapes a single showcases page. Return a tuple of {showcases, next_page} or
  :nil if a page without showcases reached.
  """
  def get_showcases(page) do
    url = "https://github.com/showcases?page=#{page}"
    %{body: body, status_code: 200} = HTTPoison.get!(url)
    results = parse_showcases_page(body)
    case results do
      [] -> :nil
      otherwise -> {otherwise, page + 1}
    end
  end

  @doc """
  Parse a showcases page.
  """
  def parse_showcases_page(html) do
    html
    |> Floki.find("a.exploregrid-item")
    |> Enum.map(&parse_showcase_tile/1)
  end

  @doc """
  Parse a showcase tile for it's name and href (from the showcases page).
  """
  def parse_showcase_tile(html_tile) do
    %{
      href: parse_showcase_href(html_tile),
      name: parse_showcase_name(html_tile),
      description: parse_showcase_description(html_tile)
    }
  end

  def parse_showcase_href(html_tile) do
    html_tile
    |> Floki.attribute("href")
    |> hd
    |> String.replace_prefix("/showcases/", "")
  end

  def parse_showcase_name(html_tile) do
    html_tile
    |> Floki.find("h3")
    |> Floki.text()
    |> String.trim()
  end

  def parse_showcase_description(html_tile) do
    html_tile
    |> Floki.find("p")
    |> Floki.text()
    |> String.trim()
  end

  @doc """
  Parse a showcase page for it's repositories.
  """
  def parse_showcase_page(html) do
    html
    |> Floki.find(".repo-list-item")
    |> Enum.map(&parse_repo_name/1)
  end

  @doc """
  Parse a single repo name.
  """
  def parse_repo_name(repo_html_item) do
    repo_html_item
    |> Floki.find("h3 a")
    |> Floki.attribute("href")
    |> hd
    |> String.replace_prefix("/", "")
  end
end
