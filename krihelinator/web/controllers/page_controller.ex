defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, _params) do
    repos = Repo.all from(r in GithubRepo,
                          order_by: [desc: r.krihelimeter],
                          limit: 50,
                          preload: :language)
    render conn, "repositories.html", repos: repos
  end

  def language(conn, %{"language" => language_name}) do
    repos_query = from(r in GithubRepo,
                       order_by: [desc: r.krihelimeter],
                       limit: 50)
    language = Repo.one from(l in Language,
                             where: l.name == ^language_name,
                             preload: [repos: ^repos_query])

    case language do

      nil ->
        conn
        |> put_status(:not_found)
        |> put_layout(false)
        |> render(Krihelinator.ErrorView, "404.html", [])

      _otherwise ->
        render(conn, "language.html", language: language)

    end
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
    showcase = Repo.one from(s in Showcase,
                             where: s.href == ^showcase_href,
                             preload: [repos: ^repos_query])

    case showcase do

      nil ->
        conn
        |> put_status(:not_found)
        |> put_layout(false)
        |> render(Krihelinator.ErrorView, "404.html", [])

      _otherwise ->
        render(conn, "showcase.html", showcase: showcase)

    end
  end

  def badge(conn, _params) do
    render conn, "badge.html"
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
