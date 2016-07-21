defmodule Krihelinator.Background.PollerStash do

  @moduledoc """
  Keep the state of the poller in redis to allow it to fail and restore state
  automatically, even between deploys / restarts.
  """

  @initial_state "repositories"
  @key "poller_stash"

  def get do
    {:ok, client} = Exredis.start_link
    case Exredis.query(client, ["GET", @key]) do
      :undefined ->
        Exredis.query client, ["SET", @key, @initial_state]
        @initial_state
      otherwise ->
        otherwise
    end
  end

  def put(new_state) do
    {:ok, client} = Exredis.start_link
    Exredis.query client, ["SET", "poller_stash", new_state]
  end
end
