defmodule Krihelinator.Controllers.Helpers do
  @moduledoc """
  Common helpers for the controllers.
  """

  alias Krihelinator.{GithubRepo, Repo, Scraper}

  def get_from_db_or_scrape(name) do
    case Repo.get_by(GithubRepo, name: name) do
      :nil ->
        %GithubRepo{}
        |> GithubRepo.cast_allowed(%{name: name, user_requested: true})
        |> Scraper.scrape_repo()
        |> GithubRepo.finalize_changeset()
        |> Ecto.Changeset.validate_inclusion(:name, [name])
        |> Repo.insert()
      model ->
        {:ok, model}
    end
  end
end
