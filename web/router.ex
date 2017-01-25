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
    get "/repositories/:language", PageController, :language
    get "/languages", PageController, :languages
    get "/languages/history", PageController, :languages_history
    get "/badge", PageController, :badge
    get "/about", PageController, :about
  end

  scope "/badge", Krihelinator do
    get "/:user/:repo", BadgeController, :badge
  end
end
