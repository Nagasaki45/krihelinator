defmodule Krihelinator.LanguageHistoryTest do
  use Krihelinator.ModelCase

  alias Krihelinator.LanguageHistory

  @valid_attrs %{krihelimeter: 42, name: "some content", num_of_repos: 42,
                 timestamp: DateTime.utc_now()}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LanguageHistory.changeset(%LanguageHistory{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LanguageHistory.changeset(%LanguageHistory{}, @invalid_attrs)
    refute changeset.valid?
  end
end
