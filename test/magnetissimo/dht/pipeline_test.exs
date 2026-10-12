defmodule Magnetissimo.DHT.PipelineTest do
  # Not async: the crawler writes to the database from its own processes.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.DHT.Bloom
  alias Magnetissimo.DHT.FakeMetadata
  alias Magnetissimo.DHT.FakeTransport
  alias Magnetissimo.DHT.KRPC
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias Magnetissimo.TorrentsFixtures

  @router {{1, 2, 3, 4}, 6881}
  @sampler {{5, 6, 7, 8}, 6881}
  @peer {{9, 9, 9, 9}, 51_413}

  setup do
    TorrentsFixtures.seed!()
    FakeTransport.listen()
    :ok = DHT.subscribe()
    :ok
  end

  defp info(name, files) do
    %{"name" => name, "piece length" => 262_144, "pieces" => "", "files" => files}
    |> Bencode.encode()
    |> IO.iodata_to_binary()
  end

  defp start_crawler do
    start_supervised!({Task.Supervisor, name: DHT.TaskSupervisor})
    start_supervised!({DHT.Node, rate: 1_000, transport: FakeTransport})
    start_supervised!(DHT.Indexer)
    start_supervised!({DHT.Fetcher, fetches: 2, metadata: FakeMetadata})

    start_supervised!(
      {DHT.Sampler,
       rate: 1_000, bootstrap: [{"1.2.3.4", 6881}], persist: false, backlog_limit: 100}
    )
  end

  # Answers queries as they come, until `fun` returns `:done`, or `{:last,
  # results}` to answer and then stop.
  defp serve(fun) do
    receive do
      {:dht_sent, node, {ip, port} = address, packet} ->
        {:ok, %{"t" => tid, "q" => method, "a" => args}} = Bencode.decode(packet)

        reply = fn results ->
          reply = %{
            "t" => tid,
            "y" => "r",
            "r" => Map.put(results, "id", :crypto.strong_rand_bytes(20))
          }

          send(node, {:udp, self(), ip, port, IO.iodata_to_binary(Bencode.encode(reply))})
        end

        case fun.(address, method, args) do
          :done ->
            :ok

          :ignore ->
            serve(fun)

          {:last, results} ->
            reply.(results)

          results ->
            reply.(results)
            serve(fun)
        end
    after
      5_000 -> flunk("the crawler stopped asking")
    end
  end

  test "walks from a router to a node, fetches what it samples, files it and estimates its swarm" do
    metadata =
      info("Some.Show.S01.1080p", [
        %{"length" => 700_000_000, "path" => ["Some.Show.S01E01.1080p.mkv"]},
        %{"length" => 650_000_000, "path" => ["Some.Show.S01E02.1080p.mkv"]}
      ])

    banned = info("pthc", [%{"length" => 5_000, "path" => ["x.mp4"]}])
    hash = :crypto.hash(:sha, metadata)
    FakeMetadata.serve([metadata, banned])

    seeds = Enum.reduce(1..30, Bloom.empty(), &Bloom.insert(&2, {10, 0, 0, &1}))
    peers = Enum.reduce(1..5, Bloom.empty(), &Bloom.insert(&2, {10, 1, 0, &1}))

    start_crawler()

    serve(fn
      @router, "find_node", _args ->
        %{"nodes" => KRPC.encode_nodes([{String.duplicate("s", 20), @sampler}])}

      @sampler, "sample_infohashes", _args ->
        %{"samples" => hash <> :crypto.hash(:sha, banned), "interval" => 3_600, "num" => 2}

      @sampler, "get_peers", %{"scrape" => 1} ->
        send(self(), :scraped)
        %{"BFsd" => seeds, "BFpe" => peers, "token" => "t"}

      @sampler, "get_peers", _args ->
        %{"values" => [KRPC.encode_peer(@peer)], "token" => "t"}

      _address, _method, _args ->
        if_scraped()
    end)

    assert_receive {:dht_indexed, [torrent]}, 5_000
    assert torrent.name == "Some.Show.S01.1080p"
    assert torrent.source.name == "DHT"
    assert torrent.category_id == Taxonomy.id!("TV/HD")
    assert torrent.size_in_bytes == 1_350_000_000
    assert torrent.file_count == 2
    assert torrent.magnet_hash == Base.encode16(hash, case: :lower)

    assert_receive {:dht_swarm, %{id: id, seeders: seeders, leechers: leechers}}, 5_000
    assert id == torrent.id
    assert_in_delta seeders, 30, 3
    assert_in_delta leechers, 5, 2

    # The banned one was fetched and refused.
    assert [%{name: "Some.Show.S01.1080p"}] = Torrents.list_dht_torrents()
  end

  test "a hash already indexed is never fetched again" do
    known = TorrentsFixtures.torrent_fixture(%{name: "Already Here"})
    {:ok, hash} = Base.decode16(known.magnet_hash, case: :lower)
    start_crawler()

    serve(fn
      @router, "find_node", _args ->
        %{"nodes" => KRPC.encode_nodes([{String.duplicate("s", 20), @sampler}])}

      @sampler, "sample_infohashes", _args ->
        {:last, %{"samples" => hash, "interval" => 3_600}}

      _address, _method, _args ->
        :ignore
    end)

    # Nothing more is asked about it once the fetcher has checked the index.
    refute_get_peers(1_500)
  end

  defp refute_get_peers(timeout) do
    receive do
      {:dht_sent, _node, _address, packet} ->
        {:ok, %{"q" => method}} = Bencode.decode(packet)
        refute method == "get_peers"
        refute_get_peers(timeout)
    after
      timeout -> :ok
    end
  end

  # After the scrape, the crawler has nothing left to ask.
  defp if_scraped do
    receive do
      :scraped -> :done
    after
      0 -> :ignore
    end
  end
end
