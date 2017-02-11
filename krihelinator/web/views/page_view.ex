defmodule Krihelinator.PageView do
  use Krihelinator.Web, :view

  @doc """
  Make this atom a bit nicer for presentation.
  """
  def nicier(atom) do
    atom
    |> Atom.to_string()
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

  @doc """
  Path to the language history page.
  """
  def language_history_path(conn, language) do
    page_path(conn, :languages_history) <> "?languages=[\"#{language}\"]"
  end
end
