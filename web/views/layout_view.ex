defmodule Krihelinator.LayoutView do
  use Krihelinator.Web, :view

  def production? do
    Mix.env == :prod
  end
end
