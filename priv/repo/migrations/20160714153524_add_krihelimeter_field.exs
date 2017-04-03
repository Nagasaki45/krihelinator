defmodule Krihelinator.Repo.Migrations.AddKrihelimeterField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :krihelimeter, :integer
    end
  end
end
