defmodule MagnetissimoWeb.Format do
  @moduledoc """
  Pure formatting for templates: sizes, counts, ages and hashes.

  Everything here takes plain values and returns strings, so templates stay
  free of arithmetic and the same number reads the same way on every page.
  """

  @units ~w(B KB MB GB TB PB)

  @doc """
  Human-readable file size, one decimal above kilobytes.

      iex> bytes(1_400_000_000)
      "1.4 GB"

  Sizes are decimal (1 KB = 1000 B), which is what every torrent site shows.
  """
  def bytes(nil), do: "—"
  def bytes(n) when is_integer(n) and n < 1000, do: "#{n} B"

  def bytes(n) when is_integer(n) do
    exponent = min(trunc(:math.log10(n) / 3), length(@units) - 1)
    value = n / :math.pow(1000, exponent)
    unit = Enum.at(@units, exponent)

    if value >= 100 or exponent == 1,
      do: "#{round(value)} #{unit}",
      else: "#{:erlang.float_to_binary(value, decimals: 1)} #{unit}"
  end

  @doc """
  Integer with thousands separators.

      iex> number(5120)
      "5,120"
  """
  def number(nil), do: "0"

  def number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  @doc """
  Zero-padded ordinal for torrent numbering: `001`, `042`, `1337`.
  """
  def ordinal(n) when is_integer(n), do: n |> Integer.to_string() |> String.pad_leading(3, "0")

  @doc """
  How long ago `datetime` was, relative to `now`, in the shortest honest unit.

      iex> ago(~U[2026-01-01 00:00:00Z], ~U[2026-01-01 00:03:00Z])
      "3m ago"
  """
  def ago(nil, _now), do: "—"

  def ago(%DateTime{} = datetime, %DateTime{} = now) do
    seconds = DateTime.diff(now, datetime, :second)

    cond do
      seconds < 45 -> "just now"
      seconds < 3600 -> "#{max(div(seconds, 60), 1)}m ago"
      seconds < 86_400 -> "#{div(seconds, 3600)}h ago"
      seconds < 86_400 * 30 -> "#{div(seconds, 86_400)}d ago"
      seconds < 86_400 * 365 -> "#{div(seconds, 86_400 * 30)}mo ago"
      true -> "#{div(seconds, 86_400 * 365)}y ago"
    end
  end

  @doc """
  A full date: `2026.10.09 20:25 UTC`.
  """
  def stamp(nil), do: "—"

  def stamp(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y.%m.%d %H:%M UTC")
  end

  @doc """
  A 40-character infohash in groups of eight, so it can wrap and be read
  back by eye.
  """
  def hash_groups(hash) when is_binary(hash) do
    hash
    |> String.graphemes()
    |> Enum.chunk_every(8)
    |> Enum.map(&Enum.join/1)
  end

  @doc """
  Seed health as a 0–5 rating, shown as sparkles.

  Thresholds follow what users read as healthy: anything under ten seeders
  is a gamble, a thousand is a sure thing.
  """
  def health(seeders) when is_integer(seeders) do
    cond do
      seeders >= 1000 -> 5
      seeders >= 250 -> 4
      seeders >= 50 -> 3
      seeders >= 10 -> 2
      seeders >= 1 -> 1
      true -> 0
    end
  end

  @doc """
  Share of seeders in the swarm, 0–100, for the seed/leech bar.
  """
  def seed_ratio(seeders, leechers) when is_integer(seeders) and is_integer(leechers) do
    case seeders + leechers do
      0 -> 0
      total -> round(seeders / total * 100)
    end
  end
end
