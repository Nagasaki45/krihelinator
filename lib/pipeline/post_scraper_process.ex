alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PostScraperProcess do
  use GenStage
  alias Krihelinator.Krihelimeter

  @moduledoc """
  Filter out projects below statistics thresholds.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    repos =
      repos
      |> Stream.filter(fn r -> r.authors > 1 end)
      |> Stream.filter(fn r -> Krihelimeter.calculate(r) > 30 end)
      |> Enum.to_list
    {:noreply, repos, state}
  end
end
