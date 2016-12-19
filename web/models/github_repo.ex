defmodule Krihelinator.GithubRepo do
  use Krihelinator.Web, :model
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Ecto model of a repository on github.
  """

  schema "repos" do
    field :name, :string
    field :description, :string
    field :language, :string
    field :merged_pull_requests, :integer
    field :proposed_pull_requests, :integer
    field :closed_issues, :integer
    field :new_issues, :integer
    field :commits, :integer
    field :authors, :integer
    field :krihelimeter, :integer
    field :trending, :boolean, default: false
    field :user_requested, :boolean, default: false

    timestamps()
  end

  @allowed ~w(name description language merged_pull_requests
              proposed_pull_requests closed_issues new_issues commits authors
              trending user_requested)a
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
  def cast_allowed(struct, params) do
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
    |> unique_constraint(:name)
    |> set_krihelimeter
    |> trim_description(max_length: 255)
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

  @doc """
  Trim the description string to `max_length` chars.
  """
  def trim_description(%{changes: %{description: description}} = changeset,
                       max_length: max_length)
                       when is_binary(description) do
    description = if String.length(description) > max_length do
      String.slice(description, 0, 255 - 1 - 3) <> "..."
    else
      description
    end
    put_change(changeset, :description, description)
  end

  def trim_description(changeset, _opts) do
    changeset
  end

  @doc """
  Get the repo name from the changeset
  """
  def fetch_name(changeset) do
    changeset
    |> Ecto.Changeset.fetch_field(:name)
    |> elem(1)  # {data_or_changes, value}
  end

  @doc """
  For querying all languages.
  """
  def languages_query() do
    from(r in __MODULE__,
         group_by: r.language,
         select: %{name: r.language,
                   krihelimeter: sum(r.krihelimeter),
                   num_of_repos: count(r.id)},
         order_by: [desc: sum(r.krihelimeter)],
         where: not(is_nil(r.language)))
  end
end
