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
    |> Enum.map(&parse_item/1)
    |> Enum.each(&Background.StatsScraper.process/1)
  end

  @doc """
  Parse single floki item repo to "name" and "description".
  """
  def parse_item(floki_item) do
    %{name: parse_name(floki_item),
      description: parse_description(floki_item)
    }
  end

  @doc """
  Parse the repo name (user/repo) from the repo floki item.
  """
  def parse_name(floki_item) do
    floki_item
    |> Floki.find(".repo-list-name a")
    |> Floki.attribute("href")
    |> hd
    |> String.trim_leading("/")
  end

  @doc """
  Parse the repo description from the floki item, or `:nil` if doesn't exist.
  """
  def parse_description(floki_item) do
    case Floki.find(floki_item, ".repo-list-description") do
      [] -> :nil
      [floki] -> floki |> Floki.text |> String.strip
    end
  end

end
