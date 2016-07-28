alias Krihelinator.{Repo, GithubRepo}

for repo <- Repo.all(GithubRepo) do
  if repo.commits == 0 do
    IO.puts "#{repo.name} have zero commits, deleting!"
    Repo.delete!(repo)
  end
end
