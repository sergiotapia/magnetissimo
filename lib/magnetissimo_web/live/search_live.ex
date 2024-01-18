defmodule MagnetissimoWeb.SearchLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

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
      |> assign_indexing_summary()

    {:ok, socket}
  end

  def assign_indexing_summary(socket) do
    assign(socket, :indexing_summary, Torrents.list_crawler_statistics())
  end
end
