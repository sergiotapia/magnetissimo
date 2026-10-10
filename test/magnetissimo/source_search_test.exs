defmodule Magnetissimo.SourceSearchTest do
  # Not async: the searches write, SQLite takes one writer at a time, and the
  # server and its config are global.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.FastCrawler
  alias Magnetissimo.SlowCrawler
  alias Magnetissimo.SourceSearch
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  setup do
    TorrentsFixtures.seed!()

    previous = Application.get_env(:magnetissimo, SourceSearch)
    configure(crawlers: [FastCrawler, SlowCrawler], ttl: :timer.minutes(1), timeout: 5_000)
    Application.put_env(:magnetissimo, :crawler_test_pid, self())

    on_exit(fn ->
      Application.put_env(:magnetissimo, SourceSearch, previous || [])
      Application.delete_env(:magnetissimo, :crawler_test_pid)
    end)

    # The server remembers terms for the ttl, and the database is rolled back
    # after every test, so every test searches a term no other test has.
    %{term: "term #{System.unique_integer([:positive])}"}
  end

  defp configure(config), do: Application.put_env(:magnetissimo, SourceSearch, config)

  test "every source answers on the term's topic as it lands", %{term: term} do
    key = SourceSearch.key(term)
    :ok = SourceSearch.subscribe(term)

    assert SourceSearch.request(term) == %{"YTS" => :searching, "Nyaa.si" => :searching}

    # The fast source does not wait for the slow one.
    assert_receive {:source_search, ^key, "YTS", {:done, %{inserted: 1, found: 1}}}
    assert_receive {:crawled, "Nyaa.si", ^key, slow}
    refute_received {:source_search_done, ^key, _}
    assert Torrents.count_search_torrents(term) == 1

    send(slow, :go)

    assert_receive {:source_search, ^key, "Nyaa.si", {:done, %{inserted: 1, found: 1}}}
    assert_receive {:source_search_done, ^key, statuses}
    refute SourceSearch.searching?(statuses)
    assert Torrents.count_search_torrents(term) == 2
  end

  test "a term in flight is joined, and a recent one is not asked again", %{term: term} do
    key = SourceSearch.key(term)
    :ok = SourceSearch.subscribe(term)

    SourceSearch.request(term)
    assert_receive {:crawled, "Nyaa.si", ^key, slow}
    assert_receive {:source_search, ^key, "YTS", {:done, _}}

    # The same term, spelled differently, while the slow source is still out.
    assert %{"YTS" => {:done, _}, "Nyaa.si" => :searching} =
             SourceSearch.request("  #{String.upcase(term)} ")

    send(slow, :go)
    assert_receive {:source_search_done, ^key, statuses}

    assert SourceSearch.request(term) == statuses

    assert_received {:crawled, "YTS", ^key, _}
    refute_received {:crawled, _, _, _}
  end

  test "a term asked again after the ttl is searched again", %{term: term} do
    configure(crawlers: [FastCrawler], ttl: 0)
    key = SourceSearch.key(term)
    :ok = SourceSearch.subscribe(term)

    SourceSearch.request(term)
    assert_receive {:source_search_done, ^key, _}

    SourceSearch.request(term)
    assert_receive {:source_search_done, ^key, _}

    assert_received {:crawled, "YTS", ^key, _}
    assert_received {:crawled, "YTS", ^key, _}
  end

  test "a source that fails or crashes is reported, and the others still answer" do
    key = "fail crash"
    :ok = SourceSearch.subscribe(key)
    configure(crawlers: [FastCrawler, SlowCrawler], ttl: 0, timeout: 5_000)

    ExUnit.CaptureLog.capture_log(fn ->
      SourceSearch.request(key)

      assert_receive {:source_search, ^key, "YTS", {:failed, {:crashed, _}}}
      assert_receive {:crawled, "Nyaa.si", ^key, slow}
      send(slow, :go)

      assert_receive {:source_search, ^key, "Nyaa.si", {:done, %{found: 1}}}
      assert_receive {:source_search_done, ^key, _}
    end)
  end

  test "a source that never answers is given up on and stopped", %{term: term} do
    configure(crawlers: [FastCrawler, SlowCrawler], ttl: 0, timeout: 100)
    key = SourceSearch.key(term)
    :ok = SourceSearch.subscribe(term)

    SourceSearch.request(term)
    assert_receive {:crawled, "Nyaa.si", ^key, slow}
    ref = Process.monitor(slow)

    assert_receive {:source_search, ^key, "Nyaa.si", {:failed, :timeout}}, 1_000
    assert_receive {:source_search_done, ^key, %{"YTS" => {:done, _}}}
    assert_receive {:DOWN, ^ref, :process, ^slow, _reason}
  end

  test "await/2 returns once every source has answered", %{term: term} do
    configure(crawlers: [FastCrawler], ttl: :timer.minutes(1))

    assert %{"YTS" => {:done, %{found: 1}}} = SourceSearch.await(term, 5_000)
    assert Torrents.count_search_torrents(term) == 1
  end

  test "await/2 gives up waiting at its timeout", %{term: term} do
    configure(crawlers: [SlowCrawler], ttl: :timer.minutes(1), timeout: 5_000)
    key = SourceSearch.key(term)

    assert SourceSearch.await(term, 50) == %{"Nyaa.si" => :searching}

    # Let the search finish so it is not still writing when the test ends.
    :ok = SourceSearch.subscribe(term)
    assert_receive {:crawled, "Nyaa.si", ^key, slow}
    send(slow, :go)
    assert_receive {:source_search_done, ^key, _}
  end

  test "a term too short to search asks no one" do
    assert SourceSearch.request(" a ") == %{}
    refute_received {:crawled, _, _, _}
  end
end
