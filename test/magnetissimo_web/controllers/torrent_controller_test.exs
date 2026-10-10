defmodule MagnetissimoWeb.TorrentControllerTest do
  # Not async: the search writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  alias Magnetissimo.TorrentsFixtures

  setup :stub_sources

  test "search answers with the index and what the sources found", %{conn: conn} do
    TorrentsFixtures.torrent_fixture(%{name: "Fixture Movie Collection"})

    names =
      conn
      |> get(~p"/api/search/Fixture Movie")
      |> json_response(200)
      |> Map.fetch!("data")
      |> Enum.map(& &1["name"])

    assert "Fixture Movie Collection" in names
    assert Enum.count(names, &(&1 == "Fixture Movie (2024)")) == 2
  end
end
