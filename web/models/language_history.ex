defmodule Krihelinator.LanguageHistory do
  use Krihelinator.Web, :model

  @moduledoc """
  Keep a point in time for the language statistics. Used for visualizing
  language trends.
  """

  schema "languages_history" do
    field :name, :string
    field :krihelimeter, :integer
    field :num_of_repos, :integer
    field :timestamp, :utc_datetime
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :krihelimeter, :num_of_repos])
    |> validate_required([:name, :krihelimeter, :num_of_repos])
    |> put_change(:timestamp, DateTime.utc_now())
  end

  @doc """
  Returns a map with only one stat (krihelimeter / num_of_repos) as :value.
  """
  def choose_stat_field(datum, stat_field) when is_binary(stat_field) do
    stat_field = String.to_existing_atom(stat_field)
    choose_stat_field(datum, stat_field)
  end
  def choose_stat_field(datum, stat_field) do
    value = Map.fetch!(datum, stat_field)
    datum
    |> Map.from_struct
    |> Map.drop([:krihelimeter, :num_of_repos])
    |> Map.put(:value, value)
  end
end
