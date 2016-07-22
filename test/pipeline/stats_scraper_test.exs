defmodule Krihelinator.Pipeline.StatsScraperTest do
  use ExUnit.Case
  alias Krihelinator.Pipeline.StatsScraper
  doctest StatsScraper

  test "parsing numbers with comma, larger than 999" do
    html = """
      <h1>Some title</h1>
      <div class="commits">1,234 commits to all branches</div>
      """
    css_selector = "div.commits"
    pattern = ~r/(?<value>\d+) commits to all branches/

    parsed = StatsScraper.general_extractor(html, css_selector, pattern)
    assert parsed == 1234
  end
end
