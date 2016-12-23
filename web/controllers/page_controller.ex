defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, _params) do
    repos =
      GithubRepo
      |> order_by(desc: :krihelimeter)
      |> limit(50)
      |> Repo.all
    render conn, "repositories.html", repos: repos
  end

  def language(conn, %{"language" => language}) do
    repos =
      GithubRepo
      |> where(language: ^language)
      |> order_by(desc: :krihelimeter)
      |> limit(50)
      |> Repo.all
    conn
    |> put_flash(:info, "#{language} repositories")
    |> render("repositories.html", repos: repos)
  end

  def languages(conn, _params) do
    languages = Repo.all(GithubRepo.languages_query)
    render conn, "languages.html", languages: languages
  end

  def languages_history(conn, params) do
    languages =
      params
      |> Map.get("languages", "[]")
      |> Poison.decode!
    query = from(d in LanguageHistory,
                 where: d.name in ^languages)
    value_field = Map.get(params, "by", "krihelimeter")
    history =
      query
      |> Repo.all()
      |> Enum.map(fn datum ->
        LanguageHistory.choose_stat_field(datum, value_field)
      end)
    assigns = [history: history, value_field: value_field]
    render conn, "languages_history.html", assigns
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
