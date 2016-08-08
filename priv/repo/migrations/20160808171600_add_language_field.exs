defmodule Krihelinator.Repo.Migrations.AddLanguageField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :language, :string
    end
  end
end
