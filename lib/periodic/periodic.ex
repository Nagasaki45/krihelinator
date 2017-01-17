defmodule Krihelinator.Periodic do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.{Periodic, Repo, GithubRepo, Language}

  @moduledoc """
  Every `:periodic_schedule` do the following:

  - Run the DB cleaner.
  - Scrape the github trending page for interesting, active, projects.
  - Pass all of the repos from the DB through the parser again, to update stats.
  - Update the total krihelimeter and num_of_repos for all languages.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    reschedule_work()
    {:ok, :nil}
  end

  def handle_info(:run, state) do
    Logger.info "Periodic process kicked in!"
    clean_db()
    scrape_trending()
    rescrape_existing()
    delete_repos_with_less_than_two_authors()
    update_languages_stats()
    Logger.info "Periodic process finished successfully!"
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
  Keep only the top :max_repos_to_keep in the DB. Delete the rest.
  """
  def clean_db do
    Logger.info "Running DB cleaner..."
    non_user_requested = from(r in GithubRepo, where: not r.user_requested)
    count = Repo.one(from r in non_user_requested, select: count(r.id))
    keep = Application.fetch_env!(:krihelinator, :max_repos_to_keep)
    if count > keep do
      threshold = Repo.one(from r in non_user_requested,
                           order_by: [desc: r.krihelimeter],
                           offset: ^keep,
                           limit: 1,
                           select: r.krihelimeter)
      ["There are #{count} repos (excluding user requested) in the DB",
       "keeping only #{keep}",
       "new minimum krihelimeter is #{threshold}"]
      |> Enum.join(", ")
      |> Logger.info
      query = from(r in non_user_requested, where: r.krihelimeter < ^threshold)
      Repo.delete_all(query)
    end
  end

  @doc """
  Scrape the github trending page and put all to DB (update if already exists).
  """
  def scrape_trending() do
    Logger.info "Scraping trending..."
    Periodic.GithubTrending.scrape()
    |> Stream.map(fn params -> GithubRepo.cast_allowed(%GithubRepo{}, params) end)
    |> Stream.map(&scrape_repo/1)
    |> Stream.map(&update_trendiness/1)  # Effects only name uniqueness failures
    |> Enum.each(&log_changeset_errors/1)
  end

  def rescrape_existing() do
    Logger.info "Rescraping existing (non trending)..."
    query = from(r in GithubRepo, where: not r.trending)
    query
    |> Repo.all()
    |> Stream.map(fn struct -> GithubRepo.cast_allowed(struct) end)
    |> Stream.map(&scrape_repo/1)
    |> Enum.each(&log_changeset_errors/1)
  end

  @doc """
  Repos can't enter the Krihelinator with less than 2 authors, but they can
  become such repos later, which are problematic. See issue #94.
  """
  def delete_repos_with_less_than_two_authors() do
    Logger.info "Deleting repositories with less than two authors..."
    query = from(r in GithubRepo, where: not r.user_requested,
                                  where: r.authors < 2)
    Repo.delete_all(query)
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

  @doc """
  Scrape changeset and insert to DB.
  """
  def scrape_repo(changeset) do
    changeset
    |> Krihelinator.Scraper.scrape_repo_page()
    |> Krihelinator.Scraper.scrape_pulse_page()
    |> GithubRepo.finalize_changeset()
    |> Repo.insert_or_update()
  end

  @doc """
  The repo is already in the DB, update it to be trending.
  """
  def update_trendiness({:error, %{errors: [name: _]} = changeset}) do
    repo_name = GithubRepo.fetch_name(changeset)
    GithubRepo
    |> Repo.get_by(name: repo_name)
    |> GithubRepo.changeset()
    |> Ecto.Changeset.put_change(:trending, true)
    |> Repo.update()
  end
  def update_trendiness(everything_else), do: everything_else

  @doc """
  Log why the insertion of the changeset to the DB failed.
  """
  def log_changeset_errors({:ok, _struct}), do: :ok
  def log_changeset_errors({:error, changeset}) do
    repo_name = GithubRepo.fetch_name(changeset)
    errors = inspect changeset.errors
    msg = "Failed to insert changeset for #{repo_name}: #{errors}"
    Logger.error msg
  end
end
