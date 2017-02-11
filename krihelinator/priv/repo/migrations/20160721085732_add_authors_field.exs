defmodule Krihelinator.Repo.Migrations.AddAuthorsField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :authors, :integer
    end
  end
end
