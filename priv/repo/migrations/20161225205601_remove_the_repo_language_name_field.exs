defmodule Krihelinator.Repo.Migrations.RemoveTheRepoLanguageNameField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      remove :language_name
    end
  end
end
