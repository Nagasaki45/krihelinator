defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def index(conn, _params) do
    query = from GithubRepo, order_by: [desc: :krihelimeter], limit: 50
    repos = Repo.all(query)
    render conn, "index.html", repos: repos
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
