alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PreScraperProcess do
  use GenStage
  alias Krihelinator.GithubRepo

  @moduledoc """
  Filter out forks and create changesets from the received maps.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    changesets =
      repos
      |> Stream.filter(fn repo -> not Map.get(repo, "fork") end)
      |> Stream.map(&rearrange_map/1)
      |> Stream.map(&create_changeset/1)
      |> Enum.to_list
    {:noreply, changesets, state}
  end

  def rearrange_map(repo) do
    %{name: Map.get(repo, "full_name"),
      description: Map.get(repo, "description")}
  end

  def create_changeset(repo) do
    GithubRepo.cast_allowed(%GithubRepo{}, repo)
  end
end
