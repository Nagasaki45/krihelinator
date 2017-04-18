defmodule Krihelinator.Web.Controllers.Helpers do
  @moduledoc """
  Common helpers for the controllers.
  """

  require Logger
  import Ecto.Query, only: [from: 2]

  def get_from_db_or_scrape(name) do
    query = from(r in Krihelinator.Github.Repo,
                 where: ilike(r.name, ^name))
    with {:ok, :nil} <- {:ok, Krihelinator.Repo.one(query)},
         {:ok, data} <- Krihelinator.Scraper.scrape(name)
    do
      data = Map.put(data, :user_requested, true)
      %Krihelinator.Github.Repo{}
      |> Krihelinator.Github.Repo.changeset(data)
      |> Krihelinator.Repo.insert()
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
    Krihelinator.Web.Router.Helpers.page_path(conn, :repository, user, repo)
  end
end
