defmodule MagnetissimoWeb.HomeLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :torrents, Torrents.list_torrents())}
  end
end
