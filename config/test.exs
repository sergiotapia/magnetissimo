use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :magnetissimo, Magnetissimo.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :magnetissimo, Magnetissimo.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "v2821993_root",
  password: "abcd.1234",
  database: "v2821993_torrent",
  hostname: "64.62.211.131",
  port: 3306,
  pool_size: 50

