defmodule Krihelinator.InputValidator do

  @moduledoc """
  A general input validation module. Configurable functions to validate
  user input.
  """

  @doc """
  Validates a field against a list of valid values or using parsing function.
  """
  def verify_field(params, field, allowed, default) do
    case Map.get(params, field) do
      :nil -> {:ok, default}
      value ->
        if is_list(allowed) do
          verify_value(value, allowed)
        else
          allowed.(value)
        end
    end
  end

  defp verify_value(value, allowed) do
    if Enum.member?(allowed, value) do
      {:ok, String.to_existing_atom(value)}
    else
      {:error, "#{inspect(value)} is not a valid value"}
    end
  end

  ###### Krihelinator specific ######

  def verify_by(params) do
    allowed_by = ~w(krihelimeter num_of_repos name)
    allowed_dir = ~w(asc desc)
    with {:ok, by} <- verify_field(params, "by", allowed_by, :krihelimeter),
         {:ok, dir} <- verify_field(params, "dir", allowed_dir, :desc)
    do
      {:ok, by, dir}
    end
  end

  def verify_languages_list(languages) do
    if is_list(languages) do
      {:ok, languages}
    else
      {:error, "Languages are expected to be given in a list"}
    end
  end

  def nicer_poison_decode(json) do
    case Poison.decode(json) do
      {:error, _whatever} -> {:error, "Failed to decode json"}
      otherwise -> otherwise
    end
  end

  def validate_history_query(params) do
    allowed_values = ~w(krihelimeter num_of_repos)
    with {:ok, value_field} <-
           verify_field(params, "value", allowed_values, :krihelimeter),
         {:ok, languages} <-
           verify_field(params, "languages", &nicer_poison_decode/1, []),
         {:ok, languages} <-
           verify_languages_list(languages),
    do: {:ok, value_field, languages}
  end
end
