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
    languages =
      Repo.all(GithubRepo)
      |> Stream.map(fn repo -> repo.language end)
      |> Stream.filter(fn l -> is_binary(l) && String.length(l) > 0 end)
      |> Stream.uniq
      |> Enum.sort
    render conn, :languages, languages: languages
  end

  def filter(query, %{"language" => language}) do
    from(item in query, where: item.language == ^language)
  end
  def filter(query, %{}), do: query
end
