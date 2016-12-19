defmodule Krihelinator.LanguageHistory do
  use Krihelinator.Web, :model

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
    |> cast(params, [:name, :krihelimeter, :num_of_repos, :timestamp])
    |> validate_required([:name, :krihelimeter, :num_of_repos, :timestamp])
  end
end
