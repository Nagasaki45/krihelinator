alias Krihelinator.{Repo, GithubRepo}

for repo <- Repo.all(GithubRepo) do
  commits = repo.commits
  unless commits > 0 do
    IO.puts "#{repo.name} have only #{commits} commits, deleting!"
    Repo.delete!(repo)
  end
end
