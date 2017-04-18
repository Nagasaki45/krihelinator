defmodule Krihelinator.ShowcaseTest do
  use Krihelinator.ModelCase

  alias Krihelinator.Github.Showcase

  @valid_attrs %{href: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Showcase.changeset(%Showcase{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Showcase.changeset(%Showcase{}, @invalid_attrs)
    refute changeset.valid?
  end
end
