defmodule MagnetissimoWeb.DhtLive do
  @moduledoc """
  The DHT page: the crawler's switch and rate, its status, and the last
  hundred torrents it found, newest on top, arriving live.

  The switch and the rate slider save as they change, and the crawler
  starts, stops or restarts to match (`Magnetissimo.DHT.update_settings/1`).
  Every open page hears the change and moves its controls too. Without
  JavaScript the form posts to `/dht/settings` and has a Save button.

  DHT torrents stay out of "Fresh magnets" and the RSS feed, where they would
  bury what the sites publish, so this is where to watch them come in. They
  are searchable like any other.

  The list is a stream with a limit of 100: each arrival goes on top and the
  oldest row leaves the page. When a scrape estimates a torrent's swarm, its
  row is re-inserted with the numbers; their element's id holds the numbers
  too, so a change replaces the element and its flash plays once. Without
  JavaScript the page is the list as it was when loaded.
  """
  use MagnetissimoWeb, :live_view

  alias Magnetissimo.DHT
  alias Magnetissimo.DHT.Settings
  alias Magnetissimo.Taxonomy
  alias Magnetissimo.Torrents
  alias MagnetissimoWeb.DhtSettings

  @limit 100

  @impl true
  def mount(_params, _session, socket) do
    _ = if connected?(socket), do: DHT.subscribe()

    torrents = Torrents.list_dht_torrents(limit: @limit)

    {:ok,
     socket
     |> assign(:page_title, "DHT")
     |> assign(:status, DHT.status())
     |> assign_settings(DHT.settings())
     |> assign(:now, DateTime.utc_now())
     |> assign(:rows, Map.new(torrents, &{&1.id, &1}))
     |> assign(:arrived, MapSet.new())
     |> assign(:flashed, MapSet.new())
     |> assign(:shown, length(torrents))
     |> stream_configure(:torrents, dom_id: &"dht-torrents-#{&1.id}")
     |> stream(:torrents, torrents)}
  end

  @impl true
  def handle_event("save", %{"dht" => params}, socket) do
    case DHT.update_settings(DhtSettings.attrs(params)) do
      {:ok, settings} -> {:noreply, assign_settings(socket, settings)}
      {:error, _changeset} -> {:noreply, put_flash(socket, :error, "Those settings didn't save.")}
    end
  end

  @impl true
  def handle_info({:dht_settings, settings}, socket),
    do: {:noreply, assign_settings(socket, settings)}

  def handle_info({:dht_status, status}, socket) do
    {:noreply, assign(socket, status: status, now: DateTime.utc_now())}
  end

  def handle_info({:dht_indexed, torrents}, socket) do
    socket =
      Enum.reduce(torrents, socket, fn torrent, socket ->
        socket
        |> update(:arrived, &MapSet.put(&1, torrent.id))
        |> update(:rows, &Map.put(&1, torrent.id, torrent))
        |> stream_insert(:torrents, torrent, at: 0, limit: @limit)
      end)

    {:noreply, trim(socket)}
  end

  def handle_info({:dht_swarm, %{id: id, seeders: seeders, leechers: leechers}}, socket) do
    case socket.assigns.rows do
      %{^id => torrent} ->
        torrent = %{torrent | seeders: seeders, leechers: leechers}

        {:noreply,
         socket
         |> update(:rows, &Map.put(&1, id, torrent))
         |> update(:flashed, &MapSet.put(&1, id))
         |> stream_insert(:torrents, torrent)}

      _ ->
        {:noreply, socket}
    end
  end

  defp assign_settings(socket, settings) do
    socket
    |> assign(:settings, settings)
    |> assign(:settings_form, DhtSettings.form(settings))
  end

  # The stream drops rows past the limit from the page; the rows kept for
  # swarm updates follow, newest first.
  defp trim(socket) do
    rows = socket.assigns.rows

    if map_size(rows) > @limit do
      keep =
        rows |> Map.values() |> Enum.sort_by(&{&1.inserted_at, &1.id}, :desc) |> Enum.take(@limit)

      ids = MapSet.new(keep, & &1.id)

      socket
      |> assign(:rows, Map.new(keep, &{&1.id, &1}))
      |> update(:arrived, &MapSet.intersection(&1, ids))
      |> update(:flashed, &MapSet.intersection(&1, ids))
      |> assign(:shown, @limit)
    else
      assign(socket, :shown, map_size(rows))
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="grid gap-5 lg:grid-cols-[20rem_1fr] lg:items-start">
        <aside id="dht-status" class="panel animate-rise lg:sticky lg:top-6">
          <div class="panel-title">
            <span>The DHT</span>
            <span
              id="dht-state"
              class={[
                "rounded-full px-2.5 py-0.5 font-display text-[0.6rem] font-bold tracking-[0.15em] uppercase",
                if(@status.running,
                  do: "bg-mint-soft text-mint",
                  else: "bg-frost-200 text-ink-500"
                )
              ]}
            >
              {if @status.running, do: "Crawling", else: "Off"}
            </span>
          </div>

          <.settings form={@settings_form} settings={@settings} />

          <div :if={@status.running} class="p-5">
            <p class="text-sm leading-relaxed text-ink-700">
              Asking the BitTorrent DHT what it holds: at most {@status.config.rate} packets a second
              and {@status.config.fetches} fetches at once.
            </p>

            <dl class="mt-5 text-sm">
              <.stat
                id="dht-indexed-hour"
                label="Found, last hour"
                value={number(@status.indexed_last_hour)}
              />
              <.stat
                id="dht-torrents-rate"
                label="Torrents a minute"
                value={decimal(@status.rates[:torrents_per_minute])}
              />
              <.stat
                id="dht-hashes-rate"
                label="Hashes a minute"
                value={decimal(@status.rates[:hashes_per_minute])}
              />
              <.stat
                id="dht-fetching"
                label="Fetching"
                value={"#{@status.fetching} · #{number(@status.fetch_queue)} waiting"}
              />
              <.stat id="dht-nodes" label="Nodes known" value={number(@status.nodes_known)} />
              <.stat
                id="dht-router"
                label="Router connections"
                value={"≈ " <> number(@status.udp.flows_120s + @status.tcp.flows_120s)}
                title="Distinct addresses contacted in the last two minutes: what a home router's connection table holds for the crawler."
              />
              <.stat
                id="dht-bandwidth"
                label="Bandwidth"
                value={"#{decimal(@status.rates[:kbit_out])} / #{decimal(@status.rates[:kbit_in])} kbit/s"}
                title="Out / in"
              />
              <.stat
                id="dht-total"
                label="Indexed since start"
                value={number(@status.totals.indexed)}
              />
            </dl>
          </div>

          <div :if={!@status.running} id="dht-off" class="p-5 text-sm leading-relaxed text-ink-700">
            <p>
              Switch it on to have Magnetissimo find torrents on the BitTorrent DHT by itself, all the
              time, in the background: names, sizes, files and swarms, straight from the peers
              sharing them.
            </p>
            <p class="mt-3 text-ink-500">
              Fetching a torrent's details is a real BitTorrent connection, so the peers in its
              swarm see your IP. Nothing else is downloaded. Use a VPN if that matters to you.
            </p>
          </div>
        </aside>

        <section id="dht-results" class="panel animate-rise [animation-delay:120ms]">
          <div class="panel-title">
            <span>Just found on the DHT</span>
            <span class="label">latest {@shown}</span>
          </div>

          <ol id="dht-torrents" phx-update="stream" class="divide-y divide-frost-200 p-1.5">
            <li
              id="dht-torrents-empty"
              class="hidden p-12 text-center text-lg text-ink-500 only:block"
            >
              Nothing found yet ✦
            </li>
            <li
              :for={{id, torrent} <- @streams.torrents}
              id={id}
              class={[
                MapSet.member?(@arrived, torrent.id) && "animate-arrive",
                "group grid gap-x-4 gap-y-2.5 rounded-2xl px-3.5 py-3 transition hover:bg-glass/80 md:grid-cols-[minmax(0,1fr)_5.5rem_7.5rem_4.5rem_2rem] md:items-center"
              ]}
            >
              <div class="min-w-0">
                <h2 class="text-sm leading-snug font-semibold text-ink-900">
                  <.link
                    navigate={~p"/torrents/#{torrent}"}
                    class="focus-ring block truncate transition group-hover:text-azure-600"
                    title={torrent.name}
                  >
                    {torrent.name}
                  </.link>
                </h2>
                <div class="mt-1.5 flex items-center gap-2.5">
                  <.category_chip category={Taxonomy.fetch!(torrent.category_id)} />
                  <span :if={torrent.file_count} class="label">
                    {number(torrent.file_count)} {if torrent.file_count == 1,
                      do: "file",
                      else: "files"}
                  </span>
                </div>
              </div>

              <div class="flex items-center gap-4 md:contents">
                <span class="font-mono text-xs text-ink-700 tabular-nums md:text-right">
                  {bytes(torrent.size_in_bytes)}
                </span>
                <div
                  id={"swarm-#{torrent.id}-#{torrent.seeders}-#{torrent.leechers}"}
                  class={[
                    "-mx-1.5 rounded-lg px-1.5 py-1",
                    MapSet.member?(@flashed, torrent.id) && "animate-flash"
                  ]}
                >
                  <.swarm
                    seeders={torrent.seeders}
                    leechers={torrent.leechers}
                    class="w-28 md:w-auto"
                  />
                </div>
                <span class="font-mono text-xs text-ink-500 tabular-nums md:text-right">
                  {ago(torrent.inserted_at, @now)}
                </span>
                <a
                  href={torrent.magnet_url}
                  class="gel focus-ring ml-auto inline-flex size-8 items-center justify-center md:justify-self-end"
                  title="Open magnet link"
                  aria-label={"Magnet link for #{torrent.name}"}
                >
                  <.magnet_icon class="size-4" />
                </a>
              </div>
            </li>
          </ol>
        </section>
      </div>
    </Layouts.app>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :settings, Settings, required: true

  # The switch and the slider save as they change; the slider waits until it
  # has been still for a moment, as each change restarts the crawler. Without JavaScript
  # the form posts, and the Save button inside <noscript> sends it.
  defp settings(assigns) do
    {_name, preset} = DHT.preset(assigns.settings.rate)
    assigns = assign(assigns, :preset, preset)

    ~H"""
    <.form
      for={@form}
      id="dht-settings"
      action={~p"/dht/settings"}
      method="post"
      phx-change="save"
      class="border-b border-frost-300/70 p-5"
    >
      <label for="dht-enabled" class="flex cursor-pointer items-center justify-between gap-4">
        <span>
          <span class="block text-sm font-semibold text-ink-900">Crawl the DHT</span>
          <span id="dht-enabled-state" class="block text-xs text-ink-500">
            {if @settings.enabled, do: "On, in the background", else: "Off: nothing is sent"}
          </span>
        </span>
        <input type="hidden" name={@form[:enabled].name} value="false" />
        <input
          type="checkbox"
          id="dht-enabled"
          name={@form[:enabled].name}
          value="true"
          checked={@settings.enabled}
          role="switch"
          aria-checked={to_string(@settings.enabled)}
          class="sr-only"
        />
        <span class="toggle well" aria-hidden="true"><span class="toggle-thumb gel"></span></span>
      </label>

      <div class="mt-5">
        <div class="flex items-baseline justify-between gap-3">
          <label for="dht-rate" class="label">Rate</label>
          <span
            id="dht-rate-name"
            class="font-display text-xs font-bold tracking-[0.15em] text-azure-700 uppercase"
          >
            {@settings.rate}
          </span>
        </div>
        <input
          type="range"
          id="dht-rate"
          name={@form[:rate].name}
          min="0"
          max={length(Settings.rates()) - 1}
          step="1"
          value={@form[:rate].value}
          list="dht-rate-stops"
          phx-debounce="400"
          class="mt-2 w-full cursor-pointer accent-azure-500"
        />
        <datalist id="dht-rate-stops">
          <option :for={{rate, i} <- Enum.with_index(Settings.rates())} value={i} label={rate}>
          </option>
        </datalist>
        <div class="label mt-1 flex justify-between" aria-hidden="true">
          <span :for={rate <- Settings.rates()}>{rate}</span>
        </div>
        <p id="dht-rate-about" class="mt-3 text-xs leading-relaxed text-ink-500">
          About {number(@preset.entries)} connections on your router, {number(@preset.peak)} at
          most, and ~{number(@preset.per_hour)} torrents an hour. {advice(@settings.rate)}
        </p>
      </div>

      <noscript>
        <button
          type="submit"
          class="gel focus-ring mt-4 px-5 py-2 font-display text-xs font-bold tracking-[0.15em] uppercase"
        >
          Save
        </button>
      </noscript>
    </.form>
    """
  end

  defp advice("gentle"), do: "Safe on any home router."
  defp advice("normal"), do: "Fine on most home routers."

  defp advice("max"),
    do: "That fills a cheap router's table: keep it for a VPS, a VPN, or a router with room."

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :title, :string, default: nil

  defp stat(assigns) do
    ~H"""
    <div class="spec-row" title={@title}>
      <dt class="text-ink-500">{@label}</dt>
      <span class="leader"></span>
      <dd id={@id} class="text-right font-mono text-xs font-semibold text-ink-900 tabular-nums">
        {@value}
      </dd>
    </div>
    """
  end

  defp decimal(nil), do: "0"
  defp decimal(value), do: :erlang.float_to_binary(value / 1, decimals: 1)
end
