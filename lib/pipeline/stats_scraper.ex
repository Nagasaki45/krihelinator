alias Experimental.GenStage

defmodule Krihelinator.Pipeline.StatsScraper do
  use GenStage

  @moduledoc """
  GenStage that scrape statistics for each new repo pulse page.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(changesets, _from, state) do
    changesets = Enum.map(changesets, &Krihelinator.Scraper.scrape_pulse_page/1)
    {:noreply, changesets, state}
  end
end
