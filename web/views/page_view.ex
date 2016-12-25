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

  @doc """
  Takes a repo name and split and bold it like the repo names in github
  trending.
  """
  def split_and_bold(string) do
    [prefix, suffix] = String.split(string, "/")
    {:safe, "#{prefix} / <b>#{suffix}</b>"}
  end
end
