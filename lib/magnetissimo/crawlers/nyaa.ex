defmodule Magnetissimo.Crawlers.Nyaa do
  use GenServer
  import SweetXml
  require Logger

  alias Magnetissimo.{Repo, Torrent}

  # def handle_info(:rss_fetch, state) do
  #   rss_body = rss()

  #   %{torrents: torrents} =
  #     rss_body
  #     |> xmap(
  #       torrents: [
  #         ~x"//channel/item"l,
  #         name: ~x"./title/text()",
  #         canonical_url: ~x"./guid/text()",
  #         published_at: ~x"./pubDate/text()",
  #         seeds: ~x"./nyaa:seeders/text()",
  #         leechers: ~x"./nyaa:leechers/text()",
  #         magnet_url: ~x"./nyaa:infoHash/text()",
  #         size: ~x"./nyaa:size/text()"
  #       ]
  #     )

  #   Enum.each(torrents, fn torrent_data ->
  #     save_torrent(torrent_data)
  #   end)

  #   schedule_rss_fetch()
  #   {:noreply, state}
  # end

  # defp save_torrent(data) do
  #   {seeds, _} = List.to_string(data.seeds) |> Integer.parse()
  #   {leechers, _} = List.to_string(data.leechers) |> Integer.parse()
  #   name = List.to_string(data.name)
  #   canonical_url = List.to_string(data.canonical_url)
  #   magnet_url = List.to_string(data.magnet_url)

  #   torrent =
  #     Torrent.changeset(%Torrent{}, %{
  #       name: name,
  #       canonical_url: canonical_url,
  #       magnet_url: magnet_url,
  #       leechers: leechers,
  #       seeds: seeds,
  #       website_source: "Nyaa",
  #       size: 0
  #     })

  #   Repo.insert(torrent)
  # end

  def crawl_latest() do
    %{torrents: torrents} =
      get_rss()
      |> xmap(
        torrents: [
          ~x"//channel/item"l,
          name: ~x"./title/text()",
          canonical_url: ~x"./guid/text()",
          published_at: ~x"./pubDate/text()",
          seeders: ~x"./nyaa:seeders/text()",
          leechers: ~x"./nyaa:leechers/text()",
          magnet_url: ~x"./nyaa:infoHash/text()",
          size: ~x"./nyaa:size/text()"
        ]
      )

    # TODO: Hit every url, and parse the description.

    # Set the category.

    # Set the source as nyaa.si's source id.

    # field :description, :string
    # belongs_to :category, Category
    # belongs_to :source, Source
  end

  def get_rss do
    %{status_code: 200, body: body} =
      "https://nyaa.si/?page=rss"
      |> HTTPoison.get!()

    body
  end
end
