defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
