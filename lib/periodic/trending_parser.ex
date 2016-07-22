defmodule Krihelinator.Periodic.TrendingParser do

  @moduledoc """
  Helper module for parsing the github trending page.
  """

  @doc """
  Parse the github trending page. Returns a list of maps with name and
  description.
  """
  def parse(html) do
    html
    |> Floki.find(".repo-list-item")
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
    |> Floki.find(".repo-list-name a")
    |> Floki.attribute("href")
    |> hd
    |> String.trim_leading("/")
  end

  @doc """
  Parse the repo description from the floki item, or `:nil` if doesn't exist.
  """
  def parse_description(floki_item) do
    case Floki.find(floki_item, ".repo-list-description") do
      [] -> :nil
      [floki] -> floki |> Floki.text |> String.strip
    end
  end
end
