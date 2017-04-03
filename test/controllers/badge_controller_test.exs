defmodule Krihelinator.BadgeControllerTest do
  use Krihelinator.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/badge/nAgAsAkI45/krihelinator"
    assert response(conn, 200)
  end

end
