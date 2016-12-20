defmodule Krihelinator.Repo.Migrations.AddForksField do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      add :forks, :integer
    end
  end
end
