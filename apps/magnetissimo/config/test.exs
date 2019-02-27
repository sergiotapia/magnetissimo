# Since configuration is shared in umbrella projects, this file
# should only configure the :magnetissimo application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :magnetissimo, Magnetissimo.Repo,
  username: "postgres",
  password: "postgres",
  database: "magnetissimo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
