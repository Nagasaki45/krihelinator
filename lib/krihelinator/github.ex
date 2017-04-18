defmodule Krihelinator.Github do
  @moduledoc """
  A context for Github models.
  """

  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.Github, as: GH
  alias Krihelinator.Repo

  @doc """
  Fuzzy / scrapy get repo by name.
  """
  def get_repo_by_name(name) do
    query = from(r in GH.Repo,
                 where: ilike(r.name, ^name))
    with {:ok, :nil} <- {:ok, Repo.one(query)},
         {:ok, data} <- Krihelinator.Scraper.scrape(name)
    do
      data = Map.put(data, :user_requested, true)
      %GH.Repo{}
      |> GH.Repo.changeset(data)
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

  @doc """
  Get all repos that partially match the given name.
  """
  def query_repos_by_name(query_string) do
    query = from(r in GH.Repo,
                 where: ilike(r.name, ^"%#{query_string}%"),
                 order_by: [desc: r.krihelimeter],
                 limit: 50,
                 preload: :language)
    Repo.all(query)
  end

  @doc """
  Straight forward get by name (!) with preloaded repos.
  """
  def get_language_by_name!(name) do
    repos_query = from(r in GH.Repo,
                       order_by: [desc: r.krihelimeter],
                       limit: 50)

    GH.Language
    |> Repo.get_by!(name: name)
    |> Repo.preload([repos: repos_query])
  end

  @doc """
  Straight forward all languages with krihelimeter > 0, in descending order.
  """
  def all_languages() do
    query = from(l in GH.Language,
                 order_by: [{:desc, :krihelimeter}],
                 where: l.krihelimeter > 0)
    Repo.all(query)
  end

  @doc """
  Straight forward get by href (!) with preloaded repos.
  """
  def get_showcase_by_href!(showcase_href) do
    repos_query = from(r in GH.Repo,
                       order_by: [desc: r.krihelimeter],
                       preload: :language,
                       limit: 50)

    GH.Showcase
    |> Repo.get_by!(href: showcase_href)
    |> Repo.preload([repos: repos_query])
  end

  @doc """
  Straight forward all showcases with at least one repo.
  """
  def all_showcases() do
    query = from(p in GH.Showcase,
                 join: r in GH.Repo, on: [showcase_id: p.id],
                 group_by: p.id,
                 having: count(r.id) > 0)
    Repo.all(query)
  end

  @doc """
  Local path to repo.
  """
  def repo_path(conn, full_name) do
    [user, repo] = String.split(full_name, "/")
    Krihelinator.Web.Router.Helpers.page_path(conn, :repository, user, repo)
  end
end
