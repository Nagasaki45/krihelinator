defmodule Krihelinator.Repo.Migrations.AddShowcaseDescription do
  use Ecto.Migration

  def change do
    alter table(:showcases) do
      add :description, :text
    end
  end
end
