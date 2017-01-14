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

    case language do

      nil ->
        conn
        |> put_status(:not_found)
        |> render(Krihelinator.ErrorView, "404.html")

      _otherwise ->
        # Set the repos language without another DB hit
        repos = for r <- language.repos do
          %{r | language: %{name: language.name}}
        end
        conn
        |> put_flash(:info, "#{language.name} repositories")
        |> render("repositories.html", repos: repos)

    end
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
    case validate_history_query(params) do

      {:ok, value_field, language_names} ->

        query = from(l in Language,
                     where: l.name in ^language_names,
                     preload: :history)
        json =
          query
          |> Repo.all()
          |> Krihelinator.PythonGenServer.process(value_field)
        assigns = [json: json, value_field: value_field]
        render conn, "languages_history.html", assigns

      {:error, error} ->

        conn
        |> put_flash(:error, error)
        |> put_status(:bad_request)
        |> render(Krihelinator.ErrorView, "400.html")
    end

  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
