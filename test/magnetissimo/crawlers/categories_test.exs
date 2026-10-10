defmodule Magnetissimo.Crawlers.CategoriesTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Magnetissimo.Crawlers
  alias Magnetissimo.Crawlers.AudioBookBay
  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Eztv
  alias Magnetissimo.Crawlers.Nyaa
  alias Magnetissimo.Crawlers.Sukebei
  alias Magnetissimo.Crawlers.ThePirateBay
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.Taxonomy

  # Every category each site publishes, as read off the site on 2026-10-10:
  # Nyaa's and Sukebei's category menus (the ids their feeds send as
  # nyaa:categoryId), the names in TorrentDownloads' feed, and the qualities
  # the YTS API lists, and the ids The Pirate Bay's main.js names. EZTV has no
  # categories, only TV, so the resolutions its release names carry stand in.
  # AudioBookBay's categories are genres of audiobook, which all file under
  # its fallback, so it maps none. When a site adds one,
  # it belongs here and in the crawler's mapping.
  @site_categories %{
    AudioBookBay => [],
    Eztv => ~w(480p 720p 1080p 2160p),
    Nyaa => ~w(1_0 1_1 1_2 1_3 1_4 2_0 2_1 2_2 3_0 3_1 3_2 3_3 4_0 4_1 4_2 4_3 4_4
               5_0 5_1 5_2 6_0 6_1 6_2),
    Sukebei => ~w(1_0 1_1 1_2 1_3 1_4 1_5 2_0 2_1 2_2),
    ThePirateBay => ~w(100 101 102 103 104 199 200 201 202 203 204 205 206 207 208 209
                       210 211 212 299 300 301 302 303 304 305 306 399 400 401 402
                       403 404 405 406 407 408 499 500 501 502 503 504 505 506 507
                       599 600 601 602 603 604 605 699),
    TorrentDownloads => [
      "Anime",
      "Books",
      "Games",
      "Movies",
      "Music",
      "Software",
      "TV Shows",
      "Other"
    ],
    Yts => ~w(480p 720p 1080p 2160p 3D)
  }

  test "every crawler maps every category its site publishes" do
    assert Map.keys(@site_categories) |> Enum.sort() == Enum.sort(Crawlers.all())

    for {crawler, keys} <- @site_categories, key <- keys do
      assert Map.has_key?(crawler.categories().ids, key),
             "#{inspect(crawler)} has no mapping for its site's #{inspect(key)}"
    end
  end

  test "nothing from an adult source can land outside XXX" do
    mapping = Sukebei.categories()
    xxx = Taxonomy.family_ids(Taxonomy.xxx_id())

    assert mapping.fallback in xxx

    for {key, id} <- mapping.ids do
      assert id in xxx, "Sukebei's #{key} maps outside XXX"
    end
  end

  test "nothing from a work-safe source lands in XXX" do
    xxx = Taxonomy.family_ids(Taxonomy.xxx_id())

    for crawler <- Crawlers.all() -- [Sukebei, ThePirateBay],
        {key, id} <- crawler.categories().ids do
      refute id in xxx, "#{inspect(crawler)}'s #{key} maps into XXX"
    end
  end

  test "The Pirate Bay files into XXX only from its Porn group" do
    mapping = ThePirateBay.categories()
    xxx = Taxonomy.family_ids(Taxonomy.xxx_id())

    refute mapping.fallback in xxx

    for {key, id} <- mapping.ids do
      assert id in xxx == String.starts_with?(key, "5"),
             "The Pirate Bay's #{key} is filed #{if id in xxx, do: "in", else: "outside"} XXX"
    end
  end

  test "a name outside the taxonomy cannot be mapped" do
    assert_raise ArgumentError, fn ->
      Categories.mapping!("Site", %{"1" => "Anime"}, fallback: "Other")
    end

    assert_raise ArgumentError, fn -> Categories.mapping!("Site", %{}, fallback: "Nope") end
  end

  test "a missing category falls back quietly, an unknown one is logged" do
    mapping = Categories.mapping!("Site", %{"tv" => "TV"}, fallback: "Other")

    assert Categories.resolve(mapping, "tv") == 5000

    assert capture_log(fn ->
             assert Categories.resolve(mapping, nil) == 8000
             assert Categories.resolve(mapping, "") == 8000
           end) == ""

    assert capture_log(fn -> assert Categories.resolve(mapping, "new") == 8000 end) =~
             ~s([Site] unmapped category "new")
  end
end
