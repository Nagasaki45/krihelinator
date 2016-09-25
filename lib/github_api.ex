defmodule GithubAPI do
  use HTTPoison.Base

  @moduledoc """
  Wrapper around HTTPoison.Base, that:

  1. Inject the access_token to the URL query string.
  2. Handle the `https://api.github.com`. Don't pass it!
  3. Parse the body to JSON.

  The code was copied from [here](https://github.com/edgurgel/httpoison).
  Note that there is no rate limiting!
  """

  def process_url(url) do
    token = Application.fetch_env!(:krihelinator, :github_token)
    seperator = if String.contains?(url, "?"), do: "&", else: "?"
    "https://api.github.com/#{url}#{seperator}access_token=#{token}"
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end

end
