defmodule Krihelinator.APIController do
  use Krihelinator.Web, :controller

  def repositories(conn, params) do
    repos =
      GithubRepo
      |> order_by(desc: :krihelimeter)
      |> filter(params)
      |> limit(50)
      |> Repo.all
    render conn, :repositories, repos: repos
  end

  def languages(conn, _params) do
    query = from(r in GithubRepo,
                 group_by: r.language,
                 select: %{name: r.language, krihelimeter: sum(r.krihelimeter)},
                 where: not(is_nil(r.language)))
    languages = Repo.all(query)
    render conn, :languages, languages: languages
  end

  def filter(query, %{"language" => language}) do
    from(item in query, where: item.language == ^language)
  end
  def filter(query, %{}), do: query
end
