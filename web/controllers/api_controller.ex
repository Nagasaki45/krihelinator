defmodule Krihelinator.APIController do
  use Krihelinator.Web, :controller

  def index(conn, _params) do
    query = from GithubRepo, order_by: [desc: :krihelimeter], limit: 50
    repos = Repo.all(query)
    render conn, :repositories, repos: repos
  end
end
