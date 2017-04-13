defmodule Krihelinator.Repo do
  use Ecto.Repo, otp_app: :krihelinator

  @doc """
  Given a model and an keyword list get or create a row in the DB. Return
  signature is the same as Repo.insert.
  Note that the the keyword list passes through the model changeset.
  """
  def get_or_create_by(model, keywords) do
    case get_by(model, keywords) do
      nil ->
        model
        |> struct
        |> model.changeset(Enum.into(keywords, %{}))
        |> insert
      struct -> {:ok, struct}
    end
  end

  @doc """
  Update existing struct or create new one using data map. Return signature
  is the same as Repo.insert_or_update.
  Note that the the map passes through the model changeset.
  """
  def update_or_create_from_data(model, data, by: by) do
    model
    |> get_by([{by, Map.fetch!(data, by)}])
    |> case do
      :nil -> struct(model)
      struct -> struct
    end
    |> model.changeset(data)
    |> insert_or_update()
  end

end
