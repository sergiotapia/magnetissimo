# Since configuration is shared in umbrella projects, this file
# should only configure the :magnetissimo application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :magnetissimo, Magnetissimo.Repo,
  database: "magnetissimo_dev",
  hostname: "localhost",
  pool_size: 10
