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
      |> assign(:filters, %{search: ""})
      |> assign(page: 1, per_page: 20)
      |> assign_indexing_summary()

    {:ok, socket}
  end

  def handle_params(params, uri, socket) do
    url = URI.parse(uri) |> URI.to_string()

    filter_opts = %{
      search: params["search"] || ""
    }

    socket =
      socket
      |> assign(:share_url, url)
      |> assign(:meta_url, url)
      |> assign(:filters, filter_opts)
      |> assign(page: 1, per_page: 20)

    {:noreply, paginate_torrents(socket, socket.assigns.page)}
  end

  defp paginate_torrents(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns

    torrents =
      Torrents.search_torrents(
        filter_opts: socket.assigns.filters,
        offset: (new_page - 1) * per_page,
        limit: per_page
      )

    {torrents, at, limit} =
      if new_page >= cur_page do
        {torrents, -1, per_page * 3 * -1}
      else
        {Enum.reverse(torrents), 0, per_page * 3}
      end

    case torrents do
      [] ->
        # assign(socket, end_of_timeline?: at == -1)
        socket
        |> assign(:end_of_timeline?, at == -1)
        |> stream(:torrents, torrents, reset: true)

      [_ | _] = torrents ->
        socket =
          socket
          |> assign(end_of_timeline?: false)
          |> assign(:page, new_page)

        if cur_page == 1 do
          stream(socket, :torrents, torrents, reset: true)
        else
          stream(socket, :torrents, torrents, at: at, limit: limit)
        end
    end
  end

  def handle_event("filter", params, socket) do
    search = params["filter"]["search"] || ""

    filter_opts = %{search: search}

    socket =
      socket
      |> assign(:filters, filter_opts)

    {:noreply, push_patch(socket, to: ~p"/?#{filter_opts}")}
  end

  def handle_event("next-page", _, socket) do
    {:noreply, paginate_torrents(socket, socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_torrents(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_torrents(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  def assign_indexing_summary(socket) do
    assign(socket, :indexing_summary, Torrents.list_crawler_statistics())
  end
end
