defmodule Krihelinator.Repo.Migrations.CreateLanguageHistory do
  use Ecto.Migration

  def change do
    create table(:languages_history) do
      add :name, :string
      add :krihelimeter, :integer
      add :num_of_repos, :integer
      add :timestamp, :utc_datetime
    end
  end
end
