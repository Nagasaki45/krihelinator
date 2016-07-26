alias Experimental.GenStage
alias Krihelinator.Pipeline

defmodule Krihelinator.Pipeline.Supervisor do
  use Supervisor

  @moduledoc """
  Supervisor for the background pipeline that is responsible for polling
  repositories from github, fetch their pulse statistics, and push them
  to the DB.
  """

  def start_link do
      Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Pipeline, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end


defmodule Krihelinator.Pipeline do

  @moduledoc """
  Until I find a better way to connect the pipeline I do it here.

  Here is how the pipeline looks like:
  ```
                                 StatsScraper
                              /      ...       \
  Poller -> PreScraperProcess -> StatsScraper -> PostScraperProcess -> Sink
                              \      ...       /
                                 StatsScraper
  ```
  """

  def start_link do
    Task.start_link(__MODULE__, :start_pipeline, [])
  end

  def start_pipeline do
    {:ok, poller} = GenStage.start_link(Pipeline.Poller, [])
    {:ok, pre_process} = GenStage.start_link(Pipeline.PreScraperProcess, [])
    {:ok, post_process} = GenStage.start_link(Pipeline.PostScraperProcess, [])
    {:ok, sink} = GenStage.start_link(Pipeline.DataHandler, [])

    GenStage.sync_subscribe(sink, to: post_process)
    for scraper <- create_scrapers() do
      GenStage.sync_subscribe(post_process, to: scraper)
      GenStage.sync_subscribe(scraper, to: pre_process)
    end
    GenStage.sync_subscribe(pre_process, to: poller)

    Process.sleep(:infinity)
  end

  def create_scrapers do
    for _n <- 1..Application.fetch_env!(:krihelinator, :scrapers_pool_size) do
      {:ok, scraper} = GenStage.start_link(Pipeline.StatsScraper, [])
      scraper
    end
  end
end
