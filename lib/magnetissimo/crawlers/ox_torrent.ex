defmodule Magnetissimo.Crawlers.OxTorrent do
  @moduledoc """
  Crawls OxTorrent, a French site of films, series, games, software and books.

  Its search results list a release's name, category, size and swarm, but no
  infohash: that is only on the release's own page. So every search is one
  request for the results and then one per release, the way AudioBookBay is
  read. A page already in the index is not fetched again; its torrent is
  handed back as it was stored, with the swarm the results show today.

  The results come newest first, 50 to a page, and only the first page is
  read. Only the top `@search_pages` releases not yet indexed have their pages
  fetched, so a source that has to answer within
  `Magnetissimo.SourceSearch`'s timeout is never left waiting on 50 pages.
  The ones left out are fetched by a later search for the term, once the
  newer ones are indexed and skipped.

  The site's search matches the term as a phrase, in order: "cabin 10 2025"
  finds The.Woman.in.Cabin.10.2025, "woman cabin" finds nothing.

  The results give an age ("9 mois") rather than a date; the page gives the
  day it was posted (`26/10/2025`) and no time, so a release is stamped
  midnight UTC of that day.

  The name is the release name the results list. The page also gives a
  title the site wrote, often the French one ("La Disparue de la cabine 10 -
  The Woman In Cabin 10 MULTI ULTRA HD 4K x265 2025"), which goes in the
  description with the genres, where the search can find it.

  Each page's magnet link names the trackers the torrent announces to, and
  the magnet URI is built from those rather than the shared public list.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  require Logger

  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Http
  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Crawlers.Rss
  alias Magnetissimo.Torrents

  # Hardcoded on purpose, with no config to override it. OxTorrent moves
  # between domains, the way the Torrent9 family of sites it belongs to does;
  # ww1.oxtorrent.run is the one it answers on as of October 2026. Searches
  # that start failing with DNS or connection errors most likely mean it moved
  # again: change it here, and the source's url in `Magnetissimo.Seeds` with
  # it.
  @base_url "https://ww1.oxtorrent.run"
  @source_name "OxTorrent"

  # Ten pages five at a time drew no complaint from the site. Each page is
  # some 170 KB compressed, most of it an obfuscated script ahead of the
  # markup. The worst case, the results and three rounds of pages all timing
  # out, stays under SourceSearch's 20 seconds.
  @max_concurrency 5
  @search_pages 15
  @page_timeout 4_000

  # The site's own category names, as the results' type column titles them.
  @categories Categories.mapping!(
                @source_name,
                %{
                  "Films" => "Movies",
                  "Séries" => "TV",
                  "Animes" => "TV/Anime",
                  "Sports" => "TV/Sport",
                  "Musiques" => "Audio",
                  "Ebooks" => "Books/EBook",
                  "Livres" => "Books",
                  "Logiciels" => "PC",
                  "Jeux-PC" => "PC/Games",
                  "Jeux-Consoles" => "Console",
                  "Vidéos" => "Other"
                },
                fallback: "Other"
              )

  # The site says "MB" and "GB"; Prowlarr reads them as binary units.
  @units %{"KB" => 1024, "MB" => 1024 ** 2, "GB" => 1024 ** 3, "TB" => 1024 ** 4}

  # The fields of an indexed torrent a search hands back for a page it skips.
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

  @doc """
  Looks one term up on the site's search, first page only.

  The term goes in the path, `/recherche/<term>`, which is where the site's
  own search form redirects to.
  """
  @impl true
  def search(term) do
    with {:ok, body} <-
           fetch(@base_url <> "/recherche/" <> URI.encode(term, &URI.char_unreserved?/1)) do
      body |> listing_entries() |> releases()
    end
  end

  # One `<tr>` per release in the results table. The page also links releases
  # from a "Top Films" strip of covers, which are not hits and have no row.
  defp listing_entries(body) do
    body
    |> String.split("<tr>")
    |> Enum.drop(1)
    |> Enum.flat_map(fn row ->
      with [_, category] <- Regex.run(~r/liste-accueil-type" title="([^"]*)"/, row),
           [_, path, title] <-
             Regex.run(~r/liste-accueil-nom">.*?<a href="(\/detail\/\d+)" title="([^"]*)"/s, row),
           [_, size] <- Regex.run(~r/liste-accueil-taille"[^>]*>([^<]*)</, row) do
        [
          %{
            url: @base_url <> path,
            name: text(title),
            category: text(category),
            size_in_bytes: size_in_bytes(size),
            seeders: swarm(row, "sources"),
            leechers: swarm(row, "clients")
          }
        ]
      else
        _ -> []
      end
    end)
  end

  defp swarm(row, class) do
    case Regex.run(~r/class="#{class} [^"]*"[^>]*>\s*(\d+)/, row) do
      [_, count] -> String.to_integer(count)
      _ -> 0
    end
  end

  # `2.58 GB`, `575.59 MB`.
  defp size_in_bytes(size) do
    with [_, value, unit] <- Regex.run(~r/([\d.]+)\s*([KMGT]B)/, size),
         {number, ""} <- Float.parse(value) do
      round(number * Map.fetch!(@units, unit))
    else
      _ -> nil
    end
  end

  defp releases(entries) do
    source_id = Torrents.get_source_by_name!(@source_name).id
    entries = Enum.uniq_by(entries, & &1.url)
    indexed = Torrents.torrents_by_canonical_url(Enum.map(entries, & &1.url))

    {known, unknown} = Enum.split_with(entries, &Map.has_key?(indexed, &1.url))

    # Pages that time out are dropped like ones that fail; the next search
    # asks for them again.
    fetched =
      unknown
      |> Enum.take(@search_pages)
      |> Task.async_stream(&release(&1, source_id),
        max_concurrency: @max_concurrency,
        timeout: @page_timeout + 1_000,
        on_timeout: :kill_task,
        zip_input_on_exit: true
      )
      |> Enum.flat_map(fn
        {:ok, attrs} -> List.wrap(attrs)
        {:exit, {entry, reason}} -> List.wrap(skip(entry, reason))
      end)

    known =
      Enum.map(known, fn entry ->
        indexed[entry.url]
        |> Map.take(@indexed_fields)
        |> Map.merge(Map.take(entry, [:seeders, :leechers]))
      end)

    {:ok, known ++ fetched}
  end

  defp release(entry, source_id) do
    with {:ok, body} <- fetch(entry.url),
         %{} = attrs <- release_attrs(body, entry, source_id) do
      attrs
    else
      nil -> skip(entry, :no_infohash_or_date)
      {:error, reason} -> skip(entry, reason)
    end
  end

  defp skip(entry, reason) do
    Logger.warning("[#{@source_name}] skipped #{entry.url}: #{inspect(reason)}")
    nil
  end

  defp release_attrs(body, entry, source_id) do
    with [_, magnet] <- Regex.run(~r/href="(magnet:\?[^"]+)"/, body),
         magnet = Rss.unescape(magnet),
         [_, hash] <- Regex.run(~r/xt=urn:btih:([0-9a-fA-F]{40})/, magnet),
         %DateTime{} = published_at <- published_at(body) do
      hash = String.downcase(hash)

      %{
        name: entry.name,
        description: description(body),
        canonical_url: entry.url,
        published_at: published_at,
        seeders: entry.seeders,
        leechers: entry.leechers,
        size_in_bytes: entry.size_in_bytes || page_size(body),
        magnet_hash: hash,
        magnet_url: magnet_url(hash, entry.name, trackers(magnet)),
        category_id: Categories.resolve(@categories, entry.category),
        source_id: source_id
      }
    else
      _ -> nil
    end
  end

  # The results show the size too, and are read first; this is for a row that
  # left it out.
  defp page_size(body) do
    case Regex.run(~r/Poids du fichier:<\/td>\s*<td[^>]*><strong>([^<]*)</, body) do
      [_, size] -> size_in_bytes(size)
      _ -> nil
    end
  end

  # `<span class="icon_date"><i ...></i> 26/10/2025</span>`, day first.
  defp published_at(body) do
    with [_, day, month, year] <-
           Regex.run(~r/icon_date">.*?(\d{1,2})\/(\d{1,2})\/(\d{4})/s, body),
         {:ok, date} <-
           Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)) do
      DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
    else
      _ -> nil
    end
  end

  # The site's magnet lists its trackers unencoded: `&tr=udp://host:1337/announce`.
  defp trackers(magnet) do
    magnet
    |> String.split("&")
    |> Enum.flat_map(fn
      "tr=" <> tracker -> [URI.decode_www_form(tracker)]
      _ -> []
    end)
    |> Enum.uniq()
  end

  defp magnet_url(hash, name, []), do: Magnet.url(hash, name)
  defp magnet_url(hash, name, trackers), do: Magnet.url(hash, name, trackers)

  # La Disparue de la cabine 10 - The Woman In Cabin 10 MULTI ULTRA HD 4K x265
  # 2025 · Policier, Thriller
  defp description(body) do
    [
      captured(~r/<div class="maximums">(.*?)<\/div>/s, body),
      captured(~r/Sous-Catégories:<\/td>\s*<td[^>]*><strong>(.*?)<\/strong>/s, body)
    ]
    |> Enum.reject(&(&1 == ""))
    |> case do
      [] -> nil
      parts -> Enum.join(parts, " · ")
    end
  end

  defp captured(regex, body) do
    case Regex.run(regex, body, capture: :all_but_first) do
      [value] -> text(value)
      _ -> ""
    end
  end

  # Page text with any markup inside it dropped and its entities decoded.
  defp text(html) do
    html |> String.replace(~r/<[^>]*>/, "") |> Rss.unescape() |> String.trim()
  end

  defp fetch(url) do
    options =
      Keyword.put(
        Application.get_env(:magnetissimo, __MODULE__, []),
        :receive_timeout,
        @page_timeout
      )

    case Http.get(url, options) do
      {:ok, body} when is_binary(body) -> {:ok, body}
      {:ok, _body} -> {:error, :unexpected_response}
      error -> error
    end
  end
end
