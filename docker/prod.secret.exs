use Mix.Config

config :magnetissimo, Magnetissimo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "torrent",
  password: "postgres-secret",
  database: "magnetissimo_dev",
  hostname: "db",
  port: 5432,
  pool_size: 50