defmodule Krihelinator.BadgeController do
  use Krihelinator.Web, :controller

  def badge(conn, %{"user" => user, "repo" => repo}) do
    case get_from_db_or_scrape("#{user}/#{repo}") do
      {:error, _whatever} ->
        conn
        |> put_status(:not_found)
        |> render("error.json")
      {:ok, model} ->
        render conn, "badge.svg", repo: model
    end
  end

end
