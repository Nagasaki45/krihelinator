alias Krihelinator.{Repo, GithubRepo}

for repo <- Repo.all(GithubRepo) do
  authors = repo.authors
  if authors <= 5 do
    IO.puts "#{repo.name} have only #{authors} authors, deleting!"
    Repo.delete!(repo)
  end
end
