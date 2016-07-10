defmodule Krihelinator.Background.DBCleaner do
  use GenServer
  import Ecto.Query
  require Logger
  alias Krihelinator.Repo
  alias Krihelinator.GithubRepo
  alias Krihelinator.Krihelimeter

  # Copied from http://stackoverflow.com/a/32097971/1224456
  # TODO make it work!

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    schedule_work()
    {:ok, :nil}
  end

  @max_repos_to_keep Application.fetch_env!(:krihelinator, :max_repos_to_keep)

  def handle_info(:clean_db, state) do
    Logger.info "DBCleaner kicked in!"
    count = Repo.one(from r in GithubRepo, select: count(r.id))
    if count > @max_repos_to_keep do
      clean_db()
      update_threshold()
    end
    schedule_work()
    {:noreply, state}
  end

  @period Application.fetch_env!(:krihelinator, :db_cleaner_period)

  defp schedule_work do
    Process.send_after(self(), :clean_db, @period)
  end

  def clean_db do
    Repo.all(GithubRepo)
    |> Enum.sort_by(&Krihelimeter.calculate/1, &>=/2)  # Descending
    |> Enum.drop(@max_repos_to_keep)
    |> Enum.each(&Repo.delete!/1)
  end

  def update_threshold do
    Krihelinator.Repo.all(Krihelinator.GithubRepo)
    |> Enum.sort_by(&Krihelinator.Krihelimeter.calculate/1)
    |> hd
    |> Krihelinator.Krihelimeter.calculate
    |> Krihelinator.Background.DataHandler.set_threshold
  end
end
