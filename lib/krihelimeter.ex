defmodule Krihelinator.Krihelimeter do
  @moduledoc """
  Calculates the Krihelemeter of a repo.
  """

  def calculate(repo) do
    Enum.sum [
      1 * repo.merged_pull_requests,
      1 * repo.proposed_pull_requests,
      1 * repo.closed_issues,
      1 * repo.new_issues,
      1 * repo.commits,
    ]
  end
end
