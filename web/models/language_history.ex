defmodule Krihelinator.LanguageHistory do
  use Krihelinator.Web, :model

  @moduledoc """
  Keep a point in time for the language statistics. Used for visualizing
  language trends.
  """

  schema "languages_history" do
    field :name, :string
    belongs_to :language, Krihelinator.Language
    field :krihelimeter, :integer
    field :num_of_repos, :integer
    field :timestamp, :utc_datetime
  end

  @allowed ~w(krihelimeter num_of_repos timestamp)a
  @required ~w(krihelimeter timestamp)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed)
    |> validate_required(@required)
  end
end
