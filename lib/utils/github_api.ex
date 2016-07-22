defmodule GithubAPI do
  use HTTPoison.Base

  @moduledoc """
  Wrapper around HTTPoison.Base, that:

  1. Honor the github API rate limits on get calls.
  2. Inject the access_token to the URL query string.
  3. Handle the `https://api.github.com`. Don't pass it!
  4. Parse the body to JSON.

  The code was copied from [here](https://github.com/edgurgel/httpoison).
  """

  # Bucket is valid 5000 requests, for 1 hour, in miliseconds.
  @rate_limit {"github_api", 60 * 60 * 1000, 5000}

  @doc """
  A get call that honor the github rate limits, using
  [ex_rated](https://github.com/grempe/ex_rated).
  """
  def limited_get(url) do
    RateLimiter.apply(__MODULE__, :get, [url], @rate_limit)
  end

  def process_url(url) do
    token = Application.fetch_env!(:krihelinator, :github_token)
    seperator = if String.contains?(url, "?"), do: "&", else: "?"
    "https://api.github.com/#{url}#{seperator}access_token=#{token}"
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end

end
