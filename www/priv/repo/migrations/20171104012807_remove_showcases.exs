defmodule Krihelinator.Repo.Migrations.RemoveShowcase do
  use Ecto.Migration

  def change do
    alter table(:repos) do
      remove :showcase_id
    end

    drop table(:showcases)
  end
end
