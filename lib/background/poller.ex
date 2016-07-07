defmodule Krihelinator.Background.Poller do
  alias Krihelinator.Background

  @moduledoc """
  A task that loop through all github repositories, using the github API,
  and send jobs to the `StatsScraper`.

  When there are no more repos to fetch, it simply dies, and the supervisor
  restart it.
  """

  @base_path "repositories"

  def start_link do
    Task.start_link(fn -> process_repos(@base_path) end)
  end

  @doc """
  Fetch repos with the github API, and send them to the `StatsGetter`.
  """
  def process_repos(url) do
    {:ok, resp} = Background.GithubAPI.limited_get(url)
    %{body: repos, status_code: 200} = resp

    Enum.each(repos, &process_repo/1)

    repos
    |> next_path
    |> process_repos
  end

  def process_repo(repo) do
    repo
    |> Map.get("full_name")
    |> String.split("/")
    |> List.to_tuple
    |> Background.StatsScraper.process
  end

  def next_path(repos) do
    last_id = repos |> List.last |> Map.get("id")
    @base_path <> "?since=#{last_id}"
  end
end
