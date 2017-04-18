defmodule Krihelinator.DataController do
  use Krihelinator.Web, :controller

  def all(conn, _params) do
    data = Krihelinator.ImportExport.export_krihelinator_data()

    now = DateTime.utc_now()
    format = "dump_%Y-%m-%d_%H_%M_%S.json"
    {:ok, filename} = Timex.format(now, format, :strftime)

    conn
    |> put_resp_content_type("text/json")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_resp(200, data)
  end
end
