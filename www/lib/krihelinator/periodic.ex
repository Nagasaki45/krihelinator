defmodule Krihelinator.Periodic do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.Repo
  alias Krihelinator.Github, as: GH

  @moduledoc """
  A background task that needs to run periodically on the Krihelinator server.

  - Mark all github repos as "dirty".
  - Scrape the github trending page for interesting, active, projects.
  - Using BigQuery, get and scrape all repos that at least 2 users pushed
    commits to.
  - Get the remaining "dirty" repos and pass through the scraper again, to
    update stats.
  - Clean the remaining dirty repos. These repos failed to update or fell bellow
    activity threshold.
  - Update the total krihelimeter for all languages.
  """

  defp periodically_gc(pid) do
    # This is an ugly hack to force GC every now and then on the periodic
    # process. TODO search for a better solution!
    Process.sleep(30_000)
    if Process.alive?(pid) do
      :erlang.garbage_collect(pid)
      periodically_gc(pid)
    end
  end

  @doc """
  Main entry point.
  """
  def run() do
    my_pid = self()
    Task.async(fn -> periodically_gc(my_pid) end)
    Logger.info "Periodic process kicked in!"
    set_dirty_bit()
    scrape_trending()
    scrape_from_bigquery()
    rescrape_still_dirty()
    clean_dirty()
    update_languages_stats()
    Logger.info "Periodic process finished successfully!"
  end

  def set_dirty_bit() do
    Logger.info "Setting dirty bit for all"
    Repo.update_all(GH.Repo, set: [dirty: true])
  end

  @doc """
  Scrape the github trending page and update repos.
  """
  def scrape_trending() do
    Logger.info "Resetting trendiness for all"
    Repo.update_all(GH.Repo, set: [trending: false])
    Logger.info "Scraping trending"
    names = Krihelinator.Periodic.GithubTrending.scrape()
    async_handle(names, trending: true)
  end

  @doc """
  Request repos from google BigQuery, scrape, and persist.
  """
  def scrape_from_bigquery() do
    Logger.info "Getting repositories from BigQuery to scrape"
    names = Krihelinator.Periodic.BigQuery.query()
    async_handle(names)
  end

  @doc """
  Get the rest of the repositories that weren't updated from github trending
  or BigQuery and rescrape.
  """
  def rescrape_still_dirty() do
    query = from(r in GH.Repo, where: r.dirty, select: r.name)
    names = Repo.all(query)
    Logger.info "Rescraping #{length(names)} still dirty repositories"
    async_handle(names)
  end

  @async_params [max_concurrency: 20, on_timeout: :kill_task]

  @doc """
  Scrape and persist repositories concurrently with `Task.async_stream`.
  """
  def async_handle(names, extra_params \\ []) do
    names
    |> Task.async_stream(&handle(&1, extra_params), @async_params)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Enum.each(&log_aggregated_results/1)
  end

  @doc """
  Scrape and persist a single repository by name.
  """
  def handle(name, extra_params) do
    name
    |> scrape_with_retries()
    |> put_extra_params(extra_params)
    |> persist()
    |> simplify_result()
  end

  @no_retry ~w(page_not_found dmca_takedown)a
  @max_attempts 3

  def scrape_with_retries(name, attempt \\ 1) do
    case Krihelinator.Scraper.scrape(name) do
      {:error, error} when error not in @no_retry ->
        if attempt <= @max_attempts do
          scrape_with_retries(name, attempt + 1)
        else
          Logger.error "Scraping #{name} failed with #{inspect(error)}"
          {:error, error}
        end
      otherwise ->
        otherwise
    end
  end

  def put_extra_params({:error, error}, _extra_params) do
    {:error, error}
  end
  def put_extra_params({:ok, data}, extra_params) do
    {:ok, Map.merge(data, Map.new(extra_params))}
  end

  def persist({:error, error}) do
    {:error, error}
  end
  def persist({:ok, data}) do
    Repo.update_or_create_from_data(GH.Repo, data, by: :name)
  end

  def simplify_result({:error, %Ecto.Changeset{}}), do: :validation_error
  def simplify_result({:error, error}), do: error
  def simplify_result({:ok, _whatever}), do: :ok

  def log_aggregated_results({key, count}) do
    Logger.info "#{count} operations ended with #{inspect(key)}"
  end

  @doc """
  Clean the DB from repositories that failed to update properly in the last
  periodic loop.
  """
  def clean_dirty do
    Logger.info "Cleaning dirty repos"
    query = from(r in GH.Repo, where: r.dirty)
    {num, _whatever} = Repo.delete_all(query)
    Logger.info "Cleaned #{num} dirty repos"
  end

  @doc """
  Update the total krihelimeter for all languages.
  """
  def update_languages_stats() do
    Logger.info "Updating languages statistics"
    GH.Language
    |> Repo.all()
    |> Repo.preload(:repos)
    |> Enum.each(fn language ->
      changes = %{
        krihelimeter: Enum.sum(for r <- language.repos, do: r.krihelimeter),
      }
      language
      |> GH.Language.changeset(changes)
      |> Repo.update()
    end)
  end
end
