defmodule Krihelinator.Repo.Migrations.AddDescriptionField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :description, :string
    end
  end
end
