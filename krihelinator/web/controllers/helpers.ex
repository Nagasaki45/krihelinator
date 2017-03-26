defmodule Krihelinator.Controllers.Helpers do
  @moduledoc """
  Common helpers for the controllers.
  """

  alias Krihelinator.{GithubRepo, Repo, Scraper}
  require Logger

  def get_from_db_or_scrape(name) do
    case Repo.get_by(GithubRepo, name: name) do
      :nil ->
        %GithubRepo{}
        |> GithubRepo.cast_allowed(%{name: name, user_requested: true})
        |> Scraper.scrape_repo()
        |> GithubRepo.finalize_changeset()
        |> Ecto.Changeset.validate_inclusion(:name, [name])
        |> Repo.insert()
        |> log_new_user_requested_repo()
      model ->
        {:ok, model}
    end
  end

  defp log_new_user_requested_repo({:ok, repo}) do
    Logger.info("New user_requested repo: #{repo.name}")
    {:ok, repo}
  end
  defp log_new_user_requested_repo(otherwise) do
    otherwise
  end

  def repository_path(conn, repo) do
    [user, repo] = String.split(repo.name, "/")
    Krihelinator.Router.Helpers.page_path(conn, :repository, user, repo)
  end
end
