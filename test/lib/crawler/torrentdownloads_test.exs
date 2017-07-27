defmodule Magnetissimo.Crawler.TorrentDownloadsTest do
  use ExUnit.Case, async: true

  test "scrapes torrent detail links from a page" do
    torrent_links = Magnetissimo.Crawler.TorrentDownloads.torrent_links(list_sample)
    assert Enum.count(torrent_links) == 42
   end

  test "scrapes torrent information from a torrent detail page" do
    torrent = Magnetissimo.Crawler.TorrentDownloads.torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    Fixtures.load("torrentdownloads_torrent_info")
  end

  def list_sample do
    Fixtures.load("torrentdownloads")
  end

end
