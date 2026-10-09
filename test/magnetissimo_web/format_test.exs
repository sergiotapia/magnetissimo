defmodule MagnetissimoWeb.FormatTest do
  use ExUnit.Case, async: true

  import MagnetissimoWeb.Format

  doctest MagnetissimoWeb.Format

  test "bytes/1 picks the unit and rounds sensibly" do
    assert bytes(nil) == "—"
    assert bytes(512) == "512 B"
    assert bytes(130_000_000) == "130 MB"
    assert bytes(1_400_000_000) == "1.4 GB"
    assert bytes(62_000_000_000) == "62.0 GB"
    assert bytes(120_000_000_000) == "120 GB"
    assert bytes(3_100_000_000_000) == "3.1 TB"
  end

  test "number/1 groups thousands" do
    assert number(nil) == "0"
    assert number(7) == "7"
    assert number(1204) == "1,204"
    assert number(62_000_000_000) == "62,000,000,000"
  end

  test "ago/2 picks the largest whole unit" do
    now = ~U[2026-10-09 12:00:00Z]
    assert ago(nil, now) == "—"
    assert ago(~U[2026-10-09 11:59:40Z], now) == "just now"
    assert ago(~U[2026-10-09 11:30:00Z], now) == "30m ago"
    assert ago(~U[2026-10-09 07:00:00Z], now) == "5h ago"
    assert ago(~U[2026-10-01 12:00:00Z], now) == "8d ago"
    assert ago(~U[2026-06-09 12:00:00Z], now) == "4mo ago"
    assert ago(~U[2023-10-09 12:00:00Z], now) == "3y ago"
  end

  test "stamp/1 and hash_groups/1" do
    assert stamp(~U[2026-10-09 20:25:59Z]) == "2026.10.09 20:25 UTC"

    assert hash_groups("0fb89b2883ba7e654bd0e45d3b90e072e3f7e80e") == [
             "0fb89b28",
             "83ba7e65",
             "4bd0e45d",
             "3b90e072",
             "e3f7e80e"
           ]
  end

  test "health/1 and seed_ratio/2" do
    assert health(0) == 0
    assert health(1) == 1
    assert health(50) == 3
    assert health(5120) == 5
    assert seed_ratio(0, 0) == 0
    assert seed_ratio(75, 25) == 75
  end
end
