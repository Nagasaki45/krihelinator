defmodule Krihelinator.GithubRepo do
  use Krihelinator.Web, :model
  alias Krihelinator.{Repo, Language}

  @moduledoc """
  Ecto model of a repository on github.
  """

  schema "repos" do
    field :name, :string
    field :description, :string
    field :language_name, :string, virtual: true
    belongs_to :language, Krihelinator.Language
    belongs_to :showcase, Krihelinator.Showcase
    field :merged_pull_requests, :integer
    field :proposed_pull_requests, :integer
    field :closed_issues, :integer
    field :new_issues, :integer
    field :commits, :integer
    field :authors, :integer
    field :forks, :integer
    field :krihelimeter, :integer
    field :trending, :boolean, default: false
    field :user_requested, :boolean, default: false
    field :dirty, :boolean, default: false

    timestamps()
  end

  @allowed ~w(name description language_name merged_pull_requests
              proposed_pull_requests closed_issues new_issues commits authors
              forks trending user_requested dirty)a
  @required ~w(name merged_pull_requests proposed_pull_requests
               closed_issues new_issues commits authors)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast_allowed(params)
    |> finalize_changeset
  end

  @doc """
  Create basic changeset from struct and params.
  """
  def cast_allowed(struct, params \\ %{}) do
    cast(struct, params, @allowed)
  end

  @doc """
  Run all validations and set calculated fields on a changeset.
  """
  def finalize_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_number(:merged_pull_requests, greater_than_or_equal_to: 0)
    |> validate_number(:proposed_pull_requests, greater_than_or_equal_to: 0)
    |> validate_number(:closed_issues, greater_than_or_equal_to: 0)
    |> validate_number(:new_issues, greater_than_or_equal_to: 0)
    |> validate_number(:commits, greater_than_or_equal_to: 0)
    |> validate_number(:authors, greater_than_or_equal_to: 0)
    |> validate_number(:forks, greater_than_or_equal_to: 0)
    |> unique_constraint(:name)
    |> set_krihelimeter
    |> put_language_assoc()
    |> clear_dirty_bit()
  end

  @doc """
  Use the existing data, and the expected changes, to calculate and set the
  krihelimeter.
  """
  def set_krihelimeter(%{valid?: false} = changeset) do
    changeset
  end

  def set_krihelimeter(%{data: data, changes: changes} = changeset) do
    new_data = Map.merge(data, changes)
    put_change(changeset, :krihelimeter, Krihelimeter.calculate(new_data))
  end

  def put_language_assoc(%{changes: %{language_name: lang}} = changeset) do
    {:ok, language} = Repo.get_or_create_by(Language, name: lang)
    changeset
    |> put_change(:language_id, language.id)
  end
  def put_language_assoc(changeset) do
    changeset
  end

  def clear_dirty_bit(changeset) do
    put_change(changeset, :dirty, false)
  end
end
