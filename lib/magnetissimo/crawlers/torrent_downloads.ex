defmodule Magnetissimo.Crawlers.TorrentDownloads do
  @moduledoc """
  Crawls torrentdownloads.pro through its RSS feed.

  One feed serves both directions: `type=today` for the newest torrents and
  `type=search` for a term. The feed is machine generated and already carries
  everything the index needs — title, canonical page, infohash, category, size,
  swarm and upload time — so the HTML search page is never scraped. That page
  lists no infohash, and reading it would mean a second request per result.

  The fields are pulled out with fixed patterns rather than an XML parser, the
  same way the Nyaa feed is read. Titles are raw UTF-8 with only the entities
  XML escaping requires (`&amp;` is common), which are decoded. Unlike Nyaa's
  feed, this one stamps upload times in the origin's local time, so the offset
  is applied instead of assuming UTC.

  The feed carries only the infohash and no tracker, so the magnet URI is built
  from the shared public tracker list, as the YTS crawler does.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Crawlers.Rss
  alias Magnetissimo.Torrents

  @base_url "https://www.torrentdownloads.pro"
  @feed_path "/rss.xml"
  @source_name "TorrentDownloads"
  @user_agent "Magnetissimo/0.1"

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  @impl true
  def source_name, do: @source_name

  @doc "Fetches today's newest torrents."
  @impl true
  def latest, do: fetch_attrs(type: "today")

  @doc """
  Looks one term up on the feed.

  The feed has no category for a search hit, so those are filed under `"Other"`
  rather than guessed at from the search page's icons.
  """
  @impl true
  def search(term), do: fetch_attrs(type: "search", search: term)

  defp fetch_attrs(params) do
    with {:ok, body} <- fetch(params) do
      {:ok, Rss.attrs(body, @source_name, &torrent_attrs/2)}
    end
  end

  defp fetch(params) do
    # No retries: the crawl comes back in five minutes and a search is a
    # one-shot question, so retrying only holds a process open while a mirror
    # is down.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [params: params, headers: [user_agent: @user_agent], retry: false]

    case Req.get(@base_url <> @feed_path, options) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  # An item missing a field we cannot invent, or carrying a date we cannot
  # parse, is dropped rather than crashing the crawl. The feed's link is
  # relative to the site root, and the site redirects to `www`.
  defp torrent_attrs(item, source_id) do
    with title when is_binary(title) <- Rss.field(item, "title"),
         path when is_binary(path) <- Rss.field(item, "link"),
         hash when is_binary(hash) <- Rss.field(item, "info_hash"),
         %DateTime{} = published_at <- published_at(Rss.field(item, "pubDate")) do
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
        category_id: Torrents.get_category_by_name_or_alias!(category(item)).id,
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

  # The category is CDATA, and empty on a search hit; an empty name falls
  # through to "Other" in the lookup.
  defp category(item) do
    case Regex.run(~r/<category><!\[CDATA\[(.*?)\]\]><\/category>/, item, capture: :all_but_first) do
      [value] -> value
      nil -> ""
    end
  end

  # Sat, 10 Oct 2026 01:40:07 +0200. The feed stamps each item in the origin's
  # local time, unlike Nyaa's UTC feed, so the offset is applied and the result
  # stored as UTC, which is what the rest of the app compares against. Only
  # this fixed shape needs to parse, so no date library is pulled in for it.
  defp published_at(nil), do: nil

  defp published_at(raw) do
    with [_, day, month, year, hour, minute, second, sign, offset_hour, offset_minute] <-
           Regex.run(
             ~r/(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) ([+-])(\d{2})(\d{2})/,
             raw
           ),
         {:ok, date} <- Date.new(Rss.to_integer(year), month_number(month), Rss.to_integer(day)),
         {:ok, time} <-
           Time.new(Rss.to_integer(hour), Rss.to_integer(minute), Rss.to_integer(second)) do
      date
      |> DateTime.new!(time, "Etc/UTC")
      |> DateTime.add(-offset_seconds(sign, offset_hour, offset_minute), :second)
    else
      _ -> nil
    end
  end

  defp offset_seconds(sign, hour, minute) do
    sign = if sign == "-", do: -1, else: 1
    sign * (Rss.to_integer(hour) * 3600 + Rss.to_integer(minute) * 60)
  end

  defp month_number(month) do
    case Enum.find_index(@months, &(&1 == month)) do
      nil -> 0
      index -> index + 1
    end
  end
end
