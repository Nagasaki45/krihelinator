defmodule Krihelinator.Controllers.Helpers do
  @moduledoc """
  Common helpers for the controllers.
  """

  alias Krihelinator.{GithubRepo, Repo, Scraper}
  require Logger
  import Ecto.Query, only: [from: 2]

  def get_from_db_or_scrape(name) do
    query = from(r in GithubRepo,
                 where: ilike(r.name, ^name))
    with {:ok, :nil} <- {:ok, Repo.one(query)},
         {:ok, data} <- Scraper.scrape(name)
    do
      data = Map.put(data, :user_requested, true)
      %GithubRepo{}
      |> GithubRepo.changeset(data)
      |> Repo.insert()
      |> log_new_user_requested_repo()
    end
  end

  defp log_new_user_requested_repo({:ok, repo}) do
    Logger.info("New user_requested repo: #{repo.name}")
    {:ok, repo}
  end
  defp log_new_user_requested_repo(otherwise) do
    otherwise
  end

  def repository_path(conn, full_name) do
    [user, repo] = String.split(full_name, "/")
    Krihelinator.Router.Helpers.page_path(conn, :repository, user, repo)
  end
end
