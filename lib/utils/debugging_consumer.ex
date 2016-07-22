alias Experimental.GenStage

defmodule DebuggingConsumer do
  use GenStage

  @moduledoc """
  GenStage for debugging porpuses. Use it as the final consumer.
  """

  def init([]) do
    {:consumer, :nil}
  end

  def handle_events(repos, _from, state) do
    for repo <- repos do
      Process.sleep(1000)
      IO.inspect(repo)
    end
    {:noreply, [], state}
  end
end
