defmodule Krihelinator.Krihelimeter do
  @moduledoc """
  Calculates the Krihelemeter of a repo.
  """

  def calculate(repo) do
    Enum.sum [
      8 * repo.merged_pull_requests,
      8 * repo.proposed_pull_requests,
      8 * repo.closed_issues,
      8 * repo.new_issues,
      1 * repo.commits,
      20 * repo.authors,
    ]
  end
end
