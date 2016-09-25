defmodule Krihelinator.Periodic do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.{Periodic, Pipeline, Repo, GithubRepo}
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
    Repo.update_all(GithubRepo, set: [trending: false])
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
    create_changesets()
    |> Stream.map(&api_only_updates_and_redirects/1)
    |> Stream.map(&scrape_pulse_page/1)
    |> Stream.map(&GithubRepo.finalize_changeset/1)
    |> Enum.each(&Repo.insert_or_update/1)
  end

  @doc """
  Instead of working on the repos directly, create changesets to manipulate.
  """
  def create_changesets() do
    existing = Stream.map(Repo.all(GithubRepo),
                          fn struct -> {struct, %{}} end)
    trending = Stream.map(Periodic.GithubTrending.scrape(),
                          fn params -> {%GithubRepo{}, params} end)
    all = Stream.concat(existing, trending)
    all
    |> Stream.map(
      fn {struct, params} -> GithubRepo.cast_allowed(struct, params) end
    )
    |> Stream.uniq(&fetch_name/1)
  end

  @doc """
  Some data is not available on the pulse page but available on the API.
  Get it and update the repo.
  """
  def api_only_updates_and_redirects(changeset) do
    repo_name = fetch_name(changeset)
    "repos/#{repo_name}"
    |> GithubAPI.limited_get
    |> handle_api_call(changeset)
  end

  @api_only_fields ~w(language description)a

  def handle_api_call({:ok, %{body: map, status_code: 200}}, changeset) do
    changes = for key <- @api_only_fields, into: %{} do
      {key, Map.get(map, Atom.to_string(key))}
    end
    Changeset.change(changeset, changes)
  end

  def handle_api_call(_otherwise, changeset) do
    Changeset.add_error(changeset, :api_error, "Unknown")
  end

  @doc """
  TODO A temporary solution, until I implement the Pipeline using
  changesets.
  """
  def scrape_pulse_page(changeset) do
    repo_name = fetch_name(changeset)
    changes = Pipeline.StatsScraper.scrape(%{name: repo_name})
    Changeset.change(changeset, changes)
  end

  def fetch_name(changeset) do
    {_data_or_change, repo_name} = Changeset.fetch_field(changeset, :name)
    repo_name
  end
end
