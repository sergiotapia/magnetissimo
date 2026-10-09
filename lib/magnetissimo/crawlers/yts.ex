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

  Two ways in: `crawl_latest/0` for the newest page, and `search/2`, which
  reaches the rest of the catalogue on demand for a term someone actually
  searched for.
  """

  require Logger

  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Torrents

  @api_url "https://movies-api.accel.li/api/v2/list_movies.json"
  @source_name "YTS"
  @category_name "Movies"
  @limit 50
  @user_agent "Magnetissimo/0.1"

  @doc """
  Fetches the newest movies and indexes every quality variant under them.

  Never raises. A dead API, a failed request or a page that is not the shape we
  expect is logged and the crawl ends normally, because the scheduler that calls
  this would otherwise turn a site outage into a restart loop.
  """
  @spec crawl_latest() :: :ok
  def crawl_latest do
    case fetch_movies(limit: @limit, sort_by: "date_added") do
      {:ok, movies} ->
        {inserted, known} = index(movies, nil, nil)
        Logger.info("[YTS] indexed #{inserted} new torrents, ignored #{known} already known")

      {:error, reason} ->
        Logger.error("[YTS] crawl failed: #{inspect(reason)}")
    end
  end

  @doc """
  Looks one term up on the API and indexes whatever comes back.

  The index only ever holds the newest page of the site, so anything older has
  never been crawled and a local search cannot find it. This is how a search
  reaches the rest of the catalogue without crawling it: hits are written to
  the index and are ordinary, searchable results from then on.

  `opts[:notify]` is a pid that receives `{:source_search, term, :updated}` after
  each movie that added something and `{:source_search, term, :done}` once the
  term is finished, so a caller can show results as they land. A term that
  matched only torrents already indexed sends no `:updated`.

  Never raises, matching `crawl_latest/0`.
  """
  @spec search(String.t(), keyword()) :: :ok
  def search(term, opts \\ []) do
    notify = Keyword.get(opts, :notify)

    case fetch_movies(limit: @limit, query_term: term) do
      {:ok, movies} ->
        {inserted, known} = index(movies, notify, term)

        Logger.info(
          "[YTS] search #{inspect(term)}: #{inserted} new torrents, #{known} already known"
        )

      {:error, reason} ->
        Logger.error("[YTS] search #{inspect(term)} failed: #{inspect(reason)}")
    end

    # Sent on every path, so a caller waiting on this term is never left
    # waiting because the API was down or the answer was wholly duplicate.
    notify(notify, term, :done)
  end

  defp fetch_movies(params) do
    # No retries: the crawl comes back in five minutes and a search is a
    # one-shot question, so retrying here only holds a process open while a
    # mirror is down.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [
          params: params,
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

  defp index(movies, notify, term) do
    category_id = Torrents.get_category_by_name_or_alias!(@category_name).id
    source_id = Torrents.get_source_by_name!(@source_name).id

    Enum.reduce(movies, {0, 0}, fn movie, totals ->
      counts = index_movie(movie, category_id, source_id)

      # Only a movie that added something is worth reporting: a page of
      # nothing but duplicates would redraw the caller's results for nothing.
      if elem(counts, 0) > 0, do: notify(notify, term, :updated)

      add(totals, counts)
    end)
  end

  defp index_movie(movie, category_id, source_id) do
    movie
    |> torrent_attrs(category_id, source_id)
    |> Enum.reduce({0, 0}, &insert/2)
  end

  defp add({inserted, known}, {more_inserted, more_known}) do
    {inserted + more_inserted, known + more_known}
  end

  defp notify(nil, _term, _status), do: :ok

  defp notify(pid, term, status) do
    # `send/2` returns the message; `crawl_latest/0` and `search/2` promise `:ok`.
    _ = send(pid, {:source_search, term, status})
    :ok
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
          magnet_url: Magnet.url(hash, name),
          category_id: category_id,
          source_id: source_id
        }
      ]
    else
      _ -> []
    end
  end
end
