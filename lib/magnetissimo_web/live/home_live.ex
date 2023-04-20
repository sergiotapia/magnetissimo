defmodule MagnetissimoWeb.HomeLive do
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents
  alias MagnetissimoWeb.Forms.SortingForm
  alias MagnetissimoWeb.Forms.PaginationForm
  alias MagnetissimoWeb.Forms.FilterForm

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> parse_params(params)
      |> assign_torrents()
      |> assign_indexing_summary()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, opts}, socket) do
    params = merge_and_sanitize_params(socket, opts)
    query_params = URI.encode_query(params)
    path = "/?#{query_params}"
    {:noreply, push_patch(socket, to: path, replace: true)}
  end

  defp parse_params(socket, params) do
    with {:ok, sorting_opts} <- SortingForm.parse(params),
         {:ok, filter_opts} <- FilterForm.parse(params),
         {:ok, pagination_opts} <- PaginationForm.parse(params) do
      socket
      |> assign_sorting(sorting_opts)
      |> assign_filter(filter_opts)
      |> assign_pagination(pagination_opts)
    else
      _error ->
        socket
        |> assign_sorting()
        |> assign_filter()
        |> assign_pagination()
    end
  end

  defp assign_sorting(socket, overrides \\ %{}) do
    assign(socket, :sorting, SortingForm.default_values(overrides))
  end

  defp assign_filter(socket, overrides \\ %{}) do
    assign(socket, :filter, FilterForm.default_values(overrides))
  end

  defp assign_pagination(socket, overrides \\ %{}) do
    assign(socket, :pagination, PaginationForm.default_values(overrides))
  end

  defp assign_torrents(socket) do
    params = merge_and_sanitize_params(socket)

    torrents = Torrents.list_torrents(params)

    socket
    |> assign(:torrents, torrents)
  end

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
    %{sorting: sorting, pagination: pagination, filter: filter} = socket.assigns
    overrides = maybe_reset_pagination(overrides)

    %{}
    |> Map.merge(sorting)
    |> Map.merge(pagination)
    |> Map.merge(filter)
    |> Map.merge(overrides)
    |> Map.drop([:total_count])
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  def assign_indexing_summary(socket) do
    assign(socket, :indexing_summary, Torrents.get_crawler_statistics())
  end

  defp maybe_reset_pagination(overrides) do
    if FilterForm.contains_filter_values?(overrides) do
      Map.put(overrides, :page, 1)
    else
      overrides
    end
  end
end
