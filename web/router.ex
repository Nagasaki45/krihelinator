defmodule Krihelinator.Router do
  use Krihelinator.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Krihelinator do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :repositories
    get "/repositories/:user/:repo", PageController, :repository
    get "/languages", PageController, :languages
    get "/languages/:language", PageController, :language
    get "/languages-history", PageController, :languages_history
    get "/showcases", PageController, :showcases
    get "/showcases/:showcase", PageController, :showcase
    get "/about", PageController, :about
  end

  scope "/badge", Krihelinator do
    get "/:user/:repo", BadgeController, :badge
  end

  scope "/data", Krihelinator do
    get "/", DataController, :all
  end
end
