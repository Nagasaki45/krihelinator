defmodule Krihelinator.History do
  require Logger

  @moduledoc """
  A module to keep track of the history.
  """

  @doc """
  Create new History.Language record with stats for any language in the DB.
  """
  def keep_languages_history() do
    Logger.info "History.keep_languages_history() kicked in!"
    Krihelinator.Github.Language
    |> Krihelinator.Repo.all()
    |> Enum.each(&keep_language_history/1)
    Logger.info "History.keep_languages_history() finished successfully!"
  end

  defp keep_language_history(language) do
    params = %{krihelimeter: language.krihelimeter,
               timestamp: DateTime.utc_now()}
    %Krihelinator.History.Language{}
    |> Krihelinator.History.Language.changeset(params)
    |> Ecto.Changeset.put_assoc(:language, language)
    |> Krihelinator.Repo.insert!()
  end
end
