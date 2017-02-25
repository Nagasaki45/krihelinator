defmodule Krihelinator.Repo.Migrations.UseNewLanguageModel do
  use Ecto.Migration

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
