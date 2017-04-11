defmodule Krihelinator.Repo.Migrations.UnlimitDescriptionLength do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      modify :description, :text
    end
  end
end
