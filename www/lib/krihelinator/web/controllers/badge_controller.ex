defmodule Krihelinator.BadgeController do
  use Krihelinator.Web, :controller

  def badge(conn, %{"user" => user, "repo" => repo}) do
    case GH.get_repo_by_name("#{user}/#{repo}") do
      {:error, _whatever} ->
        conn
        |> put_status(:not_found)
        |> render("error.json")
      {:ok, model} ->
        render conn, "badge.svg", repo: model
    end
  end

end
