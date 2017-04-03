# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :krihelinator,
  ecto_repos: [Krihelinator.Repo],
  periodic_schedule: 6 * 60 * 60 * 1000,  # 6 hours
  scrapers_pool_size: 20,
  history_keeper_schedule: 3 * 24 * 60 * 60 * 1000  # 3 days

# Configures the endpoint
config :krihelinator, Krihelinator.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WCLRK3yAFCHMKEC5+0WtAjzkm1vaRmzk0duH19wW9xC/l3Tb5eLdI0RYl/R7xCTR",
  render_errors: [view: Krihelinator.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Krihelinator.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure your database
config :krihelinator, Krihelinator.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "krihelinator_prod",
  hostname: "localhost",
  pool_size: 10

config :big_query,
  bigquery_private_key_hosted_by_app: :krihelinator,
  bigquery_private_key_path: "priv/bigquery_private_key.json"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
