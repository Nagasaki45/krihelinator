defmodule Krihelinator.Repo.Migrations.RepoNameInsteadOfUserAndRepoFields do
  use Ecto.Migration

  def change do

    drop index(:repos, [:user, :repo], name: :user_repo)  # previous unique_index

    alter table(:repos) do
      remove :user
      remove :repo
      add :name, :string
    end

    create unique_index(:repos, [:name])
  end
end
