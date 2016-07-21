alias Krihelinator.Repo
alias Krihelinator.GithubRepo
alias Krihelinator.Background

Repo.all(GithubRepo)
|> Stream.map(&Map.from_struct/1)
|> Enum.each(&Background.StatsScraper.process/1)
