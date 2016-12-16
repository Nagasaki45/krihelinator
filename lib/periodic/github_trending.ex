defmodule Krihelinator.Periodic.GithubTrending do

  @moduledoc """
  Helper module for scrape and parsing the github trending page.
  """

  @doc """
  Scrape the github trending page and return stream of repos to scrape.
  """
  def scrape do
    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    body
    |> parse
    |> Stream.map(fn repo -> Map.put(repo, :trending, true) end)
  end

  @doc """
  Parse the github trending page. Returns a list of maps with name and
  description.
  """
  def parse(html) do
    html
    |> Floki.find(".repo-list li")
    |> Enum.map(&parse_item/1)
  end

  @doc """
  Parse single floki item repo to "name" and "description".
  """
  def parse_item(floki_item) do
    %{name: parse_name(floki_item),
      description: parse_description(floki_item)
    }
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

  @doc """
  Parse the repo description from the floki item, or `:nil` if doesn't exist.
  """
  def parse_description(floki_item) do
    floki_item
    |> Floki.find("div")
    |> Enum.at(2)  # The 3rd div contains the description
    |> Floki.text
    |> String.trim()
    |> (fn text -> if text == "", do: :nil, else: text end).()
  end
end
