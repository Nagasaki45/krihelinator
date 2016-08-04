defmodule Krihelinator.Periodic do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Krihelinator.{Periodic, Pipeline, Repo, GithubRepo}

  @moduledoc """
  Every `:periodic_schedule` do the following:

  - Scrape the github trending page for interesting, active, projects.
  - Run the DB cleaner.
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
    Stream.concat(scrape_trending(), existing_repos_to_scrape())
    |> Stream.uniq(fn repo -> repo.name end)
    |> Stream.map(&Pipeline.StatsScraper.scrape/1)
    |> Enum.each(&handle_scraped/1)
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
  Scrape the github trending page and return stream of repos to scrape.
  """
  def scrape_trending do
    Repo.update_all(GithubRepo, set: [trending: false])

    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    body
    |> Periodic.TrendingParser.parse
    |> Stream.map(fn repo -> Map.put(repo, :trending, true) end)
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
      from(r in non_user_requested, where: r.krihelimeter < ^threshold)
      |> Repo.delete_all
    end
  end

  def existing_repos_to_scrape do
    GithubRepo
    |> Repo.all
    |> Stream.map(&Map.from_struct/1)
  end

  @doc """
  Decide what to do with the scraped data. Specific errors might trigger save,
  other deletes, or ignores.
  """
  def handle_scraped(%{error: :nil}=repo) do
    Pipeline.DataHandler.save_to_db(repo)
  end

  def handle_scraped(%{error: :timeout}=repo) do
    Logger.info "Scraping #{repo.name} timed out. No stats updated"
  end

  def handle_scraped(%{error: error}=repo) do
    Logger.info "Failed to scrape #{repo.name} due to #{error}. Deleting!"
    (from r in GithubRepo, where: r.name == ^repo.name)
    |> Repo.delete_all
  end
end
