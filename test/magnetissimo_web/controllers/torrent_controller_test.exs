defmodule MagnetissimoWeb.TorrentControllerTest do
  # Not async: the search writes, and SQLite takes one writer at a time.
  use MagnetissimoWeb.ConnCase, async: false

  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures

  setup do
    TorrentsFixtures.seed!()

    Req.Test.set_req_test_to_shared()
    Req.Test.stub(Yts, fn conn -> Req.Test.json(conn, YtsFixtures.api_response()) end)
    Req.Test.stub(Feed, &Plug.Conn.send_resp(&1, 200, "<rss></rss>"))
    Req.Test.stub(TorrentDownloads, &Plug.Conn.send_resp(&1, 200, "<rss></rss>"))

    previous = Application.get_env(:magnetissimo, SourceSearch)
    Application.put_env(:magnetissimo, SourceSearch, ttl: 0)
    on_exit(fn -> Application.put_env(:magnetissimo, SourceSearch, previous || []) end)

    :ok
  end

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
