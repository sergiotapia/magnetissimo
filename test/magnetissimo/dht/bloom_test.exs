defmodule Magnetissimo.DHT.BloomTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.DHT.Bloom

  defp filter(ips), do: Enum.reduce(ips, Bloom.empty(), &Bloom.insert(&2, &1))

  defp ips(range), do: for(i <- range, do: {10, div(i, 256), rem(i, 256), 1})

  test "an empty filter is zero" do
    assert Bloom.estimate(Bloom.empty()) == 0
  end

  test "estimates the members within a few percent" do
    for n <- [1, 20, 100, 500, 2_000] do
      estimate = Bloom.estimate(filter(ips(1..n)))
      assert abs(estimate - n) <= max(2, n * 0.08), "#{n} members estimated as #{estimate}"
    end
  end

  test "a union counts an address two filters share once" do
    a = filter(ips(1..300))
    b = filter(ips(201..500))

    assert_in_delta Bloom.estimate(Bloom.union([a, b])), 500, 40
  end

  test "a full filter saturates instead of failing" do
    full = :binary.copy(<<255>>, 256)
    assert Bloom.estimate(full) > 7_000
  end
end
