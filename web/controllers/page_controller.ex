defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def index(conn, _params) do
    repos = Repo.all(from GithubRepo, order_by: [desc: :krihelimeter])
    render conn, "index.html", repos: repos
  end
end
