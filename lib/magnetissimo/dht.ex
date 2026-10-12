defmodule Magnetissimo.DHT do
  @moduledoc """
  The DHT source: a crawler of the BitTorrent DHT that runs in the background,
  switched on and off, and set to a rate, on the `/dht` page. It is off until
  someone turns it on.

  It is the one exception to "sources are asked only on a search". The sites
  blocked us for polling them; the DHT is ten million peers with no site to
  block anyone, and it cannot answer a text search at all: it only maps
  infohashes to peers. So it is crawled, gently, all the time:

    1. `Magnetissimo.DHT.Sampler` walks the network and asks nodes for samples
       of the infohashes they store (BEP 51 `sample_infohashes`), honouring
       the interval each node asks for.
    2. `Magnetissimo.DHT.Fetcher` drops hashes already indexed, asks the node
       that sampled one for its peers, and fetches the info dictionary from a
       peer over TCP (BEP 9). It also estimates the swarm (BEP 33).
    3. `Magnetissimo.DHT.Classifier` files the torrent or refuses it, and
       `Magnetissimo.DHT.Indexer` writes batches through
       `Magnetissimo.Torrents.index_torrents/2` and broadcasts them.

  Every UDP packet waits its turn in `Magnetissimo.DHT.Node`'s budget, and
  TCP fetches are capped. A home router keeps a table entry for every remote
  address it sees (conntrack), so the number of distinct nodes asked per
  second is what can slow a household's browsing, not bandwidth. The rate is
  one setting with three presets measured on a home connection; see
  `presets/0`. We are a read-only node (BEP 43), so no port has to be open
  and nobody sends us queries.

  The settings live in the database (`Magnetissimo.DHT.Settings`).
  `update_settings/1` saves them and hands them to
  `Magnetissimo.DHT.Runner`, which starts, stops or restarts the crawler to
  match. Status, counts and new torrents are broadcast on PubSub for the DHT
  page: `subscribe/0`.
  """

  import Ecto.Query, warn: false

  alias Magnetissimo.DHT.Classifier
  alias Magnetissimo.DHT.KRPC
  alias Magnetissimo.DHT.Runner
  alias Magnetissimo.DHT.Settings
  alias Magnetissimo.DHT.Stats
  alias Magnetissimo.Repo
  alias Magnetissimo.Torrents

  @pubsub Magnetissimo.PubSub
  @topic "dht"
  @saved_nodes 2_000

  # Measured on a home connection, five minutes each, twice: the router-table
  # entries the crawler added on average and at peak, and the torrents it
  # indexed an hour. See docs/dht.md for how, and don't raise one without
  # measuring it.
  @presets %{
    gentle: %{rate: 20, fetches: 8, entries: 600, peak: 900, per_hour: 900},
    normal: %{rate: 75, fetches: 24, entries: 2_000, peak: 3_000, per_hour: 2_600},
    max: %{rate: 250, fetches: 64, entries: 6_500, peak: 9_000, per_hour: 7_000}
  }

  @bootstrap [
    {"router.bittorrent.com", 6881},
    {"router.utorrent.com", 6881},
    {"dht.transmissionbt.com", 6881},
    {"dht.libtorrent.org", 25_401},
    {"dht.aelitis.com", 6881}
  ]

  @doc """
  The rate presets. `rate` is the most UDP packets a second the crawler
  sends, every kind counted; `fetches` is how many torrents' metadata it
  fetches at once, each over up to three TCP connections. The rate is a
  ceiling: sampling pauses while fetches are backed up, so the crawler
  averages well under it.

  `entries` and `peak` are the connection-tracking entries it added to a
  home router's table, on average and at most, and `per_hour` the torrents
  it indexed an hour, as measured (`docs/dht.md`). `gentle` is safe on any
  home router, `normal` on most, and `max` wants a VPS, a VPN or a router
  with a large table.
  """
  def presets, do: @presets

  @doc "The public routers a crawler that knows no nodes asks first."
  def bootstrap_nodes, do: @bootstrap

  ## Settings

  @doc "The saved settings, or the defaults (off, gentle) if none were saved."
  @spec settings() :: Settings.t()
  def settings do
    Repo.one(from s in Settings, order_by: s.id, limit: 1) || %Settings{}
  end

  @doc """
  Saves `enabled` and `rate` and applies them: the crawler starts, stops, or
  restarts at the new rate. Every `/dht` page open hears
  `{:dht_settings, settings}`.
  """
  @spec update_settings(map()) :: {:ok, Settings.t()} | {:error, Ecto.Changeset.t()}
  def update_settings(attrs) do
    with {:ok, settings} <- settings() |> Settings.changeset(attrs) |> Repo.insert_or_update() do
      Runner.apply_config(config(settings))
      _ = broadcast({:dht_settings, settings})
      {:ok, settings}
    end
  end

  @doc """
  What the crawler runs with: `enabled`, `preset`, its `rate` and
  `fetches`, and the UDP `port` (0 for any, set by `DHT_PORT`).
  """
  @spec config(Settings.t()) :: %{
          enabled: boolean(),
          preset: atom(),
          rate: pos_integer(),
          fetches: pos_integer(),
          port: :inet.port_number()
        }
  def config(settings \\ settings()) do
    {preset, %{rate: rate, fetches: fetches}} = preset(settings.rate)
    port = :magnetissimo |> Application.get_env(__MODULE__, []) |> Keyword.get(:port, 0)

    %{enabled: settings.enabled, preset: preset, rate: rate, fetches: fetches, port: port}
  end

  @doc "A preset by name, as `{name, preset}`. An unknown name is `gentle`."
  @spec preset(String.t() | atom()) :: {atom(), map()}
  def preset(name) when is_atom(name) and is_map_key(@presets, name), do: {name, @presets[name]}

  def preset(name) when is_binary(name) do
    case Enum.find(Map.keys(@presets), &(Atom.to_string(&1) == name)) do
      nil -> preset(:gentle)
      preset -> preset(preset)
    end
  end

  def preset(_name), do: preset(:gentle)

  ## PubSub

  @doc """
  Subscribes the caller to the crawler's broadcasts:

    * `{:dht_status, status}` every couple of seconds while it runs, and once
      with `running: false` when it stops
    * `{:dht_settings, settings}` when someone changes the settings
    * `{:dht_indexed, torrents}` when a batch of torrents is indexed
    * `{:dht_swarm, %{id: id, seeders: n, leechers: n}}` when a scrape
      estimates a torrent's swarm
  """
  @spec subscribe() :: :ok | {:error, term()}
  def subscribe, do: Phoenix.PubSub.subscribe(@pubsub, @topic)

  @doc "Sends one of the messages `subscribe/0` lists to every subscriber."
  @spec broadcast(term()) :: :ok | {:error, term()}
  def broadcast(message), do: Phoenix.PubSub.broadcast(@pubsub, @topic, message)

  @doc """
  The crawler's latest status, or `%{running: false}` when it is off.
  """
  @spec status() :: map()
  def status do
    if Process.whereis(Stats),
      do: Stats.status(),
      else: %{running: false, config: config()}
  catch
    # Stats was restarting between the lookup and the call.
    :exit, _reason -> %{running: false, config: config()}
  end

  ## Known nodes

  @doc """
  Files every torrent only the DHT has found again, with today's
  `Magnetissimo.DHT.Classifier`, and returns how many changed category.

  The category is decided once, when a torrent is indexed, so a better
  classifier files only what it finds from then on; this brings the rest up
  to date. A torrent it would now refuse keeps its category. A torrent a site
  has returned keeps the site's (see
  `Magnetissimo.Torrents.recategorize_dht_torrents/1`). From a release,
  `bin/magnetissimo eval "Magnetissimo.Release.reclassify_dht()"`.
  """
  @spec reclassify_torrents() :: non_neg_integer()
  def reclassify_torrents do
    Torrents.recategorize_dht_torrents(fn %{name: name, files: files} ->
      files = Enum.map(files, &%{path: &1["path"], size: &1["size"]})

      case Classifier.classify(%{name: name, files: files}) do
        {:ok, category_id} -> category_id
        :banned -> nil
      end
    end)
  end

  @doc "The nodes saved by `save_nodes/1`, as `{id, {ip, port}}`."
  @spec load_nodes() :: [{binary(), KRPC.address()}]
  def load_nodes do
    from(n in "dht_nodes", select: {n.node_id, n.ip, n.port}, order_by: [desc: n.answered_at])
    |> Repo.all()
    |> Enum.flat_map(fn {id, ip, port} ->
      case :inet.parse_ipv4_address(String.to_charlist(ip)) do
        {:ok, ip} -> [{id, {ip, port}}]
        {:error, _} -> []
      end
    end)
  end

  @doc """
  Saves these nodes, which answered the crawler, alongside those saved
  before, keeping the 2,000 that answered most recently. They are where the
  next start begins, so the bootstrap routers are rarely needed. A short run,
  switched on and off again, adds its few nodes rather than replacing a
  long run's.
  """
  @spec save_nodes([{binary(), KRPC.address()}]) :: :ok
  def save_nodes(nodes) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      for {id, {ip, port}} <- nodes do
        %{node_id: id, ip: ip |> :inet.ntoa() |> to_string(), port: port, answered_at: now}
      end

    newest =
      from n in "dht_nodes",
        order_by: [desc: n.answered_at, desc: n.id],
        limit: @saved_nodes,
        select: n.id

    {:ok, _} =
      Repo.transact(fn ->
        for chunk <- Enum.chunk_every(rows, 200) do
          {_count, _} =
            Repo.insert_all("dht_nodes", chunk,
              on_conflict: {:replace, [:node_id, :answered_at]},
              conflict_target: [:ip, :port]
            )
        end

        {_count, _} = Repo.delete_all(from n in "dht_nodes", where: n.id not in subquery(newest))
        {:ok, :saved}
      end)

    :ok
  end
end
