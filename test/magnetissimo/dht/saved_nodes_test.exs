defmodule Magnetissimo.DHT.SavedNodesTest do
  # Not async: every test here writes, and SQLite takes one writer at a time.
  use Magnetissimo.DataCase, async: false

  alias Magnetissimo.DHT

  defp dht_node(i), do: {String.duplicate(<<i>>, 20), {{8, 8, div(i, 256), rem(i, 256)}, 6881}}

  test "a short run adds its nodes to what a long run saved" do
    :ok = DHT.save_nodes(Enum.map(1..50, &dht_node/1))
    :ok = DHT.save_nodes([dht_node(51), dht_node(1)])

    assert Enum.count(DHT.load_nodes()) == 51
  end

  test "a node saved again takes its new id" do
    {_id, address} = dht_node(1)
    :ok = DHT.save_nodes([dht_node(1)])
    :ok = DHT.save_nodes([{String.duplicate("z", 20), address}])

    assert DHT.load_nodes() == [{String.duplicate("z", 20), address}]
  end
end
