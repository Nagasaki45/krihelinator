defmodule RateLimiter do

  @moduledoc """
  Use me to rate limit calls to functions.
  """

  @doc """
  Similar to `Kernel.apply`, but with added limit rates argument, as
  used by [`ex_rated`](https://github.com/grempe/ex_rated).
  """
  def apply(module, function, args, {bucket, scale, limit}) do
    case ExRated.check_rate(bucket, scale, limit) do
      {:ok, _calls_made} ->
        apply(module, function, args)
      {:error, _calls_made} ->
        ExRated.inspect_bucket(bucket, scale, limit)
        |> elem(2)  # ms_to_next_bucket
        |> Process.sleep
        apply(module, function, args, {bucket, scale, limit})
      end
  end

end
