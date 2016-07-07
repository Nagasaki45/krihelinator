defmodule Krihelinator.Repo.Migrations.CreateGithubRepo do
  use Ecto.Migration

  def change do
    create table(:repos) do
      add :user, :string
      add :repo, :string
      add :merged_pull_requests, :integer
      add :proposed_pull_requests, :integer
      add :closed_issues, :integer
      add :new_issues, :integer
      add :commits, :integer

      timestamps()
    end

    create unique_index(:repos, [:user, :repo], name: :user_repo)
  end
end
