defmodule Krihelinator.HistoryKeeper do
  use GenServer
  require Logger
  alias Krihelinator.{Repo, GithubRepo, LanguageHistory}

  @moduledoc """
  Every `:history_keeping_schedule` keep, for each language, the total
  krihelimeter and the number of repos.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    # Run it when restart
    reschedule_work(0)
    {:ok, :nil}
  end

  def handle_info(:run, state) do
    Logger.info "HistoryKeeper process kicked in!"
    keep_history()
    Logger.info "HistoryKeeper process finished successfully!"
    next_run = Application.fetch_env!(:krihelinator, :history_keeper_schedule)
    reschedule_work(next_run)
    {:noreply, state}
  end

  @doc """
  Schedule the next run in.
  """
  def reschedule_work(next_run) do
    Process.send_after(self(), :run, next_run)
  end

  @doc """
  Iterate over all languages and push info to DB.
  """
  def keep_history() do
    GithubRepo.languages_query()
    |> Repo.all
    |> Enum.each(&keep_language_history/1)
  end

  @doc """
  Push the info to the DB.
  """
  def keep_language_history(language_map) do
    %LanguageHistory{}
    |> LanguageHistory.changeset(language_map)
    |> Repo.insert!()
  end
end
