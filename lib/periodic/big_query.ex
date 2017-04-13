defmodule Krihelinator.Periodic.BigQuery do
  require Logger

  @moduledoc """
  Issue pre-configured queries against google BigQuery and (partly) process
  the results.
  """

  def query() do
    {start_date, end_date} = get_start_and_end_dates()
    {:ok, %{jobComplete: true, rows: rows}} = run_query(start_date, end_date)
    Logger.info "Got #{length(rows)} active repos between #{start_date} and #{end_date} from BigQuery"
    process_rows(rows)
  end

  defp get_start_and_end_dates() do
    end_date = Date.utc_today()
    start_date = Timex.shift(end_date, days: -7)
    {Date.to_string(start_date), Date.to_string(end_date)}
  end

  defp run_query(start_date, end_date) do
    query_string = "SELECT name, COUNT(DISTINCT author) AS authors FROM (SELECT type, repo.name AS name, actor.id AS author, FROM TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('#{start_date}'), TIMESTAMP('#{end_date}')) WHERE type = 'PushEvent') GROUP BY name HAVING authors >= 2 ORDER BY authors DESC;"
    query_struct = %BigQuery.Types.Query{query: query_string}
    BigQuery.Job.query("krihelinator", query_struct)
  end

  defp process_rows(rows) do
    rows
    |> Stream.map(fn datum -> Map.fetch!(datum, :f) end)
    |> Stream.map(&hd/1)
    |> Enum.map(fn datum -> Map.fetch!(datum, :v) end)
  end
end
