defmodule Krihelinator.LayoutView do
  use Krihelinator.Web, :view

  def production? do
    Mix.env == :prod
  end

  def navbar_link(assigns) do
    render "navbar_link.html", assigns
  end
end
