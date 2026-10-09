defmodule MagnetissimoWeb.DossierComponents do
  @moduledoc """
  The pieces the torrent pages are built from: the magnet glyph, category
  chips, the swarm bar, a torrent's bitmap fingerprint, the dossier's signal
  chart.

  Everything here is markup only. Numbers come in already formatted or get
  formatted through `MagnetissimoWeb.Format`.
  """
  use Phoenix.Component

  import Bitwise
  import MagnetissimoWeb.Format

  @doc """
  A pixel magnet, the one icon heroicons doesn't have.
  """
  attr :class, :any, default: "size-4"

  def magnet_icon(assigns) do
    ~H"""
    <svg
      viewBox="0 0 16 16"
      class={@class}
      fill="currentColor"
      aria-hidden="true"
      shape-rendering="crispEdges"
    >
      <path d="M2 5h4v4h1v1h2V9h1V5h4v5h-1v2h-1v1h-1v1H5v-1H4v-1H3v-2H2z" />
      <path d="M2 1h4v4H2zM10 1h4v4h-4z" fill="var(--color-phos-100)" />
    </svg>
    """
  end

  @doc """
  A category as a small bordered chip. Links when `patch` is given.
  """
  attr :name, :string, required: true
  attr :patch, :string, default: nil
  attr :active, :boolean, default: false
  attr :count, :integer, default: nil
  attr :rest, :global

  def category_chip(assigns) do
    ~H"""
    <.link
      :if={@patch}
      patch={@patch}
      class={[chip_classes(@active), "focus-phos"]}
      aria-current={@active && "true"}
      {@rest}
    >
      {short_category(@name)}
      <span :if={@count} class="ml-1 opacity-60">{@count}</span>
    </.link>
    <span :if={!@patch} class={chip_classes(@active)} {@rest}>
      {short_category(@name)}
    </span>
    """
  end

  defp chip_classes(active) do
    [
      "label inline-flex items-center whitespace-nowrap border px-1.5 py-1 leading-none transition",
      if(active,
        do: "border-acid bg-acid/15 text-acid-bright glow-acid",
        else: "border-phos-700 text-phos-300 hover:border-phos-300 hover:text-phos-100"
      )
    ]
  end

  @doc """
  The part of a child category name after the parent: `"Video - Movies"`
  becomes `"Movies"`. Parents and "Other" come back unchanged.
  """
  def short_category(name) do
    case String.split(name, " - ", parts: 2) do
      [_parent, child] -> child
      [name] -> name
    end
  end

  @doc """
  Seeders and leechers with a bar showing the seed share of the swarm.
  """
  attr :seeders, :integer, required: true
  attr :leechers, :integer, required: true
  attr :class, :any, default: nil

  def swarm(assigns) do
    assigns = assign(assigns, :ratio, seed_ratio(assigns.seeders, assigns.leechers))

    ~H"""
    <div class={["font-mono text-xs tabular-nums", @class]}>
      <div class="flex items-baseline justify-between gap-3">
        <span class="text-acid glow-acid" title="seeders">▲ {number(@seeders)}</span>
        <span class="text-rose/80" title="leechers">▼ {number(@leechers)}</span>
      </div>
      <div class="mt-1 h-1 w-full bg-rose/25" role="img" aria-label={"#{@ratio}% seeders"}>
        <div class="h-full bg-acid shadow-[0_0_6px_#cccc33]" style={"width: #{@ratio}%"}></div>
      </div>
    </div>
    """
  end

  @doc """
  Threat assessment, the dossier way: health as stars out of five.
  """
  attr :seeders, :integer, required: true

  def stars(assigns) do
    assigns = assign(assigns, :filled, health(assigns.seeders))

    ~H"""
    <span class="tracking-widest" aria-label={"#{@filled} of 5"}>
      <span class="text-acid glow-acid">{String.duplicate("★", @filled)}</span><span class="text-phos-700">{String.duplicate(
        "★",
        5 - @filled
      )}</span>
    </span>
    """
  end

  @doc """
  A torrent's fingerprint: its infohash drawn as a mirrored 12×12 bitmap.

  The 40 hex characters are 160 bits; the left half of each row takes six and
  the right half mirrors them, so 72 bits in, and every hash gets its own
  symmetrical glyph. Server-rendered SVG, no script involved.
  """
  attr :hash, :string, required: true
  attr :class, :any, default: "size-24"

  def fingerprint(assigns) do
    assigns = assign(assigns, :cells, fingerprint_cells(assigns.hash))

    ~H"""
    <svg
      viewBox="0 0 12 12"
      class={[@class, "drop-shadow-[0_0_6px_rgba(153,204,255,0.8)]"]}
      shape-rendering="crispEdges"
      role="img"
      aria-label="infohash fingerprint"
    >
      <rect :for={{x, y} <- @cells} x={x} y={y} width="1" height="1" fill="currentColor" />
    </svg>
    """
  end

  @doc false
  def fingerprint_cells(hash) do
    bits =
      hash
      |> String.downcase()
      |> Base.decode16!(case: :lower)
      |> :binary.bin_to_list()
      |> Enum.flat_map(fn byte -> for i <- 7..0//-1, do: byte >>> i &&& 1 end)

    for {row, y} <- bits |> Enum.chunk_every(6) |> Enum.take(12) |> Enum.with_index(),
        {bit, x} <- Enum.with_index(row ++ Enum.reverse(row)),
        bit == 1,
        do: {x, y}
  end

  @doc """
  The signal chart at the bottom of the dossier: a grid and two drifting
  waves. Decoration, not data.
  """
  attr :class, :any, default: "h-16 w-full"
  attr :id, :string, required: true

  def signal(assigns) do
    ~H"""
    <svg
      id={@id}
      viewBox="0 0 240 48"
      preserveAspectRatio="none"
      class={["text-phos-500", @class]}
      aria-hidden="true"
    >
      <defs>
        <pattern id={"#{@id}-grid"} width="8" height="8" patternUnits="userSpaceOnUse">
          <path
            d="M8 0H0V8"
            fill="none"
            stroke="currentColor"
            stroke-opacity="0.35"
            stroke-width="0.5"
          />
        </pattern>
      </defs>
      <rect width="240" height="48" fill={"url(##{@id}-grid)"} />
      <g class="animate-drift">
        <path
          d="M0 24 C 15 4, 30 4, 45 24 S 75 44, 90 24 S 120 4, 135 24 S 165 44, 180 24 S 210 4, 225 24 S 255 44, 270 24 S 300 4, 315 24 S 345 44, 360 24"
          fill="none"
          stroke="var(--color-phos-300)"
          stroke-width="1.2"
          style="filter: drop-shadow(0 0 2px rgba(153,204,255,.9))"
        />
        <path
          d="M0 24 C 10 40, 20 40, 30 24 S 50 8, 60 24 S 80 40, 90 24 S 110 8, 120 24 S 140 40, 150 24 S 170 8, 180 24 S 200 40, 210 24 S 230 8, 240 24 S 260 40, 270 24 S 290 8, 300 24 S 320 40, 330 24 S 350 8, 360 24"
          fill="none"
          stroke="var(--color-phos-100)"
          stroke-opacity="0.6"
          stroke-width="0.8"
        />
      </g>
    </svg>
    """
  end

  @doc """
  A row of hex, the way the dossier prints raw memory under the chart.
  """
  attr :hash, :string, required: true
  attr :class, :any, default: nil

  def hexdump(assigns) do
    ~H"""
    <div class={["dossier flex flex-wrap gap-x-3 text-phos-600 text-base leading-tight", @class]}>
      <span :for={group <- hash_groups(@hash)}>{group}</span>
    </div>
    """
  end
end
