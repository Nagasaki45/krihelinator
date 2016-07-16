defmodule Krihelinator.Background.Supervisor do
  use Supervisor
  alias Krihelinator.Background

  @moduledoc """
  Supervisor for the background system that is responsible for polling
  repositories from github, fetch their pulse statistics, and push it
  to the DB.
  """

  def start_link do
      Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    scrapers_poolboy_config = [
      name: {:local, :scrapers_pool},
      worker_module: Krihelinator.Background.StatsScraper,
      size: Application.fetch_env!(:krihelinator, :scrapers_pool_size),
    ]

    children = [
      worker(Background.PollerStash, []),
      worker(Background.Poller, []),
      :poolboy.child_spec(:scrapers_pool, scrapers_poolboy_config, []),
      worker(Background.DataHandler, []),
      worker(Background.DBCleaner, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
