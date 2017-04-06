defmodule Krihelinator.LayoutView do
  use Krihelinator.Web, :view

  def navbar_link(assigns) do
    render "navbar_link.html", assigns
  end

  def page_title(assigns) do
    case action_name(assigns.conn) do
      :languages -> "Languages | the Krihelinator"
      :about -> "About | the Krihelinator"
      :language -> "#{assigns.language.name} | the Krihelinator"
      :languages_history -> "Languages history | the Krihelinator"
      :showcases -> "Showcases | the Krihelinator"
      :showcase -> "#{assigns.showcase.name} | the Krihelinator"
      _whatever -> "the Krihelinator"
    end
  end
end
