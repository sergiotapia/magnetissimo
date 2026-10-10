defmodule MagnetissimoWeb.ConnCase do
  @moduledoc """
  The case for tests that go through the router: each test gets a `conn`, and
  its own SQL sandbox (shared when the test isn't async), so database changes
  roll back when it ends.
  """

  use ExUnit.CaseTemplate

  alias Magnetissimo.Crawlers.AudioBookBay
  alias Magnetissimo.Crawlers.Nyaa.Feed
  alias Magnetissimo.Crawlers.ThePirateBay
  alias Magnetissimo.Crawlers.TorrentDownloads
  alias Magnetissimo.Crawlers.Yts
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.TorrentsFixtures
  alias Magnetissimo.YtsFixtures
  alias Plug.Conn
  alias Req.Test

  using do
    quote do
      # The default endpoint for testing
      @endpoint MagnetissimoWeb.Endpoint

      use MagnetissimoWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MagnetissimoWeb.ConnCase
    end
  end

  setup tags do
    Magnetissimo.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Seeds the sources and stubs every one of them for a test that searches:
  YTS answers with `Magnetissimo.YtsFixtures.api_response/0` and the
  others with an empty feed or page. Use as `setup :stub_sources`.

  The sources are asked from `Magnetissimo.SourceSearch`'s own tasks, not the
  test process, so the stubs are shared with every process. The database is
  rolled back after every test, so the search cache is turned off too: a term
  the last test searched must not count as searched in this one.
  """
  def stub_sources(_context) do
    TorrentsFixtures.seed!()

    Test.set_req_test_to_shared()

    Test.stub(Yts, fn conn ->
      Test.json(conn, YtsFixtures.api_response())
    end)

    Test.stub(Feed, &Conn.send_resp(&1, 200, "<rss></rss>"))
    Test.stub(TorrentDownloads, &Conn.send_resp(&1, 200, "<rss></rss>"))
    # An empty page is both an empty feed and a search that matched nothing.
    Test.stub(AudioBookBay, &Conn.send_resp(&1, 200, "<html></html>"))
    Test.stub(ThePirateBay, &Test.json(&1, []))

    previous = Application.get_env(:magnetissimo, SourceSearch)
    Application.put_env(:magnetissimo, SourceSearch, ttl: 0)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(:magnetissimo, SourceSearch, previous || [])
    end)

    :ok
  end
end
