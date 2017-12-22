# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :magnetissimo,
  ecto_repos: [Magnetissimo.Repo]

# Configures the endpoint
config :magnetissimo, MagnetissimoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Djok4TJL7QT3rMVlG7RZixZPsiU1dN9BogAq8bQdf01N6gMeBnh9KB6ah9go1QqI",
  render_errors: [view: MagnetissimoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Magnetissimo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
