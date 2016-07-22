# Run this script when there is a need to re-fetch the repos descriptions from
# github.

alias Krihelinator.{Repo, GithubRepo}

repos = Repo.all(GithubRepo)
for repo <- repos do
  url = "repos/#{repo.name}"
  {:ok, %{body: content, status_code: 200}} = GithubAPI.limited_get(url)
  description = Map.get(content, "description")

  repo
  |> GithubRepo.changeset(%{description: description})
  |> Repo.update!
end
