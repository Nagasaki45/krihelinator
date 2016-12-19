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
end
