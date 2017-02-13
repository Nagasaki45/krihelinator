defmodule Krihelinator.LayoutView do
  use Krihelinator.Web, :view

  def in_production() do
    Mix.env == :prod
  end

  def navbar_link(assigns) do
    render "navbar_link.html", assigns
  end

  def page_title(assigns) do
    case action_name(assigns.conn) do
      :languages -> "Krihelinator/languages"
      :badge -> "Krihelinator/badges"
      :about -> "Krihelinator/about"
      :language -> "Krihelinator/#{assigns.language.name}"
      :languages_history -> "Krihelinator/history"
      _whatever -> "the Krihelinator"
    end
  end
end
