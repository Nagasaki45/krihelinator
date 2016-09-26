alias Experimental.GenStage

defmodule Krihelinator.Pipeline.PostScraperProcess do
  use GenStage
  import Ecto.Changeset, only: [validate_number: 3]

  @moduledoc """
  Extra validations on statistics.
  """

  def init([]) do
    {:producer_consumer, :nil}
  end

  def handle_events(changesets, _from, state) do
    changesets = Enum.map(changesets, &post_process_validations/1)
    {:noreply, changesets, state}
  end

  def post_process_validations(changeset) do
    changeset
    |> Krihelinator.GithubRepo.finalize_changeset
    |> validate_number(:authors, greater_than: 1)
    |> validate_number(:commits, greater_than: 0)
    |> validate_number(:forks, greater_than: 10)
    |> validate_number(:krihelimeter, greater_than: 30)
  end
end
