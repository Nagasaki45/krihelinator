defmodule Krihelinator.History do
  require Logger

  @moduledoc """
  A module to keep track of the history.
  """

  import Ecto.Query, only: [from: 2]

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

  def get_languages_history_json(language_names) do
    query = from(h in Krihelinator.History.Language,
                 join: l in assoc(h, :language),
                 where: l.name in ^language_names,
                 order_by: :timestamp,
                 preload: :language)

    query
    |> Krihelinator.Repo.all()
    |> Stream.map(&(
      %{name: &1.language.name,
        timestamp: &1.timestamp,
        krihelimeter: &1.krihelimeter}
    ))
    |> Poison.encode!()
  end
end
