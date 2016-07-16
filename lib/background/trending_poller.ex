defmodule Krihelinator.Background.TrendingPoller do
  use GenServer
  require Logger
  alias Krihelinator.Background

  @moduledoc """
  Every `:trending_poller_period`, scrape the github trending page for
  interesting, active, projects.
  """

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    schedule_work()
    {:ok, :nil}
  end

  def handle_info(:poll, state) do
    Logger.info "TrendingPoller kicked in!"
    poll()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :poll, Application.fetch_env!(:krihelinator, :trending_poller_period))
  end

  @doc """
  Poll the github trending page, send each project to the scrapers to process.
  """
  def poll do
    %{body: body, status_code: 200} = HTTPoison.get!("https://github.com/trending")
    Floki.parse(body)
    |> Floki.find(".repo-list-item")
    |> Enum.each(fn item ->
      item
      |> Floki.find(".repo-list-name a")
      |> Floki.attribute("href")
      |> hd
      |> String.trim_leading("/")
      |> Background.StatsScraper.process
    end)
  end

end
