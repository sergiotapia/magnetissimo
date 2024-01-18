defmodule MagnetissimoWeb.TorrentXML do
  alias Magnetissimo.Torrents.Torrent

  def latest_torznab(%{torrents: torrents}) do
    torrents_xml =
      torrents
      |> Enum.map(fn torrent ->
        data(torrent)
      end)
      |> Enum.join()

    """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="1.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:torznab="http://torznab.com/schemas/2015/feed">
      <channel>
        #{torrents_xml}
      </channel>
    </rss>
    """
  end

  def search_torznab(%{torrents: torrents}) do
    torrents_xml =
      torrents
      |> Enum.map(fn torrent ->
        data(torrent)
      end)
      |> Enum.join()

    """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="1.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:torznab="http://torznab.com/schemas/2015/feed">
      <channel>
        #{torrents_xml}
      </channel>
    </rss>
    """
  end

  defp data(%Torrent{} = torrent) do
    ~s"""
      <item>
        <title>#{HtmlEntities.encode(torrent.name)}</title>
        <guid isPermaLink="true">#{HtmlEntities.encode(torrent.canonical_url)}</guid>
        <link>#{HtmlEntities.encode(torrent.canonical_url)}</link>
        <comments>Scraped from #{torrent.source.name}</comments>
        <pubDate>#{torrent.published_at}</pubDate>
        <size>#{torrent.size_in_bytes}</size>
        <enclosure url="#{HtmlEntities.encode("magnet:#{torrent.magnet_url}")}" length="0" type="application/x-bittorrent;x-scheme-handler/magnet" />
        #{torznab_categories(torrent.category.newznab_category_id)}
        <torznab:attr name="seeders" value="#{torrent.seeders}" />
        <torznab:attr name="peers" value="#{torrent.leechers}" />
        <torznab:attr name="magneturl" value="#{HtmlEntities.encode("magnet:#{torrent.magnet_url}")}" />
        <torznab:attr name="infohash" value="#{torrent.magnet_hash}" />
        <torznab:attr name="size" value="#{torrent.size_in_bytes}" />
      </item>
    """
  end

  def torznab_categories(newznab_category_ids) do
    # newznab_category_ids is a comma separated list of newznab category ids
    # we need to return one line of XML per id.
    # <torznab:attr name="category" value="#{newznab_category_id}" />

    (newznab_category_ids || "")
    |> String.split(",")
    |> Enum.map(fn id ->
      """
      <torznab:attr name="category" value="#{id}" />
      """
    end)
    |> Enum.join()
  end
end
