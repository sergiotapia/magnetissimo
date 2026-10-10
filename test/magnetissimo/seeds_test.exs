defmodule Magnetissimo.SeedsTest do
  # Not async: SQLite has a single writer and the sandbox holds a write
  # transaction for the whole test, so two tests that both write cannot run at
  # the same time however long the busy timeout is.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.Crawlers
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

  test "there is one source row per crawler, however often it runs" do
    Seeds.run()
    Seeds.run()

    assert Torrents.list_sources() |> Enum.map(& &1.name) |> Enum.sort() ==
             Crawlers.all() |> Enum.map(& &1.source_name()) |> Enum.sort()
  end
end
