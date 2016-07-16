defmodule Krihelinator.GithubRepo do
  use Krihelinator.Web, :model

  schema "repos" do
    field :name, :string
    field :description, :string
    field :merged_pull_requests, :integer
    field :proposed_pull_requests, :integer
    field :closed_issues, :integer
    field :new_issues, :integer
    field :commits, :integer
    field :krihelimeter, :integer

    timestamps()
  end

  @allowed ~w(name description merged_pull_requests proposed_pull_requests
              closed_issues new_issues commits)a
  @required ~w(name merged_pull_requests proposed_pull_requests
               closed_issues new_issues commits)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> set_krihelimeter
  end

  @doc """
  Use the existing data, and the expected changes, to calculate and set the
  krihelimeter.
  """
  def set_krihelimeter(%{data: data, changes: changes}=changeset) do
    new_data = Map.merge(data, changes)
    put_change(changeset, :krihelimeter, Krihelimeter.calculate(new_data))
  end
end
