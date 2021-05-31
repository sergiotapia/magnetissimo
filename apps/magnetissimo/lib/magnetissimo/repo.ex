defmodule Magnetissimo.Repo do
  use Ecto.Repo,
    otp_app: :magnetissimo,
    adapter: Ecto.Adapters.Postgres
end
