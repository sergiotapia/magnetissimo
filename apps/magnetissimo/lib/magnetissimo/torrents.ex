defmodule Magnetissimo.Torrents do
  alias Magnetissimo.Torrents.Torrent
  alias Magnetissimo.Repo

  def create_torrent(params) do
    %Torrent{}
    |> Torrent.changeset(params)
    |> Repo.insert()
  end
end
