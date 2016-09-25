alias Experimental.GenStage

defmodule Krihelinator.Pipeline.StatsScraper do
  use GenStage

  @moduledoc """
  GenStage that scrape statistics for each new repo pulse page.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    repos =
      repos
      |> Stream.map(
        fn r ->
          new_data = Krihelinator.Scraper.scrape_pulse_page(r.name)
          Map.merge(r, new_data)
        end
      )
      |> Enum.filter(fn repo -> is_nil(repo.error) end)
    {:noreply, repos, state}
  end
end
