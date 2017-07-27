defmodule Magnetissimo.Crawler.WorldWideTorrentsTest do
  use ExUnit.Case, async: true

  test "scrapes torrent information from page" do
    torrents = Magnetissimo.Crawler.WorldWideTorrents.torrent_information(list_sample)
    assert torrents != nil
  end

  def list_sample do
    Fixtures.load("worldwidetorrents")
  end
end
