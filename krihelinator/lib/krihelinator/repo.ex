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
end
