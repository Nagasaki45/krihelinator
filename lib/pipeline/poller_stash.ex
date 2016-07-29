defmodule Krihelinator.Pipeline.PollerStash do

  @moduledoc """
  Keep the state of the poller in redis to allow it to fail and restore state
  automatically, even between deploys / restarts.
  """

  @initial_state "repositories"
  @key "poller_stash"

  def start_link do
    {:ok, client} = Exredis.start_link()
    true = Process.register(client, __MODULE__)
    {:ok, client}
  end

  def get do
    case Exredis.query(__MODULE__, ["GET", @key]) do
      :undefined ->
        Exredis.query __MODULE__, ["SET", @key, @initial_state]
        @initial_state
      otherwise ->
        otherwise
    end
  end

  def put(new_state) do
    Exredis.query __MODULE__, ["SET", "poller_stash", new_state]
  end
end
