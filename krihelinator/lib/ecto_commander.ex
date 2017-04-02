defmodule Krihelinator.EctoCommander do

  @moduledoc """
  A helper module to run ecto commands, similar to mix ecto.create and
  mix ecto.migrate, in production, without mix.
  """

  @start_apps [
    :postgrex,
    :ecto
  ]

  def migrate() do
    wrap(fn ->
      IO.puts "Running migrations..."
      Ecto.Migrator.run(Krihelinator.Repo, migrations_path(), :up, all: true)
    end)
  end

  def create() do
    wrap(fn ->
      IO.puts "Creating the DB..."
      config = Krihelinator.Repo.config
      adapter = Keyword.get(config, :adapter)
      adapter.storage_up(config)
    end)
  end

  defp wrap(function) do
    IO.puts "Loading krihelinator.."
    # Load the code for myapp, but don't start it
    :ok = Application.load(:krihelinator)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo for krihelinator
    IO.puts "Starting repo.."
    Krihelinator.Repo.start_link(pool_size: 1)

    function.()

    IO.puts "Success!"
    :init.stop()
  end

  defp priv_dir() do
    "#{:code.priv_dir(:krihelinator)}"
  end

  defp migrations_path() do
    Path.join([priv_dir(), "repo", "migrations"])
  end

end
