defmodule Krihelinator.Github.Language do
  use Krihelinator.Web, :model

  @moduledoc """
  A programming language found on Github.
  """

  @derive {Poison.Encoder, only: ~w(id name krihelimeter)a}
  schema "languages" do
    field :name, :string
    field :krihelimeter, :integer
    has_many :repos, Krihelinator.Github.Repo
    has_many :history, Krihelinator.History.Language

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :krihelimeter])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
