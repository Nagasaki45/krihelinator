defmodule Krihelinator.Background.DBCleaner do
  use GenServer
  require Logger

  # Copied from http://stackoverflow.com/a/32097971/1224456

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init do
    schedule_work()
    {:ok, :nil}
  end

  def handle_info(:clean_db, state) do
    clean_db()
    schedule_work()
    {:noreply, state}
  end

  @period Application.fetch_env!(:krihelinator, :db_cleaner_period)

  defp schedule_work do
    Process.send_after(self(), :clean_db, @period)
  end

  def clean_db do
    Logger.info "DBCleaner kicked in!"
  end
end
