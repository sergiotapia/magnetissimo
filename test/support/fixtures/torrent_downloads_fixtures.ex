# Two synthetic RSS feeds built for two different crawlers are bound to look
# alike; the Nyaa one shares no data or parsing with this one.
# ex_dna:disable-for-this-file
defmodule Magnetissimo.TorrentDownloadsFixtures do
  @moduledoc """
  Synthetic TorrentDownloads RSS bodies for tests.

  Shaped after the real feed. Three details are load-bearing: the upload time
  carries a numeric timezone offset instead of UTC, the category is CDATA and
  empty on a search hit, and the link is relative to the site root.
  """

  @hash_upper "23429A9AE77301514B02DCD1D6ADB17BB87F80C5"
  @hash_lower "ef330cb31971201a6478da3fc8cb6fe454be48ee"

  def hash_upper, do: @hash_upper
  def hash_lower, do: @hash_lower

  @doc "A feed with two items: one with a non-UTC offset, one with an uppercased hash."
  def rss_body do
    """
    <rss version='2.0'>
    <channel>
            <item>
        <title>Kill Jackie S01 2160p WEBRip HDR x265-KONTRAST</title>
        <pubDate>Sat, 10 Oct 2026 01:40:07 +0200</pubDate>
        <category><![CDATA[TV Shows]]></category>
        <link>/torrent/1707208289/Kill-Jackie-S01-2160p-WEBRip-HDR-x265-KONTRAST</link>
        <description></description>
        <size>23379695704</size>
        <seeders>6</seeders>
        <leechers>34</leechers>
        <info_hash>#{@hash_upper}</info_hash>
    </item>
            <item>
        <title>L’Officina della Camomilla - VM 18 [FLAC 24-44]</title>
        <pubDate>Fri, 09 Oct 2026 23:15:00 +0000</pubDate>
        <category><![CDATA[Music]]></category>
        <link>/torrent/1707208279/L-Officina</link>
        <description></description>
        <size>1115712436</size>
        <seeders>9</seeders>
        <leechers>24</leechers>
        <info_hash>#{@hash_lower}</info_hash>
    </item>
    </channel>
    </rss>
    """
  end

  @doc "A feed whose only item has no category, as a search hit is served."
  def search_rss_body do
    """
    <rss version='2.0'>
    <channel>
            <item>
        <title>Ubuntu 12 10 Server 64 Bit</title>
        <pubDate>Mon, 21 Oct 2013 13:20:49 +0200</pubDate>
        <category><![CDATA[]]></category>
        <link>/torrent/1656525368/Ubuntu-12-10-Server-64-Bit</link>
        <description></description>
        <size>24898149</size>
        <seeders>978</seeders>
        <leechers>30</leechers>
        <info_hash>#{@hash_lower}</info_hash>
    </item>
    </channel>
    </rss>
    """
  end

  @doc "A feed whose only item carries no usable upload date."
  def malformed_rss_body do
    """
    <rss version='2.0'>
    <channel>
            <item>
        <title>Broken</title>
        <pubDate>not a date</pubDate>
        <category><![CDATA[Movies]]></category>
        <link>/torrent/1/Broken</link>
        <size>100</size>
        <seeders>0</seeders>
        <leechers>0</leechers>
        <info_hash>#{@hash_lower}</info_hash>
    </item>
    </channel>
    </rss>
    """
  end
end
