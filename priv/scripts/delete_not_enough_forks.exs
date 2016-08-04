alias Krihelinator.{Repo, GithubRepo}
alias Krihelinator.Pipeline.StatsScraper
import Ecto.Query, only: [from: 2]

rescrape_and_delete = fn repo ->
  forks =
    repo
    |> StatsScraper.scrape
    |> Map.get(:forks)
  if forks <= 10 do
    IO.puts "Deleting #{repo.name} (#{forks} forks)"
    Repo.delete!(repo)
  end
end

from(r in GithubRepo, where: not r.user_requested)
|> Repo.all
|> Enum.each(rescrape_and_delete)
