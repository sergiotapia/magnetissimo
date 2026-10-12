defmodule Magnetissimo.DHT.BencodeTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Bencode

  defp encode(value), do: value |> Bencode.encode() |> IO.iodata_to_binary()

  test "encodes each type, with dictionary keys sorted" do
    assert encode(42) == "i42e"
    assert encode(-3) == "i-3e"
    assert encode("spam") == "4:spam"
    assert encode(["a", 1]) == "l1:ai1ee"
    assert encode(%{"zz" => 1, "a" => "b"}) == "d1:a1:b2:zzi1ee"
  end

  test "round-trips nested values and raw bytes" do
    value = %{"id" => <<0, 255, 10, 13>>, "list" => [1, ["x", %{}], ""], "n" => 0}
    assert Bencode.decode(encode(value)) == {:ok, value}
  end

  test "decode_prefix returns what follows the value" do
    assert Bencode.decode_prefix("d8:msg_typei1ee" <> <<1, 2, 3>>) ==
             {:ok, %{"msg_type" => 1}, <<1, 2, 3>>}
  end

  test "refuses trailing bytes, truncation and junk without raising" do
    assert Bencode.decode("i1ex") == {:error, :trailing_data}
    assert {:error, _} = Bencode.decode("5:abc")
    assert {:error, _} = Bencode.decode("d3:key")
    assert {:error, _} = Bencode.decode("l")
    assert {:error, _} = Bencode.decode("ie")
    assert {:error, _} = Bencode.decode("i1.5e")
    assert {:error, _} = Bencode.decode("di1ei2ee")
    assert {:error, _} = Bencode.decode("x")
    assert {:error, _} = Bencode.decode("")
  end

  test "a string longer than the input is refused before it is read" do
    assert {:error, :invalid_string} = Bencode.decode("99999999:short")
  end

  test "nesting stops at 64 levels" do
    deep = String.duplicate("l", 100) <> String.duplicate("e", 100)
    assert Bencode.decode(deep) == {:error, :too_deep}

    shallow = String.duplicate("l", 60) <> String.duplicate("e", 60)
    assert {:ok, _} = Bencode.decode(shallow)
  end
end
