# Since configuration is shared in umbrella projects, this file
# should only configure the :magnetissimo application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :magnetissimo,
  ecto_repos: [Magnetissimo.Repo]

import_config "#{Mix.env()}.exs"
