defmodule MagnetissimoWeb.DossierComponents do
  @moduledoc """
  The pieces the torrent pages are built from: the magnet glyph, sparkles,
  category chips, the swarm bar, health sparkles, a torrent's fingerprint,
  the pearl orb, the CD and the wave chart.

  Everything here is markup only. Numbers come in already formatted or get
  formatted through `MagnetissimoWeb.Format`.
  """
  use Phoenix.Component

  import Bitwise
  import MagnetissimoWeb.Format

  @doc """
  A rounded magnet, the one icon heroicons doesn't have.
  """
  attr :class, :any, default: "size-4"

  def magnet_icon(assigns) do
    ~H"""
    <svg viewBox="4 4.5 24 24" class={@class} fill="currentColor" aria-hidden="true">
      <g transform="rotate(45 16 16.5)">
        <path d="M9 13.2h5V18a2 2 0 0 0 4 0v-4.8h5V18a7 7 0 0 1-14 0z" />
        <path d="M9 8h5v4.2H9zM18 8h5v4.2h-5z" fill-opacity="0.55" />
      </g>
    </svg>
    """
  end

  @doc """
  A four-point sparkle. Position it with `class`; it twinkles on its own.
  """
  attr :class, :any, required: true

  def sparkle(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" class={["sparkle", @class]} fill="currentColor" aria-hidden="true">
      <path d="M12 0c.6 6.2 5.8 11.4 12 12-6.2.6-11.4 5.8-12 12-.6-6.2-5.8-11.4-12-12C6.2 11.4 11.4 6.2 12 0z" />
    </svg>
    """
  end

  @doc """
  A category as a small pill. Links when `patch` is given.

  Shows the full Torznab name (`"Movies/UHD"`), or with `short` only the part
  after the parent (`"UHD"`), for where the parent is already on screen.
  """
  attr :category, Magnetissimo.Taxonomy.Category, required: true
  attr :short, :boolean, default: false
  attr :patch, :string, default: nil
  attr :active, :boolean, default: false
  attr :count, :integer, default: nil
  attr :rest, :global

  def category_chip(assigns) do
    ~H"""
    <.link
      :if={@patch}
      patch={@patch}
      class={[chip_classes(@active), "focus-ring"]}
      aria-current={@active && "true"}
      {@rest}
    >
      {if @short, do: @category.label, else: @category.name}
      <span
        :if={@count}
        class={[
          "ml-1.5 rounded-full px-1.5 py-px font-mono text-[0.65rem]",
          if(@active, do: "bg-white/25", else: "bg-azure-100 text-azure-600")
        ]}
      >
        {@count}
      </span>
    </.link>
    <span :if={!@patch} class={chip_classes(@active)} title={@category.name} {@rest}>
      {if @short, do: @category.label, else: @category.name}
    </span>
    """
  end

  defp chip_classes(true) do
    "gel inline-flex items-center whitespace-nowrap px-3 py-1 text-xs font-semibold leading-none"
  end

  defp chip_classes(_inactive) do
    "pill inline-flex items-center whitespace-nowrap px-3 py-1 text-xs font-semibold leading-none"
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
        <span class="font-bold text-mint" title="seeders">▲ {number(@seeders)}</span>
        <span class="text-bubble" title="leechers">▼ {number(@leechers)}</span>
      </div>
      <div
        class="mt-1 h-1.5 w-full overflow-hidden rounded-full bg-bubble-soft"
        role="img"
        aria-label={"#{@ratio}% seeders"}
      >
        <div
          class="h-full rounded-full bg-linear-to-r from-mint to-[#5fd4b4]"
          style={"width: #{@ratio}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Swarm health as sparkles out of five.
  """
  attr :seeders, :integer, required: true

  def stars(assigns) do
    assigns = assign(assigns, :filled, health(assigns.seeders))

    ~H"""
    <span class="tracking-[0.2em]" aria-label={"#{@filled} of 5"}>
      <span class="text-azure-500">{String.duplicate("✦", @filled)}</span><span class="text-frost-300">{String.duplicate(
        "✦",
        5 - @filled
      )}</span>
    </span>
    """
  end

  @doc """
  A torrent's fingerprint: its infohash drawn as a mirrored 12×12 grid of
  beads.

  The 40 hex characters are 160 bits; the left half of each row takes six and
  the right half mirrors them, so 72 bits in, and every hash gets its own
  symmetrical glyph. Server-rendered SVG, no script involved.
  """
  attr :hash, :string, required: true
  attr :class, :any, default: "size-24"

  def fingerprint(assigns) do
    assigns = assign(assigns, :cells, fingerprint_cells(assigns.hash))

    ~H"""
    <svg viewBox="0 0 12 12" class={@class} role="img" aria-label="infohash fingerprint">
      <defs>
        <linearGradient id={"fp-#{@hash}"} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="var(--color-azure-500)" />
          <stop offset="1" stop-color="var(--color-aqua)" />
        </linearGradient>
      </defs>
      <rect
        :for={{x, y} <- @cells}
        x={x + 0.08}
        y={y + 0.08}
        width="0.84"
        height="0.84"
        rx="0.32"
        fill={"url(#fp-#{@hash})"}
      />
    </svg>
    """
  end

  defp fingerprint_cells(hash) do
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
  A pearl orb. The seed picks where its colours start and a small hue shift,
  so the home page and each torrent get their own. Pure CSS.
  """
  attr :seed, :string, required: true
  attr :class, :any, default: "size-28"
  attr :rest, :global

  def orb(assigns) do
    hash = :erlang.phash2(assigns.seed, 3600)
    assigns = assign(assigns, turn: rem(hash, 360), hue: div(hash, 360) * 6 - 30)

    ~H"""
    <div
      class={["orb animate-float", @class]}
      style={"--orb-turn: #{@turn}deg; --orb-hue: #{@hue}deg"}
      aria-hidden="true"
      {@rest}
    >
    </div>
    """
  end

  @doc """
  A CD that spins, for the now-playing ticker.
  """
  attr :class, :any, default: "size-6"

  def disc(assigns) do
    ~H"""
    <span class={["disc animate-spin-slow inline-block shrink-0", @class]} aria-hidden="true"></span>
    """
  end

  @doc """
  Two soft waves drifting under a panel, like a stereo's visualiser.
  Decoration, not data.
  """
  attr :class, :any, default: "h-16 w-full"
  attr :id, :string, required: true

  def signal(assigns) do
    ~H"""
    <svg
      id={@id}
      viewBox="0 0 240 48"
      preserveAspectRatio="none"
      class={@class}
      aria-hidden="true"
    >
      <defs>
        <linearGradient id={"#{@id}-fill"} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="var(--color-azure-400)" stop-opacity="0.35" />
          <stop offset="1" stop-color="var(--color-azure-400)" stop-opacity="0" />
        </linearGradient>
      </defs>
      <g class="animate-drift">
        <path
          d="M0 24 C 15 4, 30 4, 45 24 S 75 44, 90 24 S 120 4, 135 24 S 165 44, 180 24 S 210 4, 225 24 S 255 44, 270 24 S 300 4, 315 24 S 345 44, 360 24 V48 H0 Z"
          fill={"url(##{@id}-fill)"}
        />
        <path
          d="M0 24 C 15 4, 30 4, 45 24 S 75 44, 90 24 S 120 4, 135 24 S 165 44, 180 24 S 210 4, 225 24 S 255 44, 270 24 S 300 4, 315 24 S 345 44, 360 24"
          fill="none"
          stroke="var(--color-azure-500)"
          stroke-width="1.4"
          stroke-linecap="round"
        />
        <path
          d="M0 24 C 10 40, 20 40, 30 24 S 50 8, 60 24 S 80 40, 90 24 S 110 8, 120 24 S 140 40, 150 24 S 170 8, 180 24 S 200 40, 210 24 S 230 8, 240 24 S 260 40, 270 24 S 290 8, 300 24 S 320 40, 330 24 S 350 8, 360 24"
          fill="none"
          stroke="var(--color-aqua)"
          stroke-opacity="0.8"
          stroke-width="1"
          stroke-linecap="round"
        />
      </g>
    </svg>
    """
  end

  @doc """
  The infohash in groups of four, small and quiet under the fingerprint.
  """
  attr :hash, :string, required: true
  attr :class, :any, default: nil

  def hexdump(assigns) do
    ~H"""
    <div class={[
      "flex flex-wrap gap-x-2 font-mono text-[0.7rem] leading-relaxed text-ink-300",
      @class
    ]}>
      <span :for={group <- hash_groups(@hash)}>{group}</span>
    </div>
    """
  end
end
