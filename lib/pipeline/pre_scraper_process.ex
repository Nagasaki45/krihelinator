alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PreScraperProcess do
  use GenStage

  @moduledoc """
  Filter out forks and rearrange the Map for further processing.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    repos =
      repos
      |> Stream.filter(fn repo -> not Map.get(repo, "fork") end)
      |> Enum.map(&rearrange_map/1)
    {:noreply, repos, state}
  end

  def rearrange_map(repo) do
    %{name: Map.get(repo, "full_name"),
      description: Map.get(repo, "description")}
  end
end
