defmodule Magnetissimo.DHT.KRPCTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Bencode
  alias Magnetissimo.DHT.KRPC

  @id String.duplicate("a", 20)
  @other String.duplicate("b", 20)

  defp packet(map), do: map |> Bencode.encode() |> IO.iodata_to_binary()

  test "a query is read-only and carries its method and arguments" do
    {:ok, decoded} =
      "aa"
      |> KRPC.query("sample_infohashes", %{"id" => @id, "target" => @other})
      |> IO.iodata_to_binary()
      |> Bencode.decode()

    assert %{"t" => "aa", "y" => "q", "q" => "sample_infohashes", "ro" => 1} = decoded
    assert decoded["a"] == %{"id" => @id, "target" => @other}
  end

  test "reads a sample_infohashes response" do
    nodes = KRPC.encode_nodes([{@other, {{8, 8, 8, 8}, 6881}}, {@id, {{192, 168, 1, 2}, 6881}}])
    hashes = String.duplicate("h", 20) <> String.duplicate("i", 20)

    response =
      packet(%{
        "t" => "xy",
        "y" => "r",
        "r" => %{
          "id" => @id,
          "samples" => hashes,
          "interval" => 21_600,
          "num" => 99,
          "nodes" => nodes
        }
      })

    assert {:ok, {:response, "xy", results}} = KRPC.decode(response)
    assert results.samples == [String.duplicate("h", 20), String.duplicate("i", 20)]
    assert results.interval == 21_600
    assert results.num == 99
    # The private address is unreachable, so it is left out.
    assert results.nodes == [{@other, {{8, 8, 8, 8}, 6881}}]
  end

  test "a node that doesn't sample has no samples, not an empty list" do
    {:ok, {:response, _, results}} =
      KRPC.decode(packet(%{"t" => "1", "y" => "r", "r" => %{"id" => @id}}))

    assert results.samples == nil
    assert results.values == []
  end

  test "reads peers, in a list or as one old-style string" do
    one = KRPC.encode_peer({{1, 2, 3, 4}, 51_413})
    two = KRPC.encode_peer({{5, 6, 7, 8}, 80})

    assert KRPC.peers([one, two]) == [{{1, 2, 3, 4}, 51_413}, {{5, 6, 7, 8}, 80}]
    assert KRPC.peers([one <> two]) == [{{1, 2, 3, 4}, 51_413}, {{5, 6, 7, 8}, 80}]
  end

  test "drops malformed lists and unreachable addresses" do
    assert KRPC.nodes(String.duplicate("x", 27)) == []
    assert KRPC.peers(["short"]) == []
    assert KRPC.peers([KRPC.encode_peer({{1, 2, 3, 4}, 0})]) == []
    refute KRPC.dialable?({10, 0, 0, 1}, 6881)
    refute KRPC.dialable?({127, 0, 0, 1}, 6881)
    refute KRPC.dialable?({172, 20, 0, 1}, 6881)
    refute KRPC.dialable?({239, 1, 1, 1}, 6881)
    assert KRPC.dialable?({172, 32, 0, 1}, 6881)
  end

  test "reads the scrape bloom filters" do
    filter = :binary.copy(<<0>>, 256)

    {:ok, {:response, _, results}} =
      KRPC.decode(
        packet(%{"t" => "1", "y" => "r", "r" => %{"id" => @id, "BFsd" => filter, "BFpe" => "x"}})
      )

    assert results.bfsd == filter
    assert results.bfpe == nil
  end

  test "reads errors, and refuses a response without a proper id" do
    assert KRPC.decode(packet(%{"t" => "1", "y" => "e", "e" => [201, "Generic Error"]})) ==
             {:ok, {:error, "1", 201, "Generic Error"}}

    assert KRPC.decode(packet(%{"t" => "1", "y" => "r", "r" => %{"id" => "short"}})) ==
             {:error, :bad_id}

    assert {:error, _} = KRPC.decode("garbage")
  end
end
