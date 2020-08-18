use Mix.Config

# Logging level
config :logger,
  level: String.to_existing_atom(System.get_env("MAG_LOG_LEVEL", "info"))

# Database Settings
config :magnetissimo, Magnetissimo.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT"),
  pool_size: 10
