defmodule Krihelinator.PageControllerTest do
  use Krihelinator.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "The Krihelinator"
  end
end
