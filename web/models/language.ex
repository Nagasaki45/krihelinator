defmodule Krihelinator.Language do
  use Krihelinator.Web, :model

  @moduledoc """
  A programming language found on Github.
  """

  @derive {Poison.Encoder, only: ~w(id name krihelimeter)a}
  schema "languages" do
    field :name, :string
    field :krihelimeter, :integer
    field :num_of_repos, :integer
    has_many :repos, Krihelinator.GithubRepo
    has_many :history, Krihelinator.LanguageHistory

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :krihelimeter, :num_of_repos])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
