defmodule Krihelinator.HistoryKeeper do
  require Logger
  alias Krihelinator.{Repo, Language, LanguageHistory}

  @moduledoc """
  For each language, keep the total krihelimeter and the number of repos.
  """

  @doc """
  Run the HistoryKeeper. Create new LanguageHistory record with stats for any
  language in the DB.
  """
  def run() do
    Logger.info "HistoryKeeper process kicked in!"
    Language
    |> Repo.all
    |> Enum.each(&keep_language_history/1)
    Logger.info "HistoryKeeper process finished successfully!"
  end

  @doc """
  Create new LanguageHistory record for a language.
  """
  def keep_language_history(language) do
    params = %{krihelimeter: language.krihelimeter,
               num_of_repos: language.num_of_repos,
               timestamp: DateTime.utc_now()}
    %LanguageHistory{}
    |> LanguageHistory.changeset(params)
    |> Ecto.Changeset.put_assoc(:language, language)
    |> Repo.insert!()
  end
end
