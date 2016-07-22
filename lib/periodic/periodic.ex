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
    schedule_work()
    {:ok, :nil}
  end

  def handle_info(:run, state) do
    Logger.info "Periodic process kicked in!"
    Logger.info "Scraping trending..."
    scrape_trending()
    Logger.info "Running DB cleaner..."
    clean_db()
    Logger.info "Re-analysing existing repos..."
    reanalyse_existing_repos()
    Logger.info "Periodic process finished successfully!"
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :run, Application.fetch_env!(:krihelinator, :periodic_schedule))
  end

  @doc """
  Scrape the github trending page, scrape the pulse page for each project and
  persist.
  """
  def scrape_trending do
    Repo.update_all(GithubRepo, set: [trending: false])

    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    body
    |> Periodic.TrendingParser.parse
    |> Stream.map(fn repo -> Map.put(repo, :trending, true) end)
    |> scrape_and_persist_repos
  end

  @doc """
  Re-analyse each project in the DB.
  """
  def reanalyse_existing_repos do
    Repo.all(GithubRepo)
    |> Stream.map(&Map.from_struct/1)
    |> scrape_and_persist_repos
  end

  @doc """
  Keep only the top :max_repos_to_keep in the DB. Delete the rest.
  """
  def clean_db do
    count = Repo.one(from r in GithubRepo, select: count(r.id))
    keep = Application.fetch_env!(:krihelinator, :max_repos_to_keep)
    if count > keep do
      Logger.info "There are #{count} repos in the DB, keeping only #{keep}"
      (from GithubRepo, order_by: [desc: :krihelimeter], limit: 50)
      |> Repo.all
      |> Enum.drop(keep)
      |> Enum.each(&Repo.delete!/1)
    end
  end

  @doc """
  Helper to stream repos through `Pipeline.StatsScraper` -> `Pipeline.DataHandler`.
  """
  def scrape_and_persist_repos(repos) do
    repos
    |> Stream.map(&Pipeline.StatsScraper.scrape/1)
    |> Stream.filter(fn repo -> repo != :error end)
    |> Enum.each(&Pipeline.DataHandler.save_to_db/1)
  end
end
