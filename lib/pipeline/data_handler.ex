alias Experimental.GenStage

defmodule Krihelinator.Pipeline.DataHandler do
  use GenStage
  require Logger
  alias Krihelinator.{Repo, GithubRepo}

  @moduledoc """
  The sink of the pipeline. Persist new maps.
  """

  def init([]) do
    {:consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    repos
    |> Enum.each(&save_to_db/1)
    {:noreply, [], state}
  end

  @doc """
  Persist the repo params to the DB. If the repo is already there, update it!
  """
  def save_to_db(params) do
    changeset = GithubRepo.changeset(%GithubRepo{}, params)
    case Repo.insert(changeset) do
      {:ok, _model} -> :ok
      {:error, _changeset} ->
        Logger.debug "#{params.name} already exists. Updating"
        GithubRepo
        |> Repo.get_by(name: params.name)
        |> GithubRepo.changeset(params)
        |> Repo.update!
    end
  end

end
