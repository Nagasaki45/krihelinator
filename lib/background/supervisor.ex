defmodule Krihelinator.Background.Supervisor do
  use Supervisor
  alias Krihelinator.Background

  @moduledoc """
  Supervisor for the background system that responsible for polling
  repositories from github, fetch their pulse statistics, and push it
  to the DB.
  """

  def start_link do
      Supervisor.start_link(__MODULE__, [])
    end

    def init([]) do
      children = [
        worker(Background.Poller, []),
        worker(Background.DataHandler, []),
        worker(Background.DBCleaner, []),
      ]
      supervise(children, strategy: :one_for_one)
    end
end
