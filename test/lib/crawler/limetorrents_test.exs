defmodule Magnetissimo.Crawler.LimeTorrentsTest do
  use ExUnit.Case, async: true
  require IEx

  test "scrapes torrent information from detail page" do
    torrent = Magnetissimo.Crawler.LimeTorrents.torrent_information(detail_sample)
    assert torrent != nil
  end

  def detail_sample do
    Fixtures.load("limetorrents_torrent_info")
  end

end
