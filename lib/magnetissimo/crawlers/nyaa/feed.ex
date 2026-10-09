defmodule Magnetissimo.Crawlers.Nyaa.Feed do
  @moduledoc """
  The crawler Nyaa.si and Sukebei share.

  Both sites run the same software and publish the same RSS shape, so only
  three things differ: the feed URL, the site's own tracker and the source row
  a torrent is filed under. Those are passed in as a keyword list; the two
  callers are `Magnetissimo.Crawlers.Nyaa` and `Magnetissimo.Crawlers.Sukebei`.

  The feed is a small, machine-generated document with no real description in
  it, so only the fields the index needs are read out: title, canonical page,
  infohash, category, size, swarm and upload time. The magnet URI is built
  here, because the feed carries only the infohash.

  The fields are pulled from the raw item with fixed patterns rather than an
  XML parser: item titles carry arbitrary UTF-8, and xmerl rejects that input.
  """

  require Logger

  alias Magnetissimo.Crawlers.Rss
  alias Magnetissimo.Torrents

  @user_agent "Magnetissimo/0.1"

  # Every Nyaa magnet carries the site's own tracker first and these four
  # public ones after it.
  @trackers [
    "udp://open.stealth.si:80/announce",
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://exodus.desync.com:6969/announce",
    "udp://tracker.torrent.eu.org:451/announce"
  ]

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  @units %{
    "Bytes" => 1,
    "B" => 1,
    "KiB" => 1024,
    "MiB" => 1024 ** 2,
    "GiB" => 1024 ** 3,
    "TiB" => 1024 ** 4
  }

  @doc """
  Crawls the feed in `site` and indexes every item.

  `site` needs `:source` (the `sources.name` row), `:rss_url` and `:tracker`.
  Never raises: a dead site, a failed request or an item that is not the shape
  we expect is logged or skipped, because the scheduler that calls this would
  otherwise turn a site outage into a restart loop.
  """
  @spec crawl_latest(keyword()) :: :ok
  def crawl_latest(site) do
    case fetch(site[:rss_url]) do
      {:ok, body} ->
        {inserted, known} = index(body, site)

        Logger.info(
          "[#{site[:source]}] indexed #{inserted} new torrents, ignored #{known} already known"
        )

      {:error, reason} ->
        Logger.error("[#{site[:source]}] crawl failed: #{inspect(reason)}")
    end
  end

  @doc """
  Looks one term up on the site and indexes whatever comes back.

  The same feed serves search: a `q` parameter filters it server-side, so no
  HTML is scraped for this. That keeps the two Nyaa crawlers to one parser.

  `opts[:notify]` is a pid that receives `{:source_search, term, :updated}`
  when the term added something and `{:source_search, term, :done}` once the
  term is finished, so a caller can show results as they land. A term that
  matched only torrents already indexed sends no `:updated`. Never raises.
  """
  @spec search(keyword(), String.t(), keyword()) :: :ok
  def search(site, term, opts \\ []) do
    notify = Keyword.get(opts, :notify)
    url = site[:rss_url] <> "&q=" <> URI.encode_www_form(term)

    case fetch(url) do
      {:ok, body} ->
        {inserted, known} = index(body, site)

        if inserted > 0, do: notify(notify, term, :updated)

        Logger.info(
          "[#{site[:source]}] search #{inspect(term)}: #{inserted} new torrents, " <>
            "#{known} already known"
        )

      {:error, reason} ->
        Logger.error("[#{site[:source]}] search #{inspect(term)} failed: #{inspect(reason)}")
    end

    # Sent on every path, so a caller waiting on this term is never left
    # waiting because the site was down or the answer was wholly duplicate.
    notify(notify, term, :done)
  end

  defp notify(nil, _term, _status), do: :ok

  defp notify(pid, term, status) do
    # `send/2` returns the message; the public functions promise `:ok`.
    _ = send(pid, {:source_search, term, status})
    :ok
  end

  defp fetch(url) do
    # No retries: the crawl comes back in five minutes, so retrying only holds
    # a process open while a mirror is down.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [headers: [user_agent: @user_agent], retry: false]

    case Req.get(url, options) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp index(body, site) do
    Rss.index(body, site[:source], fn item, source_id -> torrent_attrs(item, site, source_id) end)
  end

  # An item missing a field we cannot invent, or carrying a size or date we
  # cannot parse, is dropped rather than crashing the crawl.
  defp torrent_attrs(item, site, source_id) do
    with name when is_binary(name) <- Rss.field(item, "title"),
         hash when is_binary(hash) <- Rss.field(item, "nyaa:infoHash"),
         canonical_url when is_binary(canonical_url) <- guid(item),
         category when is_binary(category) <- Rss.field(item, "nyaa:category"),
         size when is_integer(size) <- size_to_bytes(Rss.field(item, "nyaa:size")),
         %DateTime{} = published_at <- published_at(Rss.field(item, "pubDate")) do
      name = unescape(name)
      hash = String.downcase(hash)

      %{
        name: name,
        canonical_url: canonical_url,
        published_at: published_at,
        leechers: Rss.integer_field(item, "nyaa:leechers"),
        seeders: Rss.integer_field(item, "nyaa:seeders"),
        size_in_bytes: size,
        magnet_hash: hash,
        magnet_url: magnet_url(site[:tracker], hash, name),
        category_id: Torrents.get_category_by_name_or_alias!(category).id,
        source_id: source_id
      }
    else
      _ -> nil
    end
  end

  defp guid(item) do
    case Regex.run(~r/<guid[^>]*>([^<]*)<\/guid>/, item) do
      [_, value] -> value
      nil -> nil
    end
  end

  defp size_to_bytes(nil), do: nil

  defp size_to_bytes(size) do
    with [_, value, unit] <- Regex.run(~r/^([\d.]+) (\w+)$/, String.trim(size)),
         {number, ""} <- Float.parse(value),
         multiplier when is_integer(multiplier) <- @units[unit] do
      round(number * multiplier)
    else
      _ -> nil
    end
  end

  # Fri, 09 Oct 2026 23:24:24 -0000. The feed is always UTC, and only this
  # fixed shape needs to parse, so the standard date parsers (which do not
  # cover RFC 1123) are not pulled in for it.
  defp published_at(nil), do: nil

  defp published_at(raw) do
    with [_, day, month, year, hour, minute, second] <-
           Regex.run(~r/(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})/, raw),
         {:ok, date} <- Date.new(Rss.to_integer(year), month_number(month), Rss.to_integer(day)),
         {:ok, time} <-
           Time.new(Rss.to_integer(hour), Rss.to_integer(minute), Rss.to_integer(second)) do
      DateTime.new!(date, time, "Etc/UTC")
    else
      _ -> nil
    end
  end

  defp month_number(month) do
    case Enum.find_index(@months, &(&1 == month)) do
      nil -> 0
      index -> index + 1
    end
  end

  defp unescape(text) do
    text
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&apos;", "'")
    |> String.replace("&#39;", "'")
    |> String.replace("&amp;", "&")
    |> decode_numeric()
  end

  defp decode_numeric(text) do
    Regex.replace(~r/&#(\d+);/, text, fn _, code ->
      case Integer.parse(code) do
        {n, ""} when n in 1..0x10FFFF -> <<n::utf8>>
        _ -> "&#" <> code <> ";"
      end
    end)
  end

  defp magnet_url(tracker, hash, name) do
    trackers = Enum.map_join([tracker | @trackers], "&tr=", &URI.encode_www_form/1)

    "magnet:?xt=urn:btih:#{hash}&dn=#{URI.encode_www_form(name)}&tr=#{trackers}"
  end
end
