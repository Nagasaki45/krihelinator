alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PostScraperProcess do
  use GenStage

  @moduledoc """
  Set the krihelimeter, filter projects below statistics thresholds.
  """

  def init([]) do
    {:producer_consumer, Application.fetch_env!(:krihelinator, :initial_threshold)}
  end

  def handle_events(repos, _from, threshold) do
    repos = repos
      |> Stream.map(&set_krihelimeter/1)
      |> Enum.filter(fn repo -> repo.krihelimeter > threshold end)
    {:noreply, repos, threshold}
  end

  def set_krihelimeter(repo) do
    Map.put(repo, :krihelimeter, Krihelinator.Krihelimeter.calculate(repo))
  end
end
