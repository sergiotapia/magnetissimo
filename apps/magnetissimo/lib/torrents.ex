defmodule Magnetissimo.Torrents do
  alias Magnetissimo.Repo
  alias Magnetissimo.Torrent
  import Ecto.Query

  def all() do
    Torrent |> order_by(desc: :inserted_at) |> Repo.all()
  end
end
