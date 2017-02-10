defmodule Magnetissimo.MagnetKVTest do
  use ExUnit.Case, async: true

  alias Magnetissimo.MagnetKV

  setup do
    {:ok, _} = MagnetKV.start_link
    :ok
  end

  test "when magnet is not cached, returns false" do
    not_cached_magnet = "not_cached_magnet"
    assert MagnetKV.cached?(not_cached_magnet) == false
  end

	test "caches magnet, returns :ok and timestamp" do
		cached_magnet = "cached_magnet"
		timestamp = :os.system_time(:seconds)
		assert {:ok, timestamp} == MagnetKV.cache(cached_magnet)
	end

	test "when magnet is cached, returns :ok and timestamp" do
		magnet = "magnet"
    {:ok, timestamp} = MagnetKV.cache(magnet)
    IO.puts "timestamp: #{timestamp}"
    assert match?({:ok, timestamp}, MagnetKV.cached?(magnet))
  end
end
