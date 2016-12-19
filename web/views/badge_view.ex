defmodule Krihelinator.BadgeView do
  use Krihelinator.Web, :view

  def render("error.json", _opts) do
    %{"error": "Failed to process badge"}
  end
end
