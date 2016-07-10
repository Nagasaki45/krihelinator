defmodule Krihelinator.PageView do
  use Krihelinator.Web, :view

  def krihelimeter(repo) do
    Krihelinator.Krihelimeter.calculate(repo)
  end
end
