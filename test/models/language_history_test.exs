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

  test "choose_stat_field set the value" do
    struct = %LanguageHistory{name: "Elixir", timestamp: DateTime.utc_now(),
                              krihelimeter: 1000, num_of_repos: 10}
    map = LanguageHistory.choose_stat_field(struct, :krihelimeter)
    assert map.value == 1000
    map = LanguageHistory.choose_stat_field(struct, :num_of_repos)
    assert map.value == 10
  end

  test "choose_stat_field drop the stat fields" do
    struct = %LanguageHistory{name: "Elixir", timestamp: DateTime.utc_now(),
                              krihelimeter: 1000, num_of_repos: 10}
    map = LanguageHistory.choose_stat_field(struct, :krihelimeter)
    refute Map.has_key?(map, :krihelimeter)
    refute Map.has_key?(map, :num_of_repos)
  end

  test "choose_stat_field accepts strings" do
    struct = %LanguageHistory{name: "Elixir", timestamp: DateTime.utc_now(),
                              krihelimeter: 1000, num_of_repos: 10}
    map = LanguageHistory.choose_stat_field(struct, "krihelimeter")
    assert Map.has_key?(map, :value)
  end

end
