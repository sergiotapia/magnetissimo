defmodule MagnetissimoWeb.SearchLive do
  use MagnetissimoWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :page_title,
        "Search for torrents"
      )
      |> assign(
        :torrents,
        Magnetissimo.Torrents.list_torrents()
      )

    {:ok, socket}
  end
end
