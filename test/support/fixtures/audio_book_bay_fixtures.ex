# A synthetic RSS feed is bound to look like the other crawlers' ones; this
# one shares no data or parsing with them.
# ex_dna:disable-for-this-file
defmodule Magnetissimo.AudioBookBayFixtures do
  @moduledoc """
  Synthetic AudioBookBay pages for tests: the feed, the search results and a
  book's own page.

  Shaped after the real site. Load-bearing details: the feed's links are
  absolute and its dates carry an offset; a search result says the day it was
  posted and no time; a book's title carries HTML entities; the infohash, size
  and trackers sit in a table under the book, and the `Announce URL:` label
  cell has a style attribute the `Tracker:` ones do not.
  """

  @hash_upper "23B1D853D891217222EF24852BF7FF5323E062E6"
  @other_hash "d258c5a9516892ac422ae3d2922ca26a1c8195b0"

  def hash_upper, do: @hash_upper
  def other_hash, do: @other_hash

  @doc "A feed with two books, the first stamped at a non-UTC offset."
  def feed_body do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
      <title>AudioBook Bay (ABB)</title>
      <link>https://audiobookbay.lu</link>
      <pubDate>Sat, 10 Oct 2026 03:18:49 +0000</pubDate>
        <item>
        <title>Chasing Mila - Charlotte Engel</title>
        <link>https://audiobookbay.lu/abss/chasing-mila-charlotte-engel/</link>
        <pubDate>Sat, 10 Oct 2026 04:11:21 +0200</pubDate>
        <category><![CDATA[Adults]]></category>
        <category><![CDATA[Crime]]></category>
      </item>
        <item>
        <title>King Zero - Charlie Higson</title>
        <link>https://audiobookbay.lu/abss/king-zero-charlie-higson/</link>
        <pubDate>Fri, 09 Oct 2026 21:08:30 +0000</pubDate>
        <category><![CDATA[Action]]></category>
      </item>
    </channel>
    </rss>
    """
  end

  @doc "A page of search results with two books."
  def search_body do
    """
    <html><body><div id="content">
      <div class="post"><div class="postTitle"><h2><a href="/abss/chasing-mila-charlotte-engel/" rel="bookmark">Chasing Mila - Charlotte Engel</a></h2></div><div class="postInfo">Category: Adults&nbsp; Crime&nbsp; <br />Language: English</div><div class="postContent">
      <p style='text-align:center;'>Posted: 8 Oct 2026<br />Format: <span style='color:#a00;'>M4B</span> / Bitrate: <span style='color:#a00;'>128 Kbps</span><br />File Size: <span style='color:#00f;'>686.36</span> MBs</p>
      </div></div>
      <div class="post"><div class="postTitle"><h2><a href="/abss/king-zero-charlie-higson/" rel="bookmark">King Zero - Charlie Higson</a></h2></div><div class="postInfo">Category: Action&nbsp; <br />Language: English</div><div class="postContent">
      <p style='text-align:center;'>Posted: 30 Jan 2024<br />Format: <span style='color:#a00;'>MP3</span> / Bitrate: <span style='color:#a00;'>64 Kbps</span><br />File Size: <span style='color:#00f;'>1.25</span> GBs</p>
      </div></div>
    </div></body></html>
    """
  end

  @doc "Search results listing a book at each of `paths`, in that order."
  def search_body(paths) do
    posts =
      Enum.map_join(paths, "\n", fn path ->
        """
        <div class="post"><div class="postTitle"><h2><a href="#{path}" rel="bookmark">#{path}</a></h2></div><div class="postContent">
        <p style='text-align:center;'>Posted: 1 Oct 2026<br />File Size: <span style='color:#00f;'>1.00</span> GBs</p>
        </div></div>
        """
      end)

    ~s(<html><body><div id="content">#{posts}</div></body></html>)
  end

  @doc "Search results that match nothing."
  def empty_search_body, do: "<html><body><div id=\"content\"></div></body></html>"

  @doc "The page for Chasing Mila, its infohash uppercased."
  def chasing_mila_body do
    book_body(
      title: "Chasing Mila - Charlotte Engel",
      hash: @hash_upper,
      size: "686.36",
      unit: "MBs"
    )
  end

  @doc "The page for King Zero, whose title carries entities."
  def king_zero_body do
    book_body(
      title: "King Zero: Bond&#8217;s Return &amp; More - Charlie Higson",
      hash: @other_hash,
      size: "1.25",
      unit: "GBs"
    )
  end

  @doc "A book's page with the torrent table missing, as a removed torrent is shown."
  def no_hash_body do
    """
    <html><body><div class="postTitle"><h1 itemprop="name">Gone - Nobody</h1></div></body></html>
    """
  end

  defp book_body(opts) do
    """
    <html><body>
    <div class="post">
      <div class="postTitle"><h1 itemprop="name">#{opts[:title]}</h1></div>
      <div class="postInfo">
        Category: <a href="https://audiobookbay.lu/audio-books/type/adults/" rel="category tag">Adults</a>,  <a href="https://audiobookbay.lu/audio-books/type/crime/" rel="category tag">Crime</a>
        <br />Language: <a href='/audio-books/tag/english/'><span itemprop='inLanguage'>English</span></a>
      </div>
      <div class="postContent">
      <div class="desc" itemprop="description">
      <p style="left;">Written by <a href="/?s=charlotte+engel&#038;tt=1"><span class="author" itemprop="author" itemtype="https://schema.org/Person">Charlotte Engel</span></a> <br />Read by <a href="/?s=lizzie+munro"><span class="narrator" itemprop="author" itemtype="https://schema.org/Person">Lizzie Munro</span></a> <br />Format: <span class="format" itemprop="encodingFormat">M4B</span> <br />Bitrate: <span class="bitrate" itemprop="bitrate">128 Kbps</span> <br /><span class="is_abridged">Unabridged</span> </p>
      <p>I thought I knew her.</p>
      </div>
      <table border='1' border-color='#dfdfdf' style='margin:0;'>
      <tr>
      <td style='width:150px;'>Announce URL:</td>
      <td style='width:323px;'>http://tracker2.dler.org:80/announce</td>
      </tr>
      <tr>
      <td colspan='2'>This Torrent also has several backup trackers</td>
      </tr>
      <tr>
      <td>Tracker:</td>
      <td>http://tracker2.dler.org:80/announce</td>
      </tr>
      <tr>
      <td>Tracker:</td>
      <td>udp://tracker.opentrackr.org:1337/announce</td>
      </tr>
      <tr>
      <td>File Size:</td>
      <td><span style='color:#00f;'>#{opts[:size]}</span> #{opts[:unit]}</td>
      </tr>
      <tr>
      <td>Info Hash:</td>
      <td>#{opts[:hash]}</td>
      </tr>
      </table>
      </div>
    </div>
    </body></html>
    """
  end
end
