defmodule Krihelinator.LanguageHistoryTest do
  use Krihelinator.ModelCase

  alias Krihelinator.History.Language

  @valid_attrs %{krihelimeter: 42, timestamp: DateTime.utc_now()}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Language.changeset(%Language{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Language.changeset(%Language{}, @invalid_attrs)
    refute changeset.valid?
  end
end
