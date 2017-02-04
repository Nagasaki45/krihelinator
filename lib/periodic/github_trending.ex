defmodule Krihelinator.Periodic.GithubTrending do

  @moduledoc """
  Helper module for scrape and parsing the github trending page.
  """

  @doc """
  Scrape the github trending page and return stream of repos to scrape.
  """
  def scrape do
    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    parse(body)
  end

  @doc """
  Parse the github trending page. Returns a list of maps with name and
  description.
  """
  def parse(html) do
    html
    |> Floki.find(".repo-list li")
    |> Enum.map(&parse_name/1)
  end

  @doc """
  Parse the repo name (user/repo) from the repo floki item.
  """
  def parse_name(floki_item) do
    floki_item
    |> Floki.find("h3 a")
    |> Floki.attribute("href")
    |> hd
    |> String.trim_leading("/")
  end
end
