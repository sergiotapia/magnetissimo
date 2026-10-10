defmodule Magnetissimo.Crawlers.AudioBookBay do
  @moduledoc """
  Crawls AudioBookBay, a WordPress site of audiobook torrents.

  No listing on the site carries an infohash. The feed, the front page and the
  search results name a page per book, and only that page has the hash, its
  trackers and the size. So every crawl is one listing request and then one
  request per book, at most `@max_concurrency` at a time. A page already in
  the index is not fetched again: its torrent is handed back as it was stored,
  so a search still records it as a hit for the term.

  The two listings differ in what they say about time. `latest/0` reads the
  RSS feed, whose `pubDate` is exact. `search/1` reads the HTML search
  results, which give a day and no time, so a hit found that way is stamped
  midnight UTC of that day. Search results come back by relevance, not date,
  and only the first page is read.

  The site shows no swarm anywhere, so `seeders` and `leechers` stay 0. Its
  categories are genres, several per book and all of them audiobooks, so every
  torrent is filed under Audio/Audiobook; the genres go in the description,
  with the author, narrator and format, where the search can find them.

  Each page lists the trackers the torrent announces to, the site's own first,
  and the magnet URI is built from those rather than the shared public list.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  require Logger

  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Crawlers.Rss
  alias Magnetissimo.Torrents

  # Hardcoded on purpose, with no config to override it. AudioBookBay moves
  # between domains every so often (it has been .se, .is, .li, .fi and more);
  # .lu is the one it answers on as of October 2026. A crawl that starts
  # failing with DNS or connection errors most likely means it moved again:
  # change it here, and the source's url in `Magnetissimo.Seeds` with it.
  @base_url "https://audiobookbay.lu"
  @source_name "AudioBookBay"
  @user_agent "Magnetissimo/0.1"

  # The site served five book pages in a row in about a second each without
  # throttling; five at once keeps a crawl to about two rounds of requests.
  @max_concurrency 5
  @page_timeout 5_000

  # Every category on the site is a genre of audiobook, so none is mapped.
  @categories Categories.mapping!(@source_name, %{}, fallback: "Audio/Audiobook")

  # The page says "MBs" and "GBs"; Prowlarr reads them as binary units too.
  @units %{"KBs" => 1024, "MBs" => 1024 ** 2, "GBs" => 1024 ** 3, "TBs" => 1024 ** 4}

  # The fields of an indexed torrent a crawl hands back for a page it skips.
  @indexed_fields [
    :name,
    :description,
    :canonical_url,
    :published_at,
    :size_in_bytes,
    :magnet_hash,
    :magnet_url,
    :category_id,
    :source_id
  ]

  @impl true
  def source_name, do: @source_name

  @impl true
  def categories, do: @categories

  @doc "Fetches the books in the RSS feed, the newest nine or so."
  @impl true
  def latest do
    with {:ok, body} <- fetch(@base_url <> "/feed/", receive_timeout: 15_000) do
      body |> Rss.items() |> Enum.flat_map(&feed_entry/1) |> books()
    end
  end

  @doc """
  Looks one term up on the site's search, first page only.

  The site's own search form adds `cat=undefined,undefined`, which changes
  nothing and is left out.
  """
  @impl true
  def search(term) do
    with {:ok, body} <- fetch(@base_url <> "/", params: [s: term]) do
      body |> listing_entries() |> books()
    end
  end

  # The feed's links are absolute, and could name another of the site's
  # domains; only the path is kept, on the domain this crawler talks to.
  defp feed_entry(item) do
    with link when is_binary(link) <- Rss.field(item, "link"),
         %DateTime{} = published_at <- Rss.published_at(Rss.field(item, "pubDate")) do
      [%{url: canonical_url(link), published_at: published_at}]
    else
      _ -> []
    end
  end

  # One `<div class="post">` per book, linking its page and saying the day it
  # was posted: `Posted: 8 Oct 2026`.
  defp listing_entries(body) do
    body
    |> String.split(~s(<div class="post">))
    |> Enum.drop(1)
    |> Enum.flat_map(fn post ->
      with [_, path] <- Regex.run(~r/<div class="postTitle"><h2><a href="([^"]+)"/, post),
           [_, day, month, year] <- Regex.run(~r/Posted: (\d{1,2}) (\w{3}) (\d{4})/, post),
           {:ok, date} <-
             Date.new(Rss.to_integer(year), Rss.month_number(month), Rss.to_integer(day)) do
        [%{url: canonical_url(path), published_at: DateTime.new!(date, ~T[00:00:00], "Etc/UTC")}]
      else
        _ -> []
      end
    end)
  end

  defp canonical_url(link), do: @base_url <> URI.parse(link).path

  defp books(entries) do
    source_id = Torrents.get_source_by_name!(@source_name).id
    entries = Enum.uniq_by(entries, & &1.url)
    indexed = Torrents.torrents_by_canonical_url(Enum.map(entries, & &1.url))

    {known, unknown} = Enum.split_with(entries, &Map.has_key?(indexed, &1.url))

    # Pages that time out are dropped like ones that fail; the next crawl or
    # search asks for them again.
    fetched =
      unknown
      |> Task.async_stream(&book(&1, source_id),
        max_concurrency: @max_concurrency,
        timeout: @page_timeout * 2,
        on_timeout: :kill_task,
        zip_input_on_exit: true
      )
      |> Enum.flat_map(fn
        {:ok, attrs} ->
          List.wrap(attrs)

        {:exit, {entry, reason}} ->
          List.wrap(skip(entry, reason))
      end)

    {:ok, Enum.map(known, &Map.take(indexed[&1.url], @indexed_fields)) ++ fetched}
  end

  defp book(entry, source_id) do
    with {:ok, body} <- fetch(entry.url, receive_timeout: @page_timeout),
         %{} = attrs <- book_attrs(body, entry, source_id) do
      attrs
    else
      nil -> skip(entry, :no_infohash_or_size)
      {:error, reason} -> skip(entry, reason)
    end
  end

  defp skip(entry, reason) do
    Logger.warning("[#{@source_name}] skipped #{entry.url}: #{inspect(reason)}")
    nil
  end

  defp book_attrs(body, entry, source_id) do
    with [_, title] <- Regex.run(~r/<h1[^>]*>(.*?)<\/h1>/s, body),
         [_, hash] <- Regex.run(~r/Info Hash:<\/td>\s*<td>\s*([0-9a-fA-F]{40})\s*</, body),
         size when is_integer(size) <- size_in_bytes(body) do
      name = text(title)
      hash = String.downcase(hash)

      %{
        name: name,
        description: description(body),
        canonical_url: entry.url,
        published_at: entry.published_at,
        size_in_bytes: size,
        magnet_hash: hash,
        magnet_url: magnet_url(hash, name, trackers(body)),
        category_id: Categories.resolve(@categories, nil),
        source_id: source_id
      }
    else
      _ -> nil
    end
  end

  # The table under each book: `File Size:` then `<span ...>686.36</span> MBs`.
  defp size_in_bytes(body) do
    with [_, value, unit] <-
           Regex.run(~r/File Size:<\/td>\s*<td><span[^>]*>([\d.,]+)<\/span>\s*(\w+)/, body),
         {number, ""} <- Float.parse(String.replace(value, ",", "")),
         multiplier when is_integer(multiplier) <- @units[unit] do
      round(number * multiplier)
    else
      _ -> nil
    end
  end

  # `Announce URL:` is the site's own tracker, and every `Tracker:` row after
  # it a backup.
  defp trackers(body) do
    ~r/<td[^>]*>(?:Announce URL|Tracker):<\/td>\s*<td[^>]*>\s*([^<\s]+)\s*<\/td>/
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map(&hd/1)
    |> Enum.uniq()
  end

  defp magnet_url(hash, name, []), do: Magnet.url(hash, name)
  defp magnet_url(hash, name, trackers), do: Magnet.url(hash, name, trackers)

  # Written by Charlotte Engel · Read by Lizzie Munro · M4B · 128 Kbps ·
  # Unabridged · Adults, Crime, Mystery
  defp description(body) do
    [
      prefixed("Written by ", spans(body, "author")),
      prefixed("Read by ", spans(body, "narrator")),
      spans(body, "format"),
      spans(body, "bitrate"),
      spans(body, "is_abridged"),
      genres(body)
    ]
    |> Enum.reject(&(&1 == ""))
    |> case do
      [] -> nil
      parts -> Enum.join(parts, " · ")
    end
  end

  defp prefixed(_prefix, ""), do: ""
  defp prefixed(prefix, value), do: prefix <> value

  defp spans(body, class) do
    ~r/<span class="#{class}"[^>]*>(.*?)<\/span>/s
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map_join(", ", &text(hd(&1)))
  end

  defp genres(body) do
    ~r/rel="category tag">([^<]+)<\/a>/
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map_join(", ", &text(hd(&1)))
  end

  # Page text with any markup inside it dropped and its entities decoded.
  defp text(html) do
    html |> String.replace(~r/<[^>]*>/, "") |> Rss.unescape() |> String.trim()
  end

  defp fetch(url, options) do
    # No retries: the crawl comes back in five minutes and a search is a
    # one-shot question, so retrying only holds a process open while the site
    # is down.
    options =
      Keyword.merge(
        [headers: [user_agent: @user_agent], retry: false, receive_timeout: @page_timeout],
        options
      ) ++ Application.get_env(:magnetissimo, __MODULE__, [])

    case Req.get(url, options) do
      {:ok, %{status: 200, body: body}} when is_binary(body) -> {:ok, body}
      {:ok, %{status: 200}} -> {:error, :unexpected_response}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end
end
