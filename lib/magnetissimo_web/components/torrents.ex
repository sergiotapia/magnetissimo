defmodule MagnetissimoWeb.Components.Torrents do
  use Phoenix.Component
  use MagnetissimoWeb, :verified_routes

  import MagnetissimoWeb.Helpers

  attr :torrent, Magnetissimo.Torrents.Torrent
  attr :id, :string

  def torrent_result_item(assigns) do
    ~H"""
    <tr
      id={@id}
      class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
    >
      <td class="px-6 py-4">
        <.link navigate={~p"/torrents/#{@torrent.id}/#{@torrent.slug}"} class="font-bold">
          <%= @torrent.name %>
        </.link>
        <div class="flex gap-4">
          <span>
            <%= @torrent.category.name %>
          </span>
          <span>
            <%= @torrent.source.name %>
          </span>
        </div>
        <div>
          <span>
            <%= format_date(@torrent.inserted_at) %>
          </span>
        </div>
      </td>
      <td class="px-6 py-4">
        <%= format_size(@torrent.size_in_bytes) %>
      </td>
      <td class="px-6 py-4">
        <%= @torrent.seeders %>
      </td>
      <td class="px-6 py-4">
        <%= @torrent.leechers %>
      </td>
      <td class="px-6 py-4">
        <.link
          href={{:magnet, @torrent.magnet_url}}
          class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
        >
          <img src="/images/magnet.svg" class="h-5 w-5" />
        </.link>
      </td>
      <td class="px-6 py-4 text-right">
        <.link
          href={@torrent.canonical_url}
          target="_blank"
          title="Visit the canonical url for this torrent."
          class="text-blue-500 hover:underline"
        >
          <%= @torrent.source.name %>
        </.link>
      </td>
    </tr>
    """
  end
end
