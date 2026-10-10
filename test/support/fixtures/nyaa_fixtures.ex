defmodule Magnetissimo.NyaaFixtures do
  @moduledoc """
  Synthetic Nyaa/Sukebei RSS bodies for tests.

  Shaped after the real feeds. Two details are load-bearing: a title can hold
  an XML entity and non-ASCII text, and the feed sends infohashes in either
  case, while the schema only accepts lowercase.
  """

  @hash_lower "aec9b1182f520e27af38955dce4cec9118ac115f"
  @hash_upper "0123456789ABCDEF0123456789ABCDEF01234567"

  def hash_lower, do: @hash_lower
  def hash_upper, do: @hash_upper

  @doc "A feed with two items: one with entities, one with an uppercased hash."
  def rss_body do
    """
    <rss xmlns:nyaa="https://nyaa.si/xmlns/nyaa" version="2.0">
      <channel>
        <title>Nyaa - Home - Torrent File RSS</title>
        <item>
          <title>[Group] Show &amp; Tell - 01 (1080p)</title>
          <link>https://nyaa.test/download/1.torrent</link>
          <guid isPermaLink="true">https://nyaa.test/view/1</guid>
          <pubDate>Fri, 09 Oct 2026 23:24:24 -0000</pubDate>
          <nyaa:seeders>12</nyaa:seeders>
          <nyaa:leechers>3</nyaa:leechers>
          <nyaa:infoHash>#{@hash_lower}</nyaa:infoHash>
          <nyaa:categoryId>1_2</nyaa:categoryId>
          <nyaa:category>Anime - English-translated</nyaa:category>
          <nyaa:size>1.5 GiB</nyaa:size>
          <description><![CDATA[not read by the crawler]]></description>
        </item>
        <item>
          <title>Café &amp; 日本語 &#39;quoted&#39; - 02</title>
          <link>https://nyaa.test/download/2.torrent</link>
          <guid isPermaLink="true">https://nyaa.test/view/2</guid>
          <pubDate>Thu, 08 Oct 2026 10:00:00 -0000</pubDate>
          <nyaa:seeders>5</nyaa:seeders>
          <nyaa:leechers>0</nyaa:leechers>
          <nyaa:infoHash>#{@hash_upper}</nyaa:infoHash>
          <nyaa:categoryId>1_4</nyaa:categoryId>
          <nyaa:category>Anime - Raw</nyaa:category>
          <nyaa:size>700.5 MiB</nyaa:size>
        </item>
      </channel>
    </rss>
    """
  end

  @doc "A feed with one item filed under a Sukebei-only category."
  def sukebei_rss_body do
    """
    <rss xmlns:nyaa="https://sukebei.nyaa.si/xmlns/nyaa" version="2.0">
      <channel>
        <item>
          <title>Fixture Clip 01</title>
          <link>https://sukebei.test/download/1.torrent</link>
          <guid isPermaLink="true">https://sukebei.test/view/1</guid>
          <pubDate>Fri, 09 Oct 2026 23:24:24 -0000</pubDate>
          <nyaa:seeders>1</nyaa:seeders>
          <nyaa:leechers>0</nyaa:leechers>
          <nyaa:infoHash>#{@hash_lower}</nyaa:infoHash>
          <nyaa:categoryId>2_2</nyaa:categoryId>
          <nyaa:category>Real Life - Videos</nyaa:category>
          <nyaa:size>1.1 GiB</nyaa:size>
        </item>
      </channel>
    </rss>
    """
  end

  @doc "A feed whose only item carries no usable date or size."
  def malformed_rss_body do
    """
    <rss xmlns:nyaa="https://nyaa.si/xmlns/nyaa" version="2.0">
      <channel>
        <item>
          <title>Broken</title>
          <guid isPermaLink="true">https://nyaa.test/view/3</guid>
          <nyaa:infoHash>#{@hash_lower}</nyaa:infoHash>
          <nyaa:categoryId>1_4</nyaa:categoryId>
          <nyaa:category>Anime - Raw</nyaa:category>
          <nyaa:size>not a size</nyaa:size>
        </item>
      </channel>
    </rss>
    """
  end

  @doc "A feed whose only item is small enough that Nyaa sizes it in raw bytes."
  def bytes_size_rss_body do
    """
    <rss xmlns:nyaa="https://sukebei.nyaa.si/xmlns/nyaa" version="2.0">
      <channel>
        <item>
          <title>Angel Club 06-12.zip</title>
          <guid isPermaLink="true">https://sukebei.test/view/191</guid>
          <pubDate>Thu, 16 Nov 2006 00:36:00 -0000</pubDate>
          <nyaa:seeders>0</nyaa:seeders>
          <nyaa:leechers>0</nyaa:leechers>
          <nyaa:infoHash>#{@hash_lower}</nyaa:infoHash>
          <nyaa:categoryId>1_1</nyaa:categoryId>
          <nyaa:category>Art - Anime</nyaa:category>
          <nyaa:size>0 Bytes</nyaa:size>
        </item>
      </channel>
    </rss>
    """
  end
end
