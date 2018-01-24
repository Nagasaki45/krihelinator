defmodule Krihelinator.Repo.Migrations.RemoveNumOfRepos do
  use Ecto.Migration

  def change do
    alter table(:languages) do
      remove :num_of_repos
    end

    alter table(:languages_history) do
      remove :num_of_repos
    end
  end
end
