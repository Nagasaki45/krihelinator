alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PostScraperProcess do
  use GenStage
  alias Krihelinator.Krihelimeter

  @moduledoc """
  Filter out projects below statistics thresholds.
  """

  def init([]) do
    {:producer_consumer, Application.fetch_env!(:krihelinator, :initial_threshold)}
  end

  def handle_events(repos, _from, threshold) do
    repos =
      repos
      |> Enum.filter(fn r -> Krihelimeter.calculate(r) > threshold end)
    {:noreply, repos, threshold}
  end
end
