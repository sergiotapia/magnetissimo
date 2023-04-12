import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :magnetissimo, Magnetissimo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "magnetissimo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :magnetissimo, MagnetissimoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GzfJOSvi3YlKp8QLGzh8iMh6+Nt2abGynu74bmt7ew6pPmQBGhqLshlsq5Dzq4eK",
  server: false

# In test we don't send emails.
config :magnetissimo, Magnetissimo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :magnetissimo, Oban, testing: :inline
