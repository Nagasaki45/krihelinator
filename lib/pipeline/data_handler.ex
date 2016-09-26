alias Experimental.GenStage

defmodule Krihelinator.Pipeline.DataHandler do
  use GenStage
  require Logger

  @moduledoc """
  The sink of the pipeline. Persist new maps.
  """

  def init([]) do
    {:consumer, :nil}
  end

  def handle_events(changesets, _from, state) do
    changesets
    |> Enum.each(&Krihelinator.Repo.insert/1)
    {:noreply, [], state}
  end
end
