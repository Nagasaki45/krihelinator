defmodule Krihelinator.LanguageTest do
  use Krihelinator.ModelCase

  alias Krihelinator.Github.Language

  @valid_attrs %{krihelimeter: 42, name: "some content"}
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
