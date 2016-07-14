# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :krihelinator,
  ecto_repos: [Krihelinator.Repo],
  github_token: System.get_env("GITHUB_TOKEN"),
  initial_threshold: 5,
  db_cleaner_period: 10 * 60 * 1000,  # 10 minutes
  max_repos_to_keep: 500,
  scrapers_pool_size: 32

# Configures the endpoint
config :krihelinator, Krihelinator.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WCLRK3yAFCHMKEC5+0WtAjzkm1vaRmzk0duH19wW9xC/l3Tb5eLdI0RYl/R7xCTR",
  render_errors: [view: Krihelinator.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Krihelinator.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
