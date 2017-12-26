use Mix.Config

config :magnetissimo, Magnetissimo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DBUSER"),
  password: System.get_env("DBPASSWORD"),
  database: System.get_env("DBNAME"),
  hostname: "db",
  port: 5432,
  pool_size: 50


config :logger, level: :info
