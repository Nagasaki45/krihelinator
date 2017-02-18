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
    update_showcases()
    Logger.info "Periodic process finished successfully!"
  end

  def set_dirty_bit() do
    Logger.info "Setting dirty bit for all..."
    Repo.update_all(GithubRepo, set: [dirty: true])
  end

  @doc """
  Scrape the github trending page and update repos.
  """
  def scrape_trending() do
    Logger.info "Resetting trendingness for all..."
    Repo.update_all(GithubRepo, set: [trending: false])
    Logger.info "Scraping trending..."
    Periodic.GithubTrending.scrape()
    |> Stream.map(&prepare_changeset/1)
    |> Stream.map(fn cs -> Ecto.Changeset.put_change(cs, :trending, true) end)
    |> handle_changesets
  end

  @doc """
  Request repos to scrape from google BigQuery. See the moduledoc for more info.
  """
  def scrape_from_bigquery() do
    Logger.info "Getting repositories from BigQuery to scrape..."
    Periodic.BigQuery.query()
    |> Stream.map(&prepare_changeset/1)
    |> handle_changesets
  end

  @doc """
  Create changeset to work with. If the name already in the DB use that,
  otherwise create changeset from `params`.
  """
  def prepare_changeset(name) do
    case Repo.get_by(GithubRepo, name: name) do
      :nil -> GithubRepo.cast_allowed(%GithubRepo{}, %{name: name})
      struct -> GithubRepo.changeset(struct)
    end
  end

  @doc """
  Get the rest of the repositories that weren't updated from github trending
  or BigQuery and rescrape.
  """
  def rescrape_still_dirty() do
    Logger.info "Rescraping still dirty repositories..."
    query = from(r in GithubRepo, where: r.dirty)
    query
    |> Repo.all()
    |> Stream.map(fn struct -> GithubRepo.cast_allowed(struct) end)
    |> handle_changesets
  end

  @doc """
  Run the changesets asyncronously through the scraper, apply extra validations,
  push to the DB and log issues.
  """
  def handle_changesets(changesets) do
    max_concurrency = Application.fetch_env!(:krihelinator, :scrapers_pool_size)
    async_params = [max_concurrency: max_concurrency, timeout: 60_000]
    changesets
    |> Task.async_stream(&Scraper.scrape_repo/1, async_params)
    |> Stream.map(fn {:ok, cs} -> cs end)
    |> Stream.map(&GithubRepo.finalize_changeset/1)
    |> Stream.map(&apply_restrictive_validations/1)
    |> Stream.map(&Repo.insert_or_update/1)
    |> Enum.each(&log_changeset_errors/1)
  end

  @doc """
  If not user_requested make sure stats are above thresholds.
  """
  def apply_restrictive_validations(changeset) do
    if Ecto.Changeset.get_field(changeset, :user_requested) do
      changeset
    else
      changeset
      |> Ecto.Changeset.validate_number(:forks, greater_than_or_equal_to: 10)
      |> Ecto.Changeset.validate_number(:krihelimeter, greater_than_or_equal_to: 30)
    end
  end

  @doc """
  Log scraping errors. Other changeset errors are supposed to be OK.
  """
  def log_changeset_errors({:ok, _struct}), do: :ok
  def log_changeset_errors({:error, changeset}) do
    repo_name = GithubRepo.fetch_name(changeset)
    case Enum.into(changeset.errors, %{}) do
      %{scraping_error: {"page_not_found", []}} -> :ok
      %{scraping_error: error} ->
        Logger.error "Scraping error for #{repo_name}: #{inspect(error)}"
      _otherwise -> :ok
    end
  end

  @doc """
  Clean the DB from repositories that failed to update properly in the last
  periodic loop.
  """
  def clean_dirty do
    Logger.info "Cleaning dirty repos..."
    query = from(r in GithubRepo, where: r.dirty)
    {num, _whatever} = Repo.delete_all(query)
    Logger.info "Cleaned #{num} dirty repos"
  end

  @doc """
  Update the total krihelimeter and num_of_repos for all languages.
  """
  def update_languages_stats() do
    Logger.info "Updating languages statistics..."
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

  def update_showcases() do
    maps = Periodic.GithubShowcases.scrape()
    for map <- maps do
      params = [name: map.name, href: map.href]
      {:ok, showcase} = Repo.get_or_create_by(Showcase, params)
      query = from(r in GithubRepo, where: r.name in ^map.repos)
      Repo.update_all(query, set: [showcase_id: showcase.id])
    end
  end
end
