defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, _params) do
    repos = Repo.all from(r in GithubRepo,
                          order_by: [desc: r.krihelimeter],
                          limit: 50,
                          preload: :language)
    render conn, "repositories.html", repos: repos
  end

  def repository(conn, %{"user" => user, "repo" => repo}) do
    repository_name = "#{user}/#{repo}"
    case get_from_db_or_scrape(repository_name) do
      {:error, _whatever} ->
        conn
        |> put_flash(:error, "The repository \"#{repository_name}\" does not exist. Note that search is case sensitive.")
        |> redirect(to: page_path(conn, :repositories))
      {:ok, model} ->
        model = Repo.preload(model, :language)
        render(conn, "repository.html", repo: model)
    end
  end

  def language(conn, %{"language" => language_name}) do
    repos_query = from(r in GithubRepo,
                       order_by: [desc: r.krihelimeter],
                       limit: 50)

    language =
      Language
      |> Repo.get_by!(name: language_name)
      |> Repo.preload([repos: repos_query])

    render(conn, "language.html", language: language)
  end

  def languages(conn, _params) do
    query = from(l in Language,
                 order_by: [{:desc, :krihelimeter}],
                 where: l.krihelimeter > 0)
    languages = Repo.all(query)
    render(conn, "languages.html", languages: languages)
  end

  def languages_history(conn, params) do
    case Krihelinator.InputValidator.validate_history_query(params) do

      {:ok, language_names} ->

        query = from(h in Krihelinator.LanguageHistory,
                     order_by: :timestamp,
                     preload: :language)

        json =
          query
          |> Repo.all()
          |> Stream.filter(&(&1.language.name in language_names))
          |> Stream.map(&(
              %{name: &1.language.name,
                timestamp: &1.timestamp,
                value: &1.krihelimeter}
          ))
          |> Poison.encode!()
        render conn, "languages_history.html", json: json

      {:error, error} ->

        conn
        |> put_flash(:error, error)
        |> put_status(:bad_request)
        |> render(Krihelinator.ErrorView, "400.html")
    end

  end

  def showcases(conn, _params) do
    showcases = Repo.all(Showcase)
    render conn, "showcases.html", showcases: showcases
  end

  def showcase(conn, %{"showcase" => showcase_href}) do
    repos_query = from(r in GithubRepo,
                       order_by: [desc: r.krihelimeter],
                       preload: :language,
                       limit: 50)

    showcase =
      Showcase
      |> Repo.get_by!(href: showcase_href)
      |> Repo.preload([repos: repos_query])

    render(conn, "showcase.html", showcase: showcase)
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
