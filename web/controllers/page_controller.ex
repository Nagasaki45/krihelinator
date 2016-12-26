defmodule Krihelinator.PageController do
  use Krihelinator.Web, :controller

  def repositories(conn, _params) do
    repos = Repo.all from(r in GithubRepo,
                          order_by: [desc: r.krihelimeter],
                          limit: 50,
                          preload: :language)
    render conn, "repositories.html", repos: repos
  end

  def language(conn, %{"language" => language_name}) do
    repos_query = from(r in GithubRepo,
                       order_by: [desc: r.krihelimeter],
                       limit: 50)
    language = Repo.one from(l in Language,
                             where: l.name == ^language_name,
                             preload: [repos: ^repos_query])

    # Set the repos language without another DB hit
    repos = for r <- language.repos do
      %{r | language: %{name: language.name}}
    end

    conn
    |> put_flash(:info, "#{language.name} repositories")
    |> render("repositories.html", repos: repos)
  end

  def languages(conn, params) do
    {conn, {by, dir}} = case verify_by(params) do
      {:ok, by, dir} ->
        {conn, {by, dir}}
      _error ->
        conn = put_flash(conn, :error, "The provided arguments are invalid!")
        {conn, {:krihelimeter, :desc}}
    end
    languages = Repo.all from(Language, order_by: [{^dir, ^by}])
    render(conn, "languages.html", languages: languages)
  end

  def languages_history(conn, params) do
    # "Sanitize" params
    language_names =
      params
      |> Map.get("languages", "[]")
      |> Poison.decode!
    value_field = Map.get(params, "by", "krihelimeter")

    languages = Repo.all from(l in Language,
                              where: l.name in ^language_names,
                              preload: :history)

    json =
      languages
      |> Enum.flat_map(fn language ->
        for datum <- language.history do
          %{name: language.name,
            timestamp: datum.timestamp,
            value: Map.fetch!(datum, String.to_existing_atom(value_field))}
          end
        end)
      |> Poison.encode!()
      |> Krihelinator.PythonGenServer.process()

    assigns = [json: json, value_field: value_field]
    render conn, "languages_history.html", assigns
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
