defmodule Krihelinator.PageControllerTest do
  use Krihelinator.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Krihelinator"
  end

  test "Get repos of unexisting language. Bug #79", %{conn: conn} do
    conn = get conn, "/languages/moshe"
    assert html_response(conn, 404)
  end
end
