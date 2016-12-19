defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, params) do
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
    render conn, "repositories.html", repos: repos
  end

  def languages(conn, _params) do
    query = from(r in GithubRepo,
                 group_by: r.language,
                 select: %{name: r.language,
                           krihelimeter: sum(r.krihelimeter),
                           num_of_repos: count(r.id)},
                 order_by: [desc: sum(r.krihelimeter)],
                 where: not(is_nil(r.language)))
    languages = Repo.all(query)
    render conn, "languages.html", languages: languages
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
