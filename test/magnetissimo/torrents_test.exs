defmodule Magnetissimo.TorrentsTest do
  use Magnetissimo.DataCase, async: false

  import Magnetissimo.TorrentsFixtures

  alias Magnetissimo.Torrents

  describe "list_category_tree/0" do
    test "returns parents with their children, and Other as a childless parent" do
      seed!()
      tree = Torrents.list_category_tree()

      video = Enum.find(tree, &(&1.name == "Video"))
      assert Enum.map(video.children, & &1.name) |> Enum.member?("Video - Movies")

      other = Enum.find(tree, &(&1.name == "Other"))
      assert other.children == []

      refute Enum.any?(tree, &(&1.name == "Video - Movies"))
    end
  end

  describe "list_latest_torrents/1" do
    test "orders newest first and filters by category" do
      old = torrent_fixture(name: "old", published_at: ~U[2026-01-01 00:00:00Z])
      new = torrent_fixture(name: "new", published_at: ~U[2026-02-01 00:00:00Z])
      tv = torrent_fixture(name: "tv", category: "Video - Television")

      assert [^tv, ^new, ^old] = Torrents.list_latest_torrents()
      assert [^tv] = Torrents.list_latest_torrents(category_id: tv.category_id)
      assert [^new] = Torrents.list_latest_torrents(limit: 1, category_id: new.category_id)
    end
  end

  describe "search_torrents/2" do
    test "matches on name and respects the category filter" do
      movie = torrent_fixture(name: "Dune Part Two 1080p")
      show = torrent_fixture(name: "Dune Prophecy S01 1080p", category: "Video - Television")
      _other = torrent_fixture(name: "Unrelated")

      ids = Torrents.search_torrents("dune") |> Enum.map(& &1.id)
      assert Enum.sort(ids) == Enum.sort([movie.id, show.id])

      assert [^show] = Torrents.search_torrents("dune", category_id: show.category_id)
      assert [] = Torrents.search_torrents("   ")
    end
  end

  describe "counts" do
    test "count_torrents/0, count_torrents_by_category/0 and latest_published_at/0" do
      assert Torrents.count_torrents() == 0
      assert Torrents.latest_published_at() == nil

      a = torrent_fixture(published_at: ~U[2026-03-01 00:00:00Z])
      b = torrent_fixture(published_at: ~U[2026-03-02 00:00:00Z], category: "Other")

      assert Torrents.count_torrents() == 2
      assert Torrents.count_torrents_by_category() == %{a.category_id => 1, b.category_id => 1}
      assert Torrents.latest_published_at() == ~U[2026-03-02 00:00:00.000000Z]
    end
  end
end
