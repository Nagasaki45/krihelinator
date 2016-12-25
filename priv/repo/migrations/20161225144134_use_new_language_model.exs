defmodule Krihelinator.Repo.Migrations.UseNewLanguageModel do
  use Ecto.Migration
  alias Krihelinator.{Repo, GithubRepo, LanguageHistory, Language}

  @moduledoc """
  The GithubRepo model has a language field, and the LanguageHistory has a
  name field. Both fields should be replaced with belong_to fields to the new
  Language model.
  Note that the old fields are not removed, to make sure no data is
  deleted. In the case of GithubRepo the old field is renamed to language_name.
  In the future it will be changed to a virtual field.
  """

  def up do
    # Keep the old GithubRepo.language to new field
    rename table(:repos), :language, to: :language_name
    # Add a reference for GithubRepo to the Language table
    alter table(:repos) do
      add :language_id, references(:languages)
    end
    create index(:repos, [:language_id])
    # Add a reference for LanguageHistory to the Language table
    alter table(:languages_history) do
      add :language_id, references(:languages)
    end
    create index(:languages_history, [:language_id])

    flush()

    # Copy the language data from GithubRepo.language_name to GithubRepo.language
    GithubRepo
    |> Repo.all()
    |> Repo.preload(:language)
    |> Stream.filter(fn repo -> repo.language_name end)
    |> Enum.each(fn repo ->
      {:ok, language} = Repo.get_or_create_by(Language, name: repo.language_name)
      repo
      |> GithubRepo.changeset()
      |> Ecto.Changeset.put_assoc(:language, language)
      |> Repo.insert_or_update()
    end)

    # Same for the history
    LanguageHistory
    |> Repo.all()
    |> Repo.preload(:language)
    |> Enum.each(fn datum ->
      {:ok, language} = Repo.get_or_create_by(Language, name: datum.name)
      datum
      |> LanguageHistory.changeset()
      |> Ecto.Changeset.put_assoc(:language, language)
      |> Repo.insert_or_update()
    end)

    Krihelinator.Periodic.update_languages_stats()
  end

  def down do
    drop index(:repos, [:language_id])
    alter table(:repos) do
      remove :language_id
    end
    rename table(:repos), :language_name, to: :language
    drop index(:languages_history, [:language_id])
    alter table(:languages_history) do
      remove :language_id
    end
  end
end
