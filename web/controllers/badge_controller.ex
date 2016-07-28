defmodule Krihelinator.BadgeController do
  use Krihelinator.Web, :controller
  import Krihelinator.Pipeline.StatsScraper, only: [scrape: 1]

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

  def get_from_db_or_scrape(name) do
    case Repo.get_by(GithubRepo, name: name) do
      :nil ->
        scraped =
          %{name: name}
          |> scrape
          |> Map.put(:user_requested, true)
        %GithubRepo{}
        |> GithubRepo.changeset(scraped)
        |> Repo.insert
      model ->
        {:ok, model}
    end
  end
end
