# Since configuration is shared in umbrella projects, this file
# should only configure the :magnetissimo_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :magnetissimo_web,
  ecto_repos: [Magnetissimo.Repo],
  generators: [context_app: :magnetissimo]

# Configures the endpoint
config :magnetissimo_web, MagnetissimoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rRXsulYJI39DjBRRn9k1C7qbOortteUKL2atN/ffXvGwYS7q55mZTezxjDvdU/AR",
  render_errors: [view: MagnetissimoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MagnetissimoWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
