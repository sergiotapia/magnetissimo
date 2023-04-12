defmodule MagnetissimoWeb.HomeLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign_search_term(params["search_term"])
      |> assign_torrents(params["search_term"])
      |> assign_indexing_summary()

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      # |> assign_search_term(params["search_term"])
      |> assign_torrents(params["search_term"])

    {:noreply, socket}
  end

  def handle_event("submit", %{"search" => %{"search_term" => search_term}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/search/#{search_term}",
       replace: true
     )}
  end

  def handle_event("search", %{"search" => %{"search_term" => ""}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/",
       replace: true
     )}
  end

  def handle_event("search", %{"search" => %{"search_term" => search_term}}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/search/#{search_term}",
       replace: true
     )}
  end

  defp assign_search_term(socket, nil) do
    assign(socket, :search_term, nil)
  end

  defp assign_search_term(socket, search_term) do
    assign(socket, :search_term, search_term)
  end

  defp assign_torrents(socket, nil) do
    torrents = Torrents.list_torrents()
    assign(socket, :torrents, torrents)
  end

  defp assign_torrents(socket, search_term) do
    cond do
      String.length(search_term) >= 3 ->
        torrents = Torrents.search_torrents(search_term)
        assign(socket, :torrents, torrents)

      String.length(search_term) == 0 ->
        assign(socket, :torrents, [])

      true ->
        assign(socket, :torrents, [])
    end
  end

  def assign_indexing_summary(socket) do
    assign(socket, :indexing_summary, Torrents.get_crawler_statistics())
  end
end
