defmodule Mix.Tasks.Krihelinator.Import do
  use Mix.Task
  import Mix.Ecto

  @moduledoc """
  Import data from a json file. It won't work if the DB is already populated.
  """

  @usage "Usage: mix krihelinator.import path/to/json/file"

  def run([filepath | args]) do
    if File.exists?(filepath) do
      import_data(filepath, args)
    else
      Mix.shell.error @usage
    end
  end

  def run(_) do
    Mix.shell.error @usage
  end

  def import_data(filepath, args) do
    content = File.read!(filepath)

    for repo <- parse_repo(args) do
      ensure_repo(repo, args)
      ensure_started(repo, [])

      Krihelinator.ImportExport.import_data(content, repo)
    end
  end
end
