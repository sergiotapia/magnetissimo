defmodule Magnetissimo.SeedsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test, so two tests that both write cannot run at
  # the same time however long the busy timeout is.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Seeds
  alias Magnetissimo.Torrents

  test "a source already in the table has its url refreshed" do
    Seeds.run()
    source = Torrents.get_source_by_name!("YTS")

    # yts.mx stopped resolving, so a database seeded before the url moved must
    # pick the new one up on the next run rather than keep the dead host.
    Repo.update!(Ecto.Changeset.change(source, url: "https://yts.mx/"))
    Seeds.run()

    assert Torrents.get_source_by_name!("YTS").url != "https://yts.mx/"
  end

  test "running twice leaves one row per source" do
    Seeds.run()
    Seeds.run()

    assert Torrents.list_sources() |> Enum.map(& &1.name) |> Enum.sort() ==
             ["1337x", "Nyaa.si", "Sukebei", "TorrentDownloads", "YTS"]
  end

  test "every category Sukebei files under resolves to a real category" do
    Seeds.run()

    for {site, ours} <- [
          {"Art - Anime", "Anime - Raw"},
          {"Art - Doujinshi", "Books - Raw"},
          {"Art - Manga", "Books - Raw"},
          {"Art - Games", "Software - Games"},
          {"Art - Pictures", "Images - Graphics"},
          {"Real Life - Photobooks / Pictures", "Images - Photos"},
          {"Real Life - Videos", "Video - XXX"}
        ] do
      assert Torrents.get_category_by_name_or_alias!(site).name == ours
    end
  end
end
