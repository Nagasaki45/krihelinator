defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, %{"query" => ""}) do
    conn
    |> put_flash(:error, "No search query was provided.")
    |> repositories(%{})
  end
  def repositories(conn, %{"query" => query_string, "type" => "github"}) do
    case GH.get_repo_by_name(query_string) do
      {:error, _whatever} ->
        conn
        |> put_flash(:error, "The repository \"#{query_string}\" does not exist.")
        |> repositories(%{})
      {:ok, model} ->
        redirect(conn, to: GH.repo_path(conn, model.name))
    end
  end
  def repositories(conn, params) do
    query_string = Map.get(params, "query")
    repos = GH.query_repos_by_name(query_string)
    render conn, "repositories.html", repos: repos
  end

  def repository(conn, %{"user" => user, "repo" => repo}) do
    repository_name = "#{user}/#{repo}"
    case GH.get_repo_by_name(repository_name) do
      {:error, _error} ->
        conn
        |> put_status(:not_found)
        |> render(Krihelinator.ErrorView, "404.html")
      {:ok, repo} ->
        repo = Repo.preload(repo, :language)
        render(conn, "repository.html", repo: repo)
    end
  end

  def language(conn, %{"language" => language_name}) do
    language = GH.get_language_by_name!(language_name)
    render(conn, "language.html", language: language)
  end

  def languages(conn, _params) do
    languages = GH.all_languages()
    render(conn, "languages.html", languages: languages)
  end

  def languages_history(conn, params) do
    case Krihelinator.InputValidator.validate_history_query(params) do

      {:ok, language_names} ->
        json = Krihelinator.History.get_languages_history_json(language_names)
        render conn, "languages_history.html", json: json

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> put_status(:bad_request)
        |> render(Krihelinator.ErrorView, "400.html")
    end

  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
