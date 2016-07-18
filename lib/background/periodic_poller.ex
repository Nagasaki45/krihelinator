defmodule Krihelinator.Background.PeriodicPoller do
  use GenServer
  require Logger
  alias Krihelinator.Background
  alias Krihelinator.Repo
  alias Krihelinator.GithubRepo

  @moduledoc """
  Every `:periodic_poller_period`, scrape the github trending page for
  interesting, active, projects. Then pass all of the repos from the DB through
  the parser again, to update stats.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    schedule_work()
    {:ok, :nil}
  end

  def handle_info(:poll, state) do
    Logger.info "PeriodicPoller kicked in!"
    scrape_trending()
    poll_self()
    schedule_work()
    Logger.info "PeriodicPoller finished successfully!"
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :poll, Application.fetch_env!(:krihelinator, :periodic_poller_period))
  end

  @doc """
  Scrape the github trending page, send each project to the scrapers to process.
  """
  def scrape_trending do
    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    body
    |> Background.TrendingParser.parse
    |> Enum.each(&Background.StatsScraper.process/1)
  end

  def poll_self do
    for repo <- Repo.all(GithubRepo) do
      repo
      |> Map.from_struct
      |> Background.StatsScraper.process
    end
  end
end
