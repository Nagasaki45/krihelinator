defmodule InputValidator do

  @moduledoc """
  A general input validation module. Configurable functions to validate
  user input.
  """

  def verify_field(params, field, allowed, default) do
    case Map.get(params, field) do
      :nil -> {:ok, default}
      value ->
        value
        |> verify_value(allowed)
    end
  end

  defp verify_value(value, allowed) do
    if Enum.member?(allowed, value) do
      {:ok, String.to_existing_atom(value)}
    else
      {:error, value}
    end
  end

  def verify_by(params) do
    allowed_by = ~w(krihelimeter num_of_repos name)
    allowed_dir = ~w(asc desc)
    with {:ok, by} <- verify_field(params, "by", allowed_by, :krihelimeter),
         {:ok, dir} <- verify_field(params, "dir", allowed_dir, :desc)
    do
      {:ok, by, dir}
    end
  end
end
