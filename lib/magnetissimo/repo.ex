defmodule Magnetissimo.Repo do
  use Ecto.Repo, otp_app: :magnetissimo
  use Scrivener, page_size: 50
end
