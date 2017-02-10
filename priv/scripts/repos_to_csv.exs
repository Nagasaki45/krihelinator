alias Krihelinator.{Repo, GithubRepo}
import Ecto.Query, only: [from: 2]
require Logger

Logger.configure(level: :error)


fields = ~w(name language merged_pull_requests proposed_pull_requests
            closed_issues new_issues commits authors)a
fields
|> Enum.join(",")
|> IO.puts()

query = from(r in GithubRepo, preload: :language)
for repo <- Repo.all(query) do
  language = if repo.language, do: repo.language.name, else: ""
  repo = %{repo | language: language}
  fields
  |> Enum.map(fn field -> Map.fetch!(repo, field) end)
  |> Enum.join(",")
  |> IO.puts()
end
