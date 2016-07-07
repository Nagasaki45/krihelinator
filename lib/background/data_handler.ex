defmodule Krihelinator.Background.DataHandler do
  use GenServer
  require Logger

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
    GenServer.cast(__MODULE__, {:set_threshold, new_threshold})
  end

  # GenServer internals

  @initial_threshold Application.fetch_env!(:krihelinator, :initial_threshold)

  def start_link do
    GenServer.start_link(__MODULE__, [@initial_threshold], name: __MODULE__)
  end

  def init([initial_threshold]) do
    {:ok, %{threshold: initial_threshold}}
  end

  def handle_cast({:process, repo_map}, %{threshold: threshold}=state) do
    if Krihelinator.Krihelimeter.calculate(repo_map) >= threshold do
      repo_map
      |> inspect |> Logger.debug  # TODO Remove
      # |> save_to_db
    end
    {:noreply, state}
  end

  def handle_cast({:set_threshold, new_threshold}, state) do
    {:noreply, %{state | threshold: new_threshold}}
  end

  def save_to_db(repo_map) do
    
  end

end
