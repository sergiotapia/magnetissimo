defmodule Magnetissimo.Repo do
  use Ecto.Repo,
    otp_app: :magnetissimo,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 50
end
