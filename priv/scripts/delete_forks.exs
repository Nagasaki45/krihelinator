alias Krihelinator.{Repo, GithubRepo}

for repo <- Repo.all(GithubRepo) do
  url = "repos/#{repo.name}"
  {:ok, %{body: content, status_code: 200}} = GithubAPI.get(url)
  if Map.get(content, "fork") do
    IO.puts "#{repo.name} is a fork, deleting!"
    Repo.delete!(repo)
  end
end
