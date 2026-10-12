defmodule MagnetissimoWeb.TorrentLive do
  @moduledoc """
  One torrent: fingerprint, orb, the facts in rows, the magnet, whatever
  the source said about it, and its files when the source knew them.

  A torrent the DHT found has no page anywhere to link to, so its source
  links to the DHT page instead of "View on".
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.Taxonomy
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
      <nav
        class="mb-4 flex flex-wrap items-center gap-1.5 text-xs font-semibold"
        aria-label="Breadcrumb"
      >
        <.link navigate={~p"/"} class="pill focus-ring px-3 py-1">Index</.link>
        <span class="text-ink-300" aria-hidden="true">›</span>
        <.link
          navigate={~p"/?#{[category: @torrent.category_id]}"}
          class="pill focus-ring px-3 py-1"
        >
          {Taxonomy.fetch!(@torrent.category_id).name}
        </.link>
        <span class="text-ink-300" aria-hidden="true">›</span>
        <span class="px-1 font-mono text-ink-500">No. {ordinal(@torrent.id)}</span>
      </nav>

      <article id={"torrent-#{@torrent.id}"} class="panel animate-rise">
        <header class="panel-title">
          <span>No. {ordinal(@torrent.id)}</span>
          <span class="label hidden sm:inline">{@torrent.source.name}</span>
        </header>

        <div class="grid md:grid-cols-[18rem_1fr]">
          <%!-- Left: fingerprint and orb --%>
          <div class="grid border-frost-300/70 bg-glass/35 sm:grid-cols-2 md:grid-cols-1 md:border-r">
            <div class="p-6">
              <div class="label mb-3">Fingerprint</div>
              <div class="well mx-auto w-fit rounded-3xl p-4">
                <.fingerprint hash={@torrent.magnet_hash} class="size-32" />
              </div>
              <.hexdump hash={@torrent.magnet_hash} class="mt-4 justify-center" />
            </div>

            <div class="relative border-frost-300/70 p-6 max-sm:border-t sm:border-l md:border-t md:border-l-0">
              <div class="label mb-3">Aura</div>
              <.sparkle class="top-10 right-10 size-4 text-azure-400" />
              <.orb
                id={"orb-#{@torrent.id}"}
                seed={@torrent.magnet_hash}
                class="mx-auto my-2 size-36"
              />
            </div>
          </div>

          <%!-- Right: the facts --%>
          <div class="p-6 sm:p-8">
            <h1 class="text-xl leading-snug font-bold break-words text-ink-900 sm:text-2xl">
              {@torrent.name}
            </h1>

            <dl class="mt-6 text-sm sm:text-base">
              <div class="spec-row">
                <dt class="text-ink-500">Added</dt>
                <span class="leader"></span>
                <dd class="text-right font-semibold text-ink-900" title={stamp(@torrent.published_at)}>
                  {stamp(@torrent.published_at)}
                  <span class="font-medium text-ink-500">· {ago(@torrent.published_at, @now)}</span>
                </dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Category</dt>
                <span class="leader"></span>
                <dd>
                  <.link
                    navigate={~p"/?#{[category: @torrent.category_id]}"}
                    class="link font-semibold"
                  >
                    {Taxonomy.fetch!(@torrent.category_id).name}
                  </.link>
                </dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Source</dt>
                <span class="leader"></span>
                <dd>
                  <.link :if={dht?(@torrent)} navigate={~p"/dht"} class="link font-semibold">
                    {@torrent.source.name}
                  </.link>
                  <a
                    :if={!dht?(@torrent)}
                    href={@torrent.canonical_url}
                    class="link font-semibold"
                    rel="noopener"
                  >
                    {@torrent.source.name} ↗
                  </a>
                </dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Size</dt>
                <span class="leader"></span>
                <dd class="text-right font-semibold text-ink-900 tabular-nums">
                  {bytes(@torrent.size_in_bytes)}
                  <span class="font-mono text-xs font-normal text-ink-500">
                    · {number(@torrent.size_in_bytes)} B
                  </span>
                </dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Seeders</dt>
                <span class="leader"></span>
                <dd class="font-bold text-mint tabular-nums">{number(@torrent.seeders)}</dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Leechers</dt>
                <span class="leader"></span>
                <dd class="font-bold text-bubble tabular-nums">{number(@torrent.leechers)}</dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Health</dt>
                <span class="leader"></span>
                <dd><.stars seeders={@torrent.seeders} /></dd>
              </div>
              <div class="spec-row">
                <dt class="text-ink-500">Infohash</dt>
                <span class="leader"></span>
                <dd class="font-mono text-xs break-all text-ink-700 sm:text-sm">
                  {@torrent.magnet_hash}
                </dd>
              </div>
            </dl>

            <.swarm seeders={@torrent.seeders} leechers={@torrent.leechers} class="mt-6" />

            <div class="mt-8 flex flex-wrap items-center gap-3">
              <a
                id="magnet-link"
                href={@torrent.magnet_url}
                class="gel focus-ring inline-flex items-center gap-2.5 px-6 py-3 font-display text-sm font-bold tracking-[0.15em] uppercase"
              >
                <.magnet_icon class="size-5" /> Get magnet
              </a>
              <a
                :if={!dht?(@torrent)}
                id="source-link"
                href={@torrent.canonical_url}
                rel="noopener"
                class="pill focus-ring inline-flex items-center gap-2 px-5 py-3 font-display text-sm font-bold tracking-[0.15em] uppercase"
              >
                View on {@torrent.source.name}
              </a>
            </div>
          </div>
        </div>

        <%!-- Description --%>
        <div class="border-t border-frost-300/70 p-6 sm:p-8">
          <div class="label mb-2">Description</div>
          <p
            :if={@torrent.description}
            class="max-w-3xl text-sm leading-relaxed whitespace-pre-line text-ink-700"
          >
            {@torrent.description}
          </p>
          <p :if={!@torrent.description} class="text-sm text-ink-300">
            The source didn't say anything about this one.
          </p>
        </div>

        <%!-- Files, when the source knew them: only the DHT does --%>
        <div :if={@torrent.files} id="files" class="border-t border-frost-300/70 p-6 sm:p-8">
          <div class="label mb-3">
            Files · {number(@torrent.file_count || length(@torrent.files))}
          </div>
          <ol class="well max-h-96 divide-y divide-frost-200/70 overflow-y-auto rounded-2xl px-4 py-1">
            <li
              :for={file <- @torrent.files}
              class="flex items-baseline justify-between gap-4 py-2 text-sm"
            >
              <span class="min-w-0 break-words text-ink-700">{file["path"]}</span>
              <span class="shrink-0 font-mono text-xs text-ink-500 tabular-nums">
                {bytes(file["size"])}
              </span>
            </li>
          </ol>
          <p
            :if={(@torrent.file_count || 0) > length(@torrent.files)}
            id="files-more"
            class="mt-2 text-sm text-ink-500"
          >
            and {number(@torrent.file_count - length(@torrent.files))} more
          </p>
        </div>

        <.signal id="subject-signal" class="h-14 w-full" />
      </article>

      <div class="mt-5">
        <.link navigate={~p"/"} class="pill focus-ring inline-flex px-4 py-2 text-sm font-semibold">
          ← Back to the index
        </.link>
      </div>
    </Layouts.app>
    """
  end

  defp dht?(torrent), do: torrent.source.name == "DHT"
end
