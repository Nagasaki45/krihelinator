defmodule Krihelinator.PeriodicTest do
  use Krihelinator.ModelCase  # To prepare the SQL connection
  alias Krihelinator.{Periodic, GithubRepo}

  test "not having name duplications. Bug #99" do
    # First, there was microsoft/vscode
    old_vscode_params = %{name: "microsoft/vscode", merged_pull_requests: 10,
                          proposed_pull_requests: 10, authors: 5, commits: 100,
                          new_issues: 20, closed_issues: 20}
    %GithubRepo{}
    |> GithubRepo.changeset(old_vscode_params)
    |> Repo.insert
    # Then, a "new" project was found by the pipeline
    # But it's actually the same project after it was renamed
    new_vscode_params = %{ old_vscode_params | name: "Microsoft/vscode" }
    %GithubRepo{}
    |> GithubRepo.changeset(new_vscode_params)
    |> Repo.insert
    # Now, there are two different projects that are the same
    Periodic.rescrape_existing()
    # The periodic process should have fix that
    assert length(Repo.all(GithubRepo)) == 1
  end
end
