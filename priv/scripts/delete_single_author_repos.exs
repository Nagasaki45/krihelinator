alias Krihelinator.{Repo, GithubRepo}

query = from(r in GithubRepo, where: not r.user_requested)
for repo <- Repo.all(query) do
  authors = repo.authors
  unless authors > 1 do
    IO.puts "#{repo.name} have only #{authors} authors, deleting!"
    Repo.delete!(repo)
  end
end
