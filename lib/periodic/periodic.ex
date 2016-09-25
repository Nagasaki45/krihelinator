defmodule Krihelinator.Periodic do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.{Periodic, Repo, GithubRepo}
  import Krihelinator.Scraper, only: [scrape_repo_page: 1,
                                      scrape_pulse_page: 1]
  alias Ecto.Changeset

  @moduledoc """
  Every `:periodic_schedule` do the following:

  - Run the DB cleaner.
  - Scrape the github trending page for interesting, active, projects.
  - Pass all of the repos from the DB through the parser again, to update stats.
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
    Logger.info "Running DB cleaner..."
    clean_db()
    Logger.info "Scraping repos (trending + existing)..."
    rescrape()
    Logger.info "Periodic process finished successfully!"
    reschedule_work()
    {:noreply, state}
  end

  @doc """
  Schedule the next run in `:periodic_schedule` milliseconds.
  """
  def reschedule_work do
    Process.send_after(self(), :run, Application.fetch_env!(:krihelinator, :periodic_schedule))
  end

  @doc """
  Keep only the top :max_repos_to_keep in the DB. Delete the rest.
  """
  def clean_db do
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
  Rescrape existing repos plus new github trending repos.
  """
  def rescrape() do
    existing = Repo.all(GithubRepo)
    trending = Periodic.GithubTrending.scrape()
    new_trending = set_trendiness(existing, trending)
    existing = Repo.all(GithubRepo)  # Trendiness updated
    all = create_changesets(existing, new_trending)
    all
    |> Stream.map(changeset_updater_factory(&scrape_repo_page/1))
    |> Stream.map(changeset_updater_factory(&scrape_pulse_page/1))
    |> Stream.map(&GithubRepo.finalize_changeset/1)
    |> Enum.each(&Repo.insert_or_update/1)
  end

  @doc """
  Set trendiness of existing repos in the DB and return the remaining trending
  structs - those that weren't in `existing`.
  """
  def set_trendiness(existing, trending) do
    existing_names = for r <- existing, into: MapSet.new, do: r.name
    {existing_trending, new_trending} = Enum.partition(
      trending,
      fn repo -> MapSet.member?(existing_names, repo.name) end
    )
    existing_trending_names = for r <- existing_trending, do: r.name
    Repo.update_all(GithubRepo, set: [trending: false])
    query = from(r in GithubRepo, where: r.name in ^existing_trending_names)
    Repo.update_all(query, set: [trending: true])
    new_trending
  end

  @doc """
  Instead of working on the repos directly, create changesets to manipulate.
  """
  def create_changesets(existing, new_trending) do
    all = Stream.concat(
      Stream.map(existing, fn struct -> {struct, %{}} end),
      Stream.map(new_trending, fn params -> {%GithubRepo{}, params} end)
    )
    Stream.map(
      all,
      fn {struct, params} -> GithubRepo.cast_allowed(struct, params) end
    )
  end

  @doc """
  TODO A temporary solution, until the scraper will work with changesets
  directly.
  Build a function that scrape data and update the changeset.
  """
  def changeset_updater_factory(scraping_function) do
    fn changeset ->
      repo_name = fetch_name(changeset)
      changes = scraping_function.(repo_name)
      case changes do
        %{error: error} ->
          {repo_name, error} |> inspect |> Logger.debug
          Changeset.add_error(changeset, :error, inspect(error))
        _otherwise -> Changeset.change(changeset, changes)
      end
    end
  end

  def fetch_name(changeset) do
    {_data_or_change, repo_name} = Changeset.fetch_field(changeset, :name)
    repo_name
  end
end
