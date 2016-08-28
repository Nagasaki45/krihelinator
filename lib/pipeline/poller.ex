alias Experimental.GenStage

defmodule Krihelinator.Pipeline.Poller do
  use GenStage
  require Logger
  alias Krihelinator.Pipeline.PollerStash

  @moduledoc """
  A GenStage producer that emits github repos as event, using the github API.
  """

  def init([]) do
    {:producer, %{next_path: :nil, buffer: []}}
  end

  def handle_demand(demand, %{next_path: :nil} = state) do
    new_next_path = PollerStash.get()
    Logger.info "Starting to poll from '#{new_next_path}'"
    handle_demand(demand, %{state | next_path: new_next_path})
  end

  def handle_demand(demand, %{buffer: buffer} = state) when demand <= length(buffer) do
    {repos, new_buffer} = Enum.split(buffer, demand)
    {:noreply, repos, %{state | buffer: new_buffer}}
  end

  def handle_demand(demand, %{buffer: buffer, next_path: next_path}) do
    {:ok, %{body: repos, status_code: 200}} = GithubAPI.limited_get(next_path)
    new_next_path = next_path(repos)
    PollerStash.put(new_next_path)
    handle_demand(demand, %{buffer: buffer ++ repos, next_path: new_next_path})
  end

  def next_path([]) do
    Logger.info "End of Github! Leaping back to start a new loop"
    "repositories"
  end

  def next_path(repos) do
    last_id = repos |> List.last |> Map.get("id")
    "repositories?since=#{last_id}"
  end
end
