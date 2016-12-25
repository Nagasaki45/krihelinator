defmodule Krihelinator do
  use Application
  require Logger

  @moduledoc """
  The Krihelinator OTP application. Everything starts from here.
  """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Krihelinator.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Krihelinator.Endpoint, []),
      # Start the background periodic process
      worker(Krihelinator.Periodic, []),
      # Start the background history keeper process
      worker(Krihelinator.HistoryKeeper, []),
      # Start the python GenServer
      worker(Krihelinator.PythonGenServer, []),
    ]

    children =
      if Application.fetch_env!(:krihelinator, :pipeline_disabled) do
        Logger.info "The pipeline process is disabled"
        children
      else
        # Start the background polling pipeline
        children ++ [supervisor(Krihelinator.Pipeline.Supervisor, [])]
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Krihelinator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Krihelinator.Endpoint.config_change(changed, removed)
    :ok
  end
end
