defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller
  alias Krihelinator.Repo
  alias Krihelinator.GithubRepo
  alias Krihelinator.Krihelimeter

  def index(conn, _params) do
    repos =
      Repo.all(GithubRepo)
      |> Enum.sort_by(&Krihelimeter.calculate/1, &>=/2)  # Descending
    render conn, "index.html", repos: repos
  end
end
