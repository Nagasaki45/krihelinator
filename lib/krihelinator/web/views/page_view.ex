defmodule Krihelinator.PageView do
  use Krihelinator.Web, :view

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
    language = URI.encode_www_form(language)
    page_path(conn, :languages_history) <> "?languages=[\"#{language}\"]"
  end
end
