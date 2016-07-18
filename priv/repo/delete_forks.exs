alias Krihelinator.Repo
alias Krihelinator.GithubRepo
alias Krihelinator.Background.GithubAPI

for repo <- Repo.all(GithubRepo) do
  url = "repos/#{repo.name}"
  {:ok, %{body: content, status_code: 200}} = GithubAPI.limited_get(url)
  if Map.get(content, "fork") do
    IO.puts "#{repo.name} is a fork, deleting!"
    Repo.delete!(repo)
  end
end
