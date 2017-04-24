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
  - Scrape showcases from github and update repos that belongs to showcases.
  """

  @doc """
  Main entry point.
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
    Repo.update_all(GH.Repo, set: [dirty: true])
  end

  @doc """
  Scrape the github trending page and update repos.
  """
  def scrape_trending() do
    Logger.info "Resetting trendiness for all"
    Repo.update_all(GH.Repo, set: [trending: false])
    Logger.info "Scraping trending"
    Krihelinator.Periodic.GithubTrending.scrape()
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
    Krihelinator.Periodic.BigQuery.query()
    |> async_scrape()
    |> handle_scraped_data()
  end

  @doc """
  Get the rest of the repositories that weren't updated from github trending
  or BigQuery and rescrape.
  """
  def rescrape_still_dirty() do
    query = from(r in GH.Repo, where: r.dirty, select: r.name)
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
    |> Task.async_stream(&scrape_with_retries/1, @async_params)
    |> Stream.map(fn {:ok, cs} -> cs end)
  end

  @to_retry ~w(github_server_error timeout)a
  @max_attempts 3

  def scrape_with_retries(name, attempt \\ 1) do
    case Krihelinator.Scraper.scrape(name) do
      {:error, error} when error in @to_retry ->
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

  @doc """
  Persist the scraped data and log results statistics.
  """
  def handle_scraped_data(data_stream) do
    data_stream
    |> Stream.map(fn
      {:ok, data} ->
        Repo.update_or_create_from_data(GH.Repo, data, by: :name)
      otherwise ->
        otherwise
    end)
    |> Stream.map(&simplify_result/1)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Enum.each(&log_aggregated_results/1)
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

  def scrape_showcases() do
    Logger.info "Scraping showcases and updating repos"
    maps = Krihelinator.Periodic.GithubShowcases.scrape()
    for map <- maps do
      params = [name: map.name, href: map.href]
      {:ok, showcase} = Repo.get_or_create_by(GH.Showcase, params)
      query = from(r in GH.Repo, where: r.name in ^map.repos)
      Repo.update_all(query, set: [showcase_id: showcase.id])
      # Update the showcase description
      showcase
      |> GH.Showcase.changeset(%{description: map.description})
      |> Repo.update
    end
  end
end
