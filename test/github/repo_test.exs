defmodule Krihelinator.GithubRepoTest do
  use Krihelinator.ModelCase

  alias Krihelinator.Github.Repo

  @valid_attrs %{closed_issues: 42, commits: 42, merged_pull_requests: 42,
                 new_issues: 42, proposed_pull_requests: 42, authors: 42,
                 name: "some content"}

  test "changeset with valid attributes" do
    changeset = Repo.changeset(%Repo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "check krihelimeter in changes from params" do
    changeset = Repo.changeset(%Repo{}, @valid_attrs)
    assert Map.has_key?(changeset.changes, :krihelimeter)
  end

  test "check krihelimeter in changes from model" do
    model = Map.merge(%Repo{}, @valid_attrs)
    changeset = Repo.changeset(model, %{})
    assert Map.has_key?(changeset.changes, :krihelimeter)
  end

  test "unlimited description length" do
    description = String.duplicate("a", 257)
    changes = Map.put(@valid_attrs, :description, description)
    {:ok, model} =
      %Repo{}
      |> Repo.changeset(changes)
      |> Krihelinator.Repo.insert()
    assert model.description == description
  end
end
