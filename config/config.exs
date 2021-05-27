# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :magnetissimo,
  ecto_repos: [Magnetissimo.Repo]

config :magnetissimo_web,
  ecto_repos: [Magnetissimo.Repo],
  generators: [context_app: :magnetissimo, binary_id: true]

# Configures the endpoint
config :magnetissimo_web, MagnetissimoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+va9BjVZKj2kMYBiHYz6Rxs5jX4/i3pMZZjCFuvgYKN6uQajAONCjSRSudv6k7HQ",
  render_errors: [view: MagnetissimoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Magnetissimo.PubSub,
  live_view: [signing_salt: "TnLw/btN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
