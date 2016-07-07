defmodule Krihelinator.GithubRepoTest do
  use Krihelinator.ModelCase

  alias Krihelinator.GithubRepo

  @valid_attrs %{closed_issues: 42, commits: 42, merged_pull_requests: 42, new_issues: 42, proposed_pull_requests: 42, repo: "some content", user: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @invalid_attrs)
    refute changeset.valid?
  end
end
