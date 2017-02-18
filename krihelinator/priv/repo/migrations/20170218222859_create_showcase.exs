defmodule Krihelinator.Repo.Migrations.CreateShowcase do
  use Ecto.Migration

  def change do
    create table(:showcases) do
      add :name, :string
      add :href, :string

      timestamps()
    end
    create unique_index(:showcases, [:name])
    create unique_index(:showcases, [:href])

    alter table(:repos) do
      add :showcase_id, references(:showcases)
    end
  end
end
