defmodule Krihelinator.HistoryKeeper do
  use GenServer
  require Logger
  alias Krihelinator.{Repo, Language, LanguageHistory}

  @moduledoc """
  Every `:history_keeping_schedule` keep, for each language, the total
  krihelimeter and the number of repos.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    reschedule_work()
    {:ok, :nil}
  end

  def handle_info(:run, state) do
    Logger.info "HistoryKeeper process kicked in!"
    keep_history()
    Logger.info "HistoryKeeper process finished successfully!"
    reschedule_work()
    {:noreply, state}
  end

  @doc """
  Schedule the next run in.
  """
  def reschedule_work() do
    next_run = Application.fetch_env!(:krihelinator, :history_keeper_schedule)
    Process.send_after(self(), :run, next_run)
  end

  @doc """
  Iterate over all languages and push info to DB.
  """
  def keep_history() do
    Language
    |> Repo.all
    |> Enum.each(&keep_language_history/1)
  end

  @doc """
  Push the info to the DB.
  """
  def keep_language_history(language) do
    params = %{krihelimeter: language.krihelimeter,
               num_of_repos: language.num_of_repos}
    %LanguageHistory{}
    |> LanguageHistory.changeset(params)
    |> Ecto.Changeset.put_assoc(:language, language)
    |> Repo.insert!()
  end
end
