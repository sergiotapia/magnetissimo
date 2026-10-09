defmodule MagnetissimoWeb.TorrentLive do
  @moduledoc """
  One torrent as a subject dossier: fingerprint, the facts in rows, the
  magnet, and whatever the source said about it.
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Torrents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    torrent = Torrents.get_torrent!(id)

    {:ok,
     socket
     |> assign(:page_title, torrent.name)
     |> assign(:torrent, torrent)
     |> assign(:now, DateTime.utc_now())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <nav class="label mb-3 flex items-center gap-2 text-phos-500" aria-label="Breadcrumb">
        <.link navigate={~p"/"} class="hover:text-phos-300">Index</.link>
        <span aria-hidden="true">/</span>
        <.link
          navigate={~p"/?#{[category: @torrent.category_id]}"}
          class="hover:text-phos-300"
        >
          {@torrent.category.name}
        </.link>
        <span aria-hidden="true">/</span>
        <span class="text-phos-300">Subject {ordinal(@torrent.id)}</span>
      </nav>

      <article id={"torrent-#{@torrent.id}"} class="panel animate-boot">
        <header class="panel-title">
          <span>Subject {ordinal(@torrent.id)}</span>
          <span class="flex items-center gap-2">
            <span class="label hidden text-phos-500 sm:inline">{@torrent.source.name}</span>
            <span class="flex h-3 w-6 items-center border border-phos-300 p-px" aria-hidden="true">
              <span class="h-full bg-phos-300" style={"width: #{health(@torrent.seeders) * 20}%"}></span>
            </span>
          </span>
        </header>

        <div class="grid gap-px bg-phos-500/20 md:grid-cols-[18rem_1fr]">
          <%!-- Left: fingerprint and visual --%>
          <div class="grid gap-px bg-phos-500/20 sm:grid-cols-2 md:grid-cols-1">
            <div class="bg-ink-900/95 p-5">
              <div class="label mb-3 text-phos-500">Fingerprint</div>
              <div class="relative mx-auto w-fit border border-phos-500/30 p-4">
                <span class="absolute -top-px -left-px size-3 border-t border-l border-phos-300"></span>
                <span class="absolute -top-px -right-px size-3 border-t border-r border-phos-300"></span>
                <span class="absolute -bottom-px -left-px size-3 border-b border-l border-phos-300"></span>
                <span class="absolute -bottom-px -right-px size-3 border-r border-b border-phos-300"></span>
                <.fingerprint hash={@torrent.magnet_hash} class="size-32 text-phos-300" />
              </div>
              <.hexdump hash={@torrent.magnet_hash} class="mt-4 justify-center" />
            </div>

            <div class="bg-ink-900/95 p-5">
              <div class="label mb-3 text-phos-500">Visual</div>
              <canvas
                id={"orb-#{@torrent.id}"}
                phx-hook="Dither"
                phx-update="ignore"
                data-seed={@torrent.magnet_hash}
                class="pixelated mx-auto block size-40 drop-shadow-[0_0_14px_rgba(102,153,255,0.6)]"
                aria-hidden="true"
              ></canvas>
            </div>
          </div>

          <%!-- Right: the facts --%>
          <div class="bg-ink-900/95 p-5 sm:p-6">
            <h1 class="font-mono text-lg leading-snug text-phos-100 glow sm:text-2xl">
              {@torrent.name}
            </h1>

            <dl class="dossier mt-5 text-xl">
              <div class="dossier-row">
                <dt class="text-phos-500">Incept date</dt>
                <span class="leader"></span>
                <dd class="text-phos-100" title={stamp(@torrent.published_at)}>
                  {stamp(@torrent.published_at)}
                  <span class="text-phos-500">· {ago(@torrent.published_at, @now)}</span>
                </dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Function</dt>
                <span class="leader"></span>
                <dd>
                  <.link
                    navigate={~p"/?#{[category: @torrent.category_id]}"}
                    class="text-phos-100 hover:glow"
                  >
                    {@torrent.category.name}
                  </.link>
                </dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Source</dt>
                <span class="leader"></span>
                <dd>
                  <a href={@torrent.canonical_url} class="text-phos-100 hover:glow" rel="noopener">
                    {@torrent.source.name} ↗
                  </a>
                </dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Size</dt>
                <span class="leader"></span>
                <dd class="text-phos-100 tabular-nums">
                  {bytes(@torrent.size_in_bytes)}
                  <span class="text-phos-500">· {number(@torrent.size_in_bytes)} B</span>
                </dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Seeders</dt>
                <span class="leader"></span>
                <dd class="text-acid tabular-nums glow-acid">{number(@torrent.seeders)}</dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Leechers</dt>
                <span class="leader"></span>
                <dd class="text-rose tabular-nums">{number(@torrent.leechers)}</dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Threat assessment</dt>
                <span class="leader"></span>
                <dd><.stars seeders={@torrent.seeders} /></dd>
              </div>
              <div class="dossier-row">
                <dt class="text-phos-500">Infohash</dt>
                <span class="leader"></span>
                <dd class="font-mono text-xs break-all text-phos-200 normal-case tracking-normal sm:text-sm">
                  {@torrent.magnet_hash}
                </dd>
              </div>
            </dl>

            <.swarm seeders={@torrent.seeders} leechers={@torrent.leechers} class="mt-5" />

            <div class="mt-6 flex flex-wrap items-center gap-3">
              <a
                id="magnet-link"
                href={@torrent.magnet_url}
                class="dossier focus-phos group inline-flex items-center gap-3 border border-phos-300 bg-phos-500/15 px-5 py-2.5 text-2xl text-phos-100 shadow-glow transition hover:bg-phos-500/30 hover:shadow-glow-lg"
              >
                <.magnet_icon class="size-6 text-phos-300 transition group-hover:text-phos-100" />
                Acquire magnet
              </a>
              <a
                id="source-link"
                href={@torrent.canonical_url}
                rel="noopener"
                class="dossier focus-phos inline-flex items-center gap-2 border border-phos-700 px-4 py-2.5 text-xl text-phos-300 transition hover:border-phos-300 hover:text-phos-100"
              >
                View on {@torrent.source.name}
              </a>
            </div>
          </div>
        </div>

        <%!-- Description --%>
        <div class="border-t border-phos-500/20 p-5 sm:p-6">
          <div class="label mb-2 text-phos-500">Notes from source</div>
          <p
            :if={@torrent.description}
            class="max-w-3xl font-mono text-sm leading-relaxed text-phos-200 whitespace-pre-line"
          >
            {@torrent.description}
          </p>
          <p :if={!@torrent.description} class="dossier text-xl text-phos-700">
            No description on file
          </p>
        </div>

        <.signal id="subject-signal" class="h-14 w-full border-t border-phos-500/30" />
      </article>

      <div class="mt-4 flex justify-between">
        <.link
          navigate={~p"/"}
          class="dossier focus-phos text-xl text-phos-300 hover:text-phos-100 hover:glow"
        >
          ← Back to the index
        </.link>
      </div>
    </Layouts.app>
    """
  end
end
