defmodule Krihelinator.APIView do
  use Krihelinator.Web, :view

  def render("repositories.json", %{repos: repos}) do
    repos
    |> Stream.map(fn repo -> Map.delete(repo, :__meta__) end)
  end
end
