defmodule Krihelinator.Periodic.GithubTrendingTest do
  use ExUnit.Case
  alias Krihelinator.Periodic.GithubTrending

  test "scraping the trending page return 25 items" do
    num_of_trending =
      GithubTrending.scrape()
      |> Enum.to_list()
      |> length
    assert num_of_trending == 25
  end
end
