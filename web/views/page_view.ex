defmodule Krihelinator.PageView do
  use Krihelinator.Web, :view

  @doc """
  Make this string a bit nicer for presentation.
  """
  def nicier(string) do
    string
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
