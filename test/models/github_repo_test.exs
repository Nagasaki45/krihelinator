defmodule Krihelinator.GithubRepoTest do
  use Krihelinator.ModelCase

  alias Krihelinator.GithubRepo

  @valid_attrs %{closed_issues: 42, commits: 42, merged_pull_requests: 42,
                 new_issues: 42, proposed_pull_requests: 42,
                 name: "some content"}

  test "changeset with valid attributes" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "check krihelimeter in changes from params" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @valid_attrs)
    assert Map.has_key?(changeset.changes, :krihelimeter)
  end

  test "check krihelimeter in changes from model" do
    model = Map.merge(%GithubRepo{}, @valid_attrs)
    changeset = GithubRepo.changeset(model, %{})
    assert Map.has_key?(changeset.changes, :krihelimeter)
  end
end
