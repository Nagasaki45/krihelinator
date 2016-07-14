# Run this script when there is a need to update the krihelimeter value
# on all of the repos in the DB. For example: after changing the krihelimeter
# calculation.

alias Krihelinator.Repo
alias Krihelinator.GithubRepo

repos = Repo.all(GithubRepo)
for repo <- repos do
  repo |> GithubRepo.changeset |> Repo.update!
end
