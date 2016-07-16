defmodule Krihelinator.Background.PollerStash do

  @moduledoc """
  Keep the state of the poller to allow it to fail and restore state
  automatically.
  """
  def start_link do
    Agent.start_link(fn -> "repositories" end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def put(new_state) do
    Agent.update(__MODULE__, fn _old_state -> new_state end)
  end
end
