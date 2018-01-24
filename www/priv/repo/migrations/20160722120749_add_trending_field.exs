defmodule Krihelinator.Repo.Migrations.AddTrendingField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :trending, :boolean
    end
  end
end
