defmodule Krihelinator.LanguageHistory do
  use Krihelinator.Web, :model

  @moduledoc """
  Keep a point in time for the language statistics. Used for visualizing
  language trends.
  """

  @derive {Poison.Encoder, only: ~w(id language_id krihelimeter timestamp)a}
  schema "languages_history" do
    field :name, :string
    belongs_to :language, Krihelinator.Language
    field :krihelimeter, :integer
    field :timestamp, :utc_datetime
  end

  @allowed_and_required ~w(krihelimeter timestamp)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_and_required)
    |> validate_required(@allowed_and_required)
  end
end
