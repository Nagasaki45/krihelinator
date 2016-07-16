defmodule Krihelinator.Background.DataHandler do
  use GenServer
  require Logger
  alias Krihelinator.Repo
  alias Krihelinator.GithubRepo

  @moduledoc """
  The sink of the pipeline. Handles new maps, filter them, and persist.
  """

  # External API

  @doc """
  Send new repo map for processing by casting it to the process.
  """
  def process(repo_map) do
    GenServer.cast(__MODULE__, {:process, repo_map})
  end

  @doc """
  Set new Krihelimeter threshold for things that go into the DB.
  """
  def set_threshold(new_threshold) do
    Logger.info("New threshold set to #{new_threshold}")
    GenServer.cast(__MODULE__, {:set_threshold, new_threshold})
  end

  # GenServer internals

  def start_link do
    initial_threshold = Application.fetch_env!(:krihelinator, :initial_threshold)
    GenServer.start_link(__MODULE__, [initial_threshold], name: __MODULE__)
  end

  def init([initial_threshold]) do
    {:ok, %{threshold: initial_threshold}}
  end

  def handle_cast({:process, repo_map}, %{threshold: threshold}=state) do
    if Krihelinator.Krihelimeter.calculate(repo_map) >= threshold do
      save_to_db(repo_map)
    end
    {:noreply, state}
  end

  def handle_cast({:set_threshold, new_threshold}, state) do
    {:noreply, %{state | threshold: new_threshold}}
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
        Repo.get_by(GithubRepo, name: params.name)
        |> GithubRepo.changeset(params)
        |> Repo.update!
    end
  end

end
