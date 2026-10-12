import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/magnetissimo start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :magnetissimo, MagnetissimoWeb.Endpoint, server: true
end

config :magnetissimo, MagnetissimoWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

# The DHT crawler is switched on, and its rate set, on the /dht page; those
# settings live in the database. DHT_PORT is the local UDP port it sends
# from, any free one by default: the crawler is a read-only node, so nothing
# has to be forwarded.
if config_env() != :test do
  config :magnetissimo, Magnetissimo.DHT, port: String.to_integer(System.get_env("DHT_PORT", "0"))
end

if config_env() == :dev do
  # Reload browser tabs when matching files change.
  config :magnetissimo, MagnetissimoWeb.Endpoint,
    live_reload: [
      web_console_logger: true,
      patterns: [
        # Static assets, except user uploads
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
        # Gettext translations
        ~r"priv/gettext/.*\.po$"E,
        # Router, Controllers, LiveViews and LiveComponents
        ~r"lib/magnetissimo_web/router\.ex$"E,
        ~r"lib/magnetissimo_web/(controllers|live|components)/.*\.(ex|heex)$"E
      ]
    ]
end

if config_env() == :prod do
  # The SQLite file. The directory must exist and be writable; the file is
  # created on first boot. The Docker image sets /data/magnetissimo.db.
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /var/lib/magnetissimo/magnetissimo.db
      """

  config :magnetissimo, Magnetissimo.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # Signs cookies and the LiveView session. Without SECRET_KEY_BASE, one is
  # generated on first boot and kept beside the database, so a homelab
  # install needs no configuration and survives restarts and upgrades.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      (
        key_path = Path.join(Path.dirname(database_path), "secret_key_base")

        case File.read(key_path) do
          {:ok, key} ->
            String.trim(key)

          {:error, :enoent} ->
            key = Base.encode64(:crypto.strong_rand_bytes(64))
            File.write!(key_path, key)
            File.chmod!(key_path, 0o600)
            key
        end
      )

  config :magnetissimo, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # PHX_HOST is the public name behind an HTTPS reverse proxy. Nothing is
  # needed for plain http://<lan-ip>:4000.
  url =
    case System.get_env("PHX_HOST") do
      nil -> [host: "localhost"]
      host -> [host: host, port: 443, scheme: "https"]
    end

  config :magnetissimo, MagnetissimoWeb.Endpoint,
    url: url,
    # The LiveView socket accepts the host the page was served from, so the
    # app works at whatever IP or name it is reached by without listing them.
    check_origin: :conn,
    http: [
      # All interfaces, IPv6 and IPv4. See the documentation on
      # https://bandit.hexdocs.pm/Bandit.html#t:options/0
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base
end
