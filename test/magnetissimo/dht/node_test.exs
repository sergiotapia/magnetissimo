defmodule Magnetissimo.DHT.NodeTest do
  # Not async: the fake transport hands packets to one test at a time.
  use ExUnit.Case, async: false

  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.DHT.FakeTransport
  alias Magnetissimo.DHT.Node

  @peer {{8, 8, 8, 8}, 6881}
  @id String.duplicate("n", 20)

  setup do
    FakeTransport.listen()
    :ok
  end

  defp start(rate) do
    start_supervised!({Node, rate: rate, transport: FakeTransport, name: nil})
  end

  defp ask(node, address \\ @peer) do
    Task.async(fn -> Node.query(address, "ping", %{}, server: node) end)
  end

  defp respond(node, {ip, port}, packet, results) do
    {:ok, %{"t" => tid}} = Bencode.decode(packet)
    reply = %{"t" => tid, "y" => "r", "r" => Map.put(results, "id", @id)}
    send(node, {:udp, self(), ip, port, IO.iodata_to_binary(Bencode.encode(reply))})
  end

  test "sends a read-only query with our id and returns the answer" do
    node = start(100)
    task = ask(node)

    assert_receive {:dht_sent, ^node, @peer, packet}

    assert {:ok, %{"q" => "ping", "ro" => 1, "a" => %{"id" => <<_::binary-size(20)>>}}} =
             Bencode.decode(packet)

    respond(node, @peer, packet, %{})
    assert {:ok, %{id: @id}} = Task.await(task)
  end

  test "an answer from another address than the one asked is ignored" do
    node = start(100)
    task = ask(node)
    assert_receive {:dht_sent, ^node, @peer, packet}

    respond(node, {{9, 9, 9, 9}, 6881}, packet, %{})
    respond(node, @peer, packet, %{"token" => "real"})

    assert {:ok, %{token: "real"}} = Task.await(task)
  end

  test "a node's error answer is an error" do
    node = start(100)
    task = ask(node)
    assert_receive {:dht_sent, ^node, {ip, port}, packet}
    {:ok, %{"t" => tid}} = Bencode.decode(packet)

    error = Bencode.encode(%{"t" => tid, "y" => "e", "e" => [204, "Method Unknown"]})
    send(node, {:udp, self(), ip, port, IO.iodata_to_binary(error)})

    assert Task.await(task) == {:error, {:krpc, 204}}
  end

  test "holds packets to the rate, and answers busy when the queue is full" do
    # 1 packet a second, a burst of 1, a queue of 10.
    node = start(1)
    tasks = for i <- 1..12, do: ask(node, {{8, 8, 8, i}, 6881})

    assert_receive {:dht_sent, ^node, _address, _packet}
    refute_receive {:dht_sent, ^node, _address, _packet}, 300

    # The first was sent, ten wait, the last found the queue full.
    assert {:error, :busy} in Enum.map(Enum.take(tasks, -1), &Task.await/1)
    summary = Node.summary(node)
    assert summary.waiting == 10
    assert summary.flows_30s == 1
  end

  test "incoming queries are ignored: we are read-only" do
    node = start(100)
    query = Bencode.encode(%{"t" => "q1", "y" => "q", "q" => "ping", "a" => %{"id" => @id}})
    send(node, {:udp, self(), {8, 8, 8, 8}, 6881, IO.iodata_to_binary(query)})

    _ = :sys.get_state(node)
    refute_received {:dht_sent, ^node, _address, _packet}
  end
end
