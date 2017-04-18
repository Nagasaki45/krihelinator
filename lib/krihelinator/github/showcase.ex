defmodule Krihelinator.Github.Showcase do
  use Krihelinator.Web, :model

  @moduledoc """
  Github's showcase category.
  """

  @derive {Poison.Encoder, only: ~w(id name href description)a}
  schema "showcases" do
    field :name, :string
    field :href, :string
    field :description, :string
    has_many :repos, Krihelinator.Github.Repo

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :href, :description])
    |> validate_required([:name, :href])
  end
end
