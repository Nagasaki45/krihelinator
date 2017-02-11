defmodule Krihelinator.Repo.Migrations.AddDirtyBit do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :dirty, :boolean
    end
  end
end
