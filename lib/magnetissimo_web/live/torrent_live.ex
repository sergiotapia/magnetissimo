defmodule MagnetissimoWeb.TorrentLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  def mount(%{"id" => id}, _session, socket) do
    torrent = Torrents.get_torrent!(id)

    socket =
      socket
      |> assign(
        :page_title,
        "Magnetissimo - #{torrent.name}"
      )
      |> assign(:torrent, torrent)

    {:ok, socket}
  end
end
