defmodule Krihelinator.Periodic do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.{Periodic, Repo, GithubRepo, Language, Showcase, Scraper}

  @moduledoc """
  Every `:periodic_schedule` do the following:

  - Mark all github repos as "dirty".
  - Scrape the github trending page for interesting, active, projects.
  - Using BigQuery, get and scrape all repos that at least 2 users pushed
    commits to.
  - Get the remaining "dirty" repos and pass through the scraper again, to
    update stats.
  - Clean the remaining dirty repos. These repos failed to update or fell bellow
    activity threshold.
  - Update the total krihelimeter and num_of_repos for all languages.
  - Scrape showcases from github and update repos that belongs to showcases.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    reschedule_work()
    {:ok, :nil}
  end

  def handle_info(:run, state) do
    run()
    reschedule_work()
    {:noreply, state}
  end

  @doc """
  Schedule the next run in `:periodic_schedule` milliseconds.
  """
  def reschedule_work do
    next_run = Application.fetch_env!(:krihelinator, :periodic_schedule)
    Process.send_after(self(), :run, next_run)
  end

  @doc """
  The tasks to run every periodic loop.
  """
  def run() do
    Logger.info "Periodic process kicked in!"
    set_dirty_bit()
    scrape_trending()
    scrape_from_bigquery()
    rescrape_still_dirty()
    clean_dirty()
    update_languages_stats()
    scrape_showcases()
    Logger.info "Periodic process finished successfully!"
  end

  def set_dirty_bit() do
    Logger.info "Setting dirty bit for all"
    Repo.update_all(GithubRepo, set: [dirty: true])
  end

  @doc """
  Scrape the github trending page and update repos.
  """
  def scrape_trending() do
    Logger.info "Resetting trendiness for all"
    Repo.update_all(GithubRepo, set: [trending: false])
    Logger.info "Scraping trending"
    Periodic.GithubTrending.scrape()
    |> async_scrape()
    |> Stream.map(fn
      {:ok, data} -> {:ok, Map.put(data, :trending, true)}
      otherwise -> otherwise
    end)
    |> handle_scraped_data()
  end

  @doc """
  Request repos from google BigQuery, scrape, and persist.
  """
  def scrape_from_bigquery() do
    Logger.info "Getting repositories from BigQuery to scrape"
    Periodic.BigQuery.query()
    |> async_scrape()
    |> handle_scraped_data()
  end

  @doc """
  Get the rest of the repositories that weren't updated from github trending
  or BigQuery and rescrape.
  """
  def rescrape_still_dirty() do
    query = from(r in GithubRepo, where: r.dirty, select: r.name)
    names = Repo.all(query)
    Logger.info "Rescraping #{length(names)} still dirty repositories"
    names
    |> async_scrape
    |> handle_scraped_data()
  end

  @async_params [max_concurrency: 20, timeout: 60_000]

  @doc """
  Scrape repositories concurrently with `Task.async_stream`.
  """
  def async_scrape(names) do
    names
    |> Task.async_stream(&Scraper.scrape/1, @async_params)
    |> Stream.map(fn {:ok, cs} -> cs end)
  end

  @doc """
  Persist the scraped data and log results statistics.
  """
  def handle_scraped_data(data_stream) do
    data_stream
    |> Stream.map(fn
      {:ok, data} ->
        Repo.update_or_create_from_data(GithubRepo, data, by: :name)
      otherwise ->
        otherwise
    end)
    |> Enum.reduce(%{}, &collect_results/2)
    |> Enum.each(&log_aggregated_results/1)
  end

  def collect_results({:error, %Ecto.Changeset{}}, acc), do: collect_results(:validation_error, acc)
  def collect_results({:error, error}, acc), do: collect_results(error, acc)
  def collect_results({:ok, _whatever}, acc), do: collect_results(:ok, acc)
  def collect_results(something, acc), do: Map.update(acc, something, 1, &(&1 + 1))

  def log_aggregated_results({key, count}) do
    Logger.info "#{count} operations ended with #{inspect(key)}"
  end

  @doc """
  Clean the DB from repositories that failed to update properly in the last
  periodic loop.
  """
  def clean_dirty do
    Logger.info "Cleaning dirty repos"
    query = from(r in GithubRepo, where: r.dirty)
    {num, _whatever} = Repo.delete_all(query)
    Logger.info "Cleaned #{num} dirty repos"
  end

  @doc """
  Update the total krihelimeter and num_of_repos for all languages.
  """
  def update_languages_stats() do
    Logger.info "Updating languages statistics"
    Language
    |> Repo.all()
    |> Repo.preload(:repos)
    |> Enum.each(fn language ->
      changes = %{
        krihelimeter: Enum.sum(for r <- language.repos, do: r.krihelimeter),
        num_of_repos: length(language.repos)
      }
      language
      |> Language.changeset(changes)
      |> Repo.update()
    end)
  end

  def scrape_showcases() do
    Logger.info "Scraping showcases and updating repos"
    maps = Periodic.GithubShowcases.scrape()
    for map <- maps do
      params = [name: map.name, href: map.href]
      {:ok, showcase} = Repo.get_or_create_by(Showcase, params)
      query = from(r in GithubRepo, where: r.name in ^map.repos)
      Repo.update_all(query, set: [showcase_id: showcase.id])
      # Update the showcase description
      showcase
      |> Showcase.changeset(%{description: map.description})
      |> Repo.update
    end
  end
end
