# Due to restarts there is a chance for multiple language history points to
# exist for the same date. They are redundant and slow down getting the history
# page. This script remove the duplicates.

defmodule HistoryDuplicatesCleaner do
  alias Krihelinator.{Repo, LanguageHistory}
  require Logger

  @moduledoc """
  A module to organize the duplication cleaning functions with meaningful names.
  """

  @doc """
  A datum is considered duplicate if there is already another datum for the same
  date (day) and language as this one. Therefore, remove it!
  """
  def remove_duplicates() do
    get_duplicates()
    |> Enum.each(&Repo.delete/1)
  end

  @doc """
  Get a list of all of the duplicates.
  """
  def get_duplicates() do
    LanguageHistory
    |> Repo.all
    |> log_length("history points")
    |> Enum.reduce({MapSet.new, []}, &filter_duplicates/2)
    |> elem(1)  # 2nd element is the duplicates
    |> log_length("duplicates")
  end

  @doc """
  Should be used in reduce to check if for a datum we already have another
  one from the same date and language.
  """
  def filter_duplicates(datum, {date_language_set, duplicates}) do
    date = DateTime.to_date(datum.timestamp)
    language = datum.name
    date_language = {date, language}
    if MapSet.member?(date_language_set, date_language) do
      {date_language_set, [datum | duplicates]}
    else
      {MapSet.put(date_language_set, date_language), duplicates}
    end
  end

  def log_length(items, what) do
    num = length(items)
    Logger.info "Found #{num} #{what}"
    items
  end
end

HistoryDuplicatesCleaner.remove_duplicates()
