defmodule Magnetissimo.Crawlers.Yts do
  @moduledoc """
  Crawls YTS through its JSON API.

  One API entry is one movie and its quality variants hang off it. The variants
  share a name and differ only by infohash, so a movie becomes two or three
  torrents and `magnet_hash` is what tells them apart.

  The API hands back a bare infohash and no magnet link, so the magnet URI and
  its trackers are built here rather than at render time. `yts.mx`, the host the
  2.0.0 app crawled, no longer resolves; `movies-api.accel.li` is the base URL
  YTS now advertises in its own responses.
  """

  require Logger

  alias Magnetissimo.Torrents

  @api_url "https://movies-api.accel.li/api/v2/list_movies.json"
  @source_name "YTS"
  @category_name "Movies"
  @limit 50
  @user_agent "Magnetissimo/0.1"

  # YTS ships no magnet link, only the infohash, so a client has no tracker to
  # announce to without this list. Carried over from the 2.0.0 app unchanged.
  @trackers [
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.tracker.cl:1337/announce",
    "udp://9.rarbg.me:2970/announce",
    "udp://p4p.arenabg.com:1337/announce",
    "udp://tracker.torrent.eu.org:451/announce",
    "udp://tracker.dler.org:6969/announce",
    "udp://open.stealth.si:80/announce",
    "udp://ipv4.tracker.harry.lu:80/announce",
    "https://opentracker.i2p.rocks:443/announce"
  ]

  @doc """
  Fetches the newest movies and indexes every quality variant under them.

  Never raises. A dead API, a failed request or a page that is not the shape we
  expect is logged and the crawl ends normally, because the scheduler that calls
  this would otherwise turn a site outage into a restart loop.
  """
  @spec crawl_latest() :: :ok
  def crawl_latest do
    case fetch_movies() do
      {:ok, movies} ->
        {inserted, known} = index(movies)
        Logger.info("[YTS] indexed #{inserted} new torrents, ignored #{known} already known")

      {:error, reason} ->
        Logger.error("[YTS] crawl failed: #{inspect(reason)}")
    end
  end

  defp fetch_movies do
    # No retries: the scheduler comes back in five minutes, so retrying here
    # only holds the process open while a mirror is down.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [
          params: [limit: @limit, sort_by: "date_added"],
          headers: [user_agent: @user_agent],
          retry: false
        ]

    case Req.get(@api_url, options) do
      {:ok, %{status: 200, body: body}} -> movies(body)
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp movies(%{"data" => %{"movies" => movies}}) when is_list(movies), do: {:ok, movies}
  defp movies(_body), do: {:error, :unexpected_response}

  defp index(movies) do
    category_id = Torrents.get_category_by_name_or_alias!(@category_name).id
    source_id = Torrents.get_source_by_name!(@source_name).id

    movies
    |> Enum.flat_map(&torrent_attrs(&1, category_id, source_id))
    |> Enum.reduce({0, 0}, &insert/2)
  end

  defp insert(attrs, {inserted, known}) do
    case Torrents.create_torrent(attrs) do
      {:ok, _torrent} ->
        {inserted + 1, known}

      {:error, changeset} ->
        # A source republishing a torrent it already listed is the normal case,
        # not a fault. Anything else means our own attrs are wrong and the
        # torrent is being dropped silently, which should be visible.
        unless Keyword.has_key?(changeset.errors, :magnet_hash) do
          Logger.warning("[YTS] skipped #{attrs.name}: #{inspect(changeset.errors)}")
        end

        {inserted, known + 1}
    end
  end

  defp torrent_attrs(movie, category_id, source_id) do
    movie
    |> Map.get("torrents", [])
    |> Enum.flat_map(&attrs_for(&1, movie, category_id, source_id))
  end

  # A torrent with no usable upload time is dropped rather than crashing the
  # crawl, so one malformed entry cannot cost the whole page.
  defp attrs_for(torrent, movie, category_id, source_id) do
    with unix when is_integer(unix) <- torrent["date_uploaded_unix"],
         {:ok, published_at} <- DateTime.from_unix(unix) do
      name = movie["title_long"]
      # The API sends the infohash uppercased; the schema only accepts lowercase.
      hash = String.downcase(torrent["hash"] || "")

      [
        %{
          name: name,
          description: movie["description_full"],
          canonical_url: movie["url"],
          published_at: published_at,
          leechers: torrent["peers"],
          seeders: torrent["seeds"],
          size_in_bytes: torrent["size_bytes"],
          magnet_hash: hash,
          magnet_url: magnet_url(hash, name),
          category_id: category_id,
          source_id: source_id
        }
      ]
    else
      _ -> []
    end
  end

  defp magnet_url(hash, name) do
    trackers = Enum.map_join(@trackers, "&tr=", &URI.encode_www_form/1)

    "magnet:?xt=urn:btih:#{hash}&dn=#{URI.encode_www_form(name)}&tr=#{trackers}"
  end
end
