defmodule Krihelinator.Repo.Migrations.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string
      add :krihelimeter, :integer
      add :num_of_repos, :integer

      timestamps()
    end
    create unique_index(:languages, [:name])

  end
end
