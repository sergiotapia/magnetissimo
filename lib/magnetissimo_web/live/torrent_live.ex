defmodule MagnetissimoWeb.TorrentLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  @impl true
  def mount(params, _session, socket) do
    torrent = Torrents.get_torrent!(params["torrent_id"])
    {:ok, assign(socket, :torrent, torrent)}
  end
end
