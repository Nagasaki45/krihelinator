defmodule Krihelinator.GithubRepo do
  use Krihelinator.Web, :model

  schema "repos" do
    field :user, :string
    field :repo, :string
    field :merged_pull_requests, :integer
    field :proposed_pull_requests, :integer
    field :closed_issues, :integer
    field :new_issues, :integer
    field :commits, :integer

    timestamps()
  end

  @required_params ~w(user repo merged_pull_requests proposed_pull_requests
                      closed_issues new_issues commits)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ :empty) do
    struct
    |> cast(params, @required_params, [])
    |> unique_constraint(:whatever, name: :user_repo)
  end
end
