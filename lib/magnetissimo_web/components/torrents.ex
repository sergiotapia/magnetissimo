defmodule MagnetissimoWeb.Components.Torrents do
  use Phoenix.Component

  import MagnetissimoWeb.Components.Containers

  alias Magnetissimo.Torrents.Torrent

  attr(:class, :string, default: "")
  attr(:id, :string)
  attr(:torrent, Torrent, required: true)

  def search_result(assigns) do
    ~H"""
    <.box class={@class}>
      <p><%= @torrent.name %></p>
      <p><%= @torrent.size_in_bytes |> Size.humanize!() %></p>
      <p>Seeders: <%= @torrent.seeders %> | Leechers <%= @torrent.leechers %></p>
      <.link href={{:magnet, @torrent.magnet_url}}>Download</.link>
    </.box>
    """
  end
end
