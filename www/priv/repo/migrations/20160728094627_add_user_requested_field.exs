defmodule Krihelinator.Repo.Migrations.AddUserRequestedField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :user_requested, :boolean, default: false
    end
  end
end
