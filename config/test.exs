import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :magnetissimo, Magnetissimo.Repo,
  database: Path.expand("../magnetissimo_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :magnetissimo, MagnetissimoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jTHOYWPY5CEEpcqgGI5cD8gdXtLbWhDlt58/UCg9DVdJJyUYShrrG21chSKJgGZ4",
  server: false

# In test we don't send emails
config :magnetissimo, Magnetissimo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Route the YTS crawler's HTTP through a `Req.Test` stub, so no test ever
# reaches the network. Individual tests install the stub with
# `Req.Test.stub(Magnetissimo.Crawlers.Yts, fn conn -> ... end)`.
config :magnetissimo, Magnetissimo.Crawlers.Yts, plug: {Req.Test, Magnetissimo.Crawlers.Yts}

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
