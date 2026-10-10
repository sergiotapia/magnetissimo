defmodule Magnetissimo.Crawlers.TorrentDownloads do
  @moduledoc """
  Crawls torrentdownloads.pro through its RSS feed.

  The feed answers a search with `type=search`. It is machine generated and
  already carries everything the index needs — title, canonical page,
  infohash, category, size, swarm and upload time — so the HTML search page is
  never scraped. That page lists no infohash, and reading it would mean a
  second request per result.

  The fields are pulled out with fixed patterns rather than an XML parser, the
  same way the Nyaa feed is read. Titles are raw UTF-8 with only the entities
  XML escaping requires (`&amp;` is common), which are decoded. Unlike Nyaa's
  feed, this one stamps upload times in the origin's local time, so the offset
  is applied instead of assuming UTC.

  The feed carries only the infohash and no tracker, so the magnet URI is built
  from the shared public tracker list, as the YTS crawler does.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  require Logger

  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Crawlers.Rss

  @base_url "https://www.torrentdownloads.pro"
  @feed_path "/rss.xml"
  @source_name "TorrentDownloads"
  @user_agent "Magnetissimo/0.1"

  # The feed names a category but gives no id, so the names are the keys.
  # These are Prowlarr's `torrentdownloads` mappings: the site's categories
  # are broad, and say nothing finer to map onto.
  @categories Categories.mapping!(
                @source_name,
                %{
                  "Anime" => "TV/Anime",
                  "Books" => "Books",
                  "Games" => "PC/Games",
                  "Movies" => "Movies",
                  "Music" => "Audio",
                  "Software" => "PC",
                  "TV Shows" => "TV",
                  "Pics" => "Other/Misc",
                  "Other" => "Other"
                },
                fallback: "Other"
              )

  # The site's own category ids, from its menu. Asked with a `cid`, the
  # search feed returns only that category and names it on every item.
  @category_ids %{
    1 => "Anime",
    2 => "Books",
    3 => "Games",
    4 => "Movies",
    5 => "Music",
    7 => "Software",
    8 => "TV Shows",
    9 => "Other"
  }

  @impl true
  def source_name, do: @source_name

  @impl true
  def categories, do: @categories

  @doc """
  Looks one term up on the feed, once per category.

  Asked for a term alone, the feed leaves the category out of nearly every
  hit: 47 of 50 for "wolfenstein" came back blank, though the site files
  them all under Games. Asked with a category id, it names the category on
  every hit. So the term is asked once per category, which also returns up
  to 50 hits per category rather than 50 in all, and once with no category,
  which catches a hit filed somewhere the site's menu does not list. A hit
  that comes back twice keeps its categorised copy.

  The requests go one after another. The site answers 503 to most of nine
  requests sent at once, and to some of three, but serves them in turn about
  as fast as in parallel: some 8 seconds for an uncached term, much less for
  one its CDN has cached. Each request gets 5 seconds, so a stuck one cannot
  hold the source past `Magnetissimo.SourceSearch`'s timeout.

  Answers as long as one of the requests did; the ones that failed are
  logged.
  """
  @impl true
  def search(term) do
    # The unnarrowed search is asked first and merged last, so that a hit's
    # categorised copy is the one kept.
    results =
      [nil | Enum.sort(Map.keys(@category_ids))]
      |> Enum.map(&search_category(term, &1))
      |> Enum.reverse()

    case Enum.split_with(results, &match?({:ok, _}, &1)) do
      {[], [error | _]} ->
        error

      {answers, failures} ->
        for {:error, reason} <- failures do
          Logger.warning(
            "[#{@source_name}] search #{inspect(term)} partly failed: #{inspect(reason)}"
          )
        end

        attrs =
          answers |> Enum.flat_map(fn {:ok, attrs} -> attrs end) |> Enum.uniq_by(& &1.magnet_hash)

        {:ok, attrs}
    end
  end

  defp search_category(term, nil), do: fetch_attrs([type: "search", search: term], nil)

  defp search_category(term, cid) do
    params = [type: "search", search: term, cid: cid]
    fetch_attrs(params, Map.fetch!(@category_ids, cid))
  end

  # `category` stands in for an item that names none, which only an answer
  # already narrowed to one category can vouch for.
  defp fetch_attrs(params, category) do
    with {:ok, body} <- fetch(params) do
      {:ok, Rss.attrs(body, @source_name, &torrent_attrs(&1, &2, category))}
    end
  end

  defp fetch(params) do
    # No retries: a search is a one-shot question, so retrying only holds a
    # process open while a mirror is down.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [
          params: params,
          headers: [user_agent: @user_agent],
          retry: false,
          receive_timeout: 5_000
        ]

    case Req.get(@base_url <> @feed_path, options) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  # An item missing a field we cannot invent, or carrying a date we cannot
  # parse, is dropped rather than crashing the crawl. The feed's link is
  # relative to the site root, and the site redirects to `www`.
  defp torrent_attrs(item, source_id, category) do
    with title when is_binary(title) <- Rss.field(item, "title"),
         path when is_binary(path) <- Rss.field(item, "link"),
         hash when is_binary(hash) <- Rss.field(item, "info_hash"),
         %DateTime{} = published_at <- Rss.published_at(Rss.field(item, "pubDate")) do
      hash = String.downcase(hash)
      name = Rss.unescape(title)

      %{
        name: name,
        canonical_url: @base_url <> path,
        published_at: published_at,
        leechers: swarm(item, "leechers"),
        seeders: swarm(item, "seeders"),
        size_in_bytes: Rss.integer_field(item, "size"),
        magnet_hash: hash,
        magnet_url: Magnet.url(hash, name),
        category_id: Categories.resolve(@categories, category(item, category)),
        source_id: source_id
      }
    else
      _ -> nil
    end
  end

  # The feed reports a swarm it does not know as 2^24 - 1 rather than leaving
  # it out, and taken at face value that is the best-seeded torrent there is.
  @unknown_swarm 16_777_215

  defp swarm(item, field) do
    case Rss.integer_field(item, field) do
      @unknown_swarm -> 0
      count -> count
    end
  end

  # The category is CDATA, and empty on most hits of an unnarrowed search,
  # which take the category the request was narrowed to, or the fallback.
  defp category(item, narrowed_to) do
    case Regex.run(~r/<category><!\[CDATA\[(.*?)\]\]><\/category>/, item, capture: :all_but_first) do
      [value] when value != "" -> value
      _none -> narrowed_to
    end
  end
end
