defmodule SpawnViewer.PageControllerTest do
  use SpawnViewer.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Spawn Viewer"
  end
end
