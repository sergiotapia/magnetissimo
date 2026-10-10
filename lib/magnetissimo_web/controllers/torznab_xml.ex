defmodule MagnetissimoWeb.TorznabXML do
  @moduledoc """
  Writes the Torznab XML that Sonarr, Radarr, Lidarr, Prowlarr, Chaptarr,
  Bookshelf, Listenarr and LazyLibrarian read.

  Each client reads a different part of an item, so an item says the same
  thing in several places. This follows Jackett's output, which has served
  magnet-only sites like Nyaa to all of them for years:

    * The magnet is the `<enclosure>` url (Sonarr, Radarr and Readarr's
      download link), the `<link>` (LazyLibrarian, Listenarr) and the
      `magneturl` attribute (Prowlarr, and what overrides the others at grab
      time).
    * The size is the `<size>` element, the enclosure `length` and the
      `size` attribute. Prowlarr drops an item without one.
    * `pubDate` is RFC 822 with a numeric offset. Sonarr and Prowlarr reject
      the whole feed when an item has none.
    * The `guid` is the infohash, which clients dedupe on.
    * `peers` is seeders plus leechers, and both are given too. An item
      without `seeders` is taken for Usenet by LazyLibrarian.
    * Every site is public, so nothing counts against a ratio:
      `downloadvolumefactor` is 0, as Jackett has it for public trackers.

  The caps advertise free-text search only (see
  `MagnetissimoWeb.TorznabRequest`) and every category in
  `Magnetissimo.Taxonomy`, with full names like `Audio/Audiobook`:
  LazyLibrarian picks its categories by name, and Radarr's Test fails if a
  category it was set up with is not listed.

  The documents are written as iodata rather than through a template, so
  every value goes through `escape/1` on its way out. Characters XML 1.0
  cannot carry are dropped: a site's title can hold control characters, and
  one of them makes the whole feed unreadable.
  """

  alias Magnetissimo.Taxonomy
  alias MagnetissimoWeb.TorznabRequest

  @declaration ~s(<?xml version="1.0" encoding="UTF-8"?>\n)

  @namespaces [
    {"version", "2.0"},
    {"xmlns:atom", "http://www.w3.org/2005/Atom"},
    {"xmlns:torznab", "http://torznab.com/schemas/2015/feed"},
    {"xmlns:newznab", "http://www.newznab.com/DTD/2010/feeds/attributes/"}
  ]

  # Supported params are comma-separated with no spaces: Sonarr splits on the
  # comma and does not trim. Lidarr reads `audio-search` and others
  # `music-search`; Jackett writes both, and so does this.
  @searching [
    {"search", "q"},
    {"tv-search", "q,season,ep"},
    {"movie-search", "q"},
    {"music-search", "q,artist,album"},
    {"audio-search", "q,artist,album"},
    {"book-search", "q,author,title"}
  ]

  # XML 1.0's Char production. Anything else is a fatal error to a parser.
  @not_xml ~r/[^\x{09}\x{0A}\x{0D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]/u

  @doc "The capabilities document, `t=caps`."
  @spec caps() :: iolist()
  def caps do
    limit = TorznabRequest.max_limit()

    [
      @declaration,
      element("caps", [], [
        element("server", title: "Magnetissimo"),
        element("limits", default: limit, max: limit),
        element("searching", [], for({name, params} <- @searching, do: search(name, params))),
        element(
          "categories",
          [],
          for({root, children} <- Taxonomy.tree(), do: category(root, children))
        )
      ])
    ]
  end

  defp search(name, params), do: element(name, available: "yes", supportedParams: params)

  defp category(root, children) do
    subcats = for c <- children, do: element("subcat", id: c.id, name: c.name)
    element("category", [id: root.id, name: root.name], subcats)
  end

  @doc """
  A page of results.

    * `:base_url` - where the app is reached from the client, for links
    * `:offset` - where this page starts
    * `:total` - how many results there are in all

  """
  @spec feed([Ecto.Schema.t()], keyword()) :: iolist()
  def feed(torrents, opts) do
    base_url = Keyword.fetch!(opts, :base_url)
    response = element("newznab:response", offset: opts[:offset], total: opts[:total])

    channel(base_url, [response | Enum.map(torrents, &item(&1, base_url))])
  end

  @doc """
  A feed whose one item says the index has nothing in the asked categories
  yet, filed under `category_id`.

  Every client's Test button and RSS poll fails on an empty feed, and a
  fresh install has nothing indexed. The item cannot be grabbed: its title
  matches no show, movie or book, and its link is the home page, not a
  torrent.
  """
  @spec placeholder(String.t(), pos_integer()) :: iolist()
  def placeholder(base_url, category_id) do
    item =
      element("item", [], [
        element("title", [], "Magnetissimo has nothing indexed in these categories yet"),
        element("guid", [isPermaLink: "false"], "magnetissimo-placeholder-#{category_id}"),
        element("link", [], base_url <> "/"),
        element("pubDate", [], pub_date(DateTime.utc_now())),
        element("size", [], "1"),
        element("category", [], category_id),
        element("enclosure", url: base_url <> "/", length: 1, type: "application/x-bittorrent"),
        attr("category", category_id),
        attr("size", 1),
        attr("seeders", 0),
        attr("peers", 0)
      ])

    channel(base_url, [element("newznab:response", offset: 0, total: 1), item])
  end

  @doc "A Newznab error. Clients read it from a 200 response."
  @spec error(pos_integer(), String.t()) :: iolist()
  def error(code, description) do
    [@declaration, element("error", code: code, description: description)]
  end

  defp channel(base_url, content) do
    [
      @declaration,
      element("rss", @namespaces, [
        element("channel", [], [
          element("atom:link",
            href: base_url <> "/api",
            rel: "self",
            type: "application/rss+xml"
          ),
          element("title", [], "Magnetissimo"),
          element("description", [], "Magnetissimo's Torznab feed"),
          element("link", [], base_url <> "/")
          | content
        ])
      ])
    ]
  end

  defp item(torrent, base_url) do
    category = Taxonomy.fetch!(torrent.category_id)
    # A subcategory is listed with its parent, as Jackett lists them.
    category_ids = Enum.uniq([category.id, Taxonomy.root(category).id])
    seeders = torrent.seeders || 0
    leechers = torrent.leechers || 0

    element("item", [], [
      element("title", [], torrent.name),
      element("guid", [isPermaLink: "false"], torrent.magnet_hash),
      element("link", [], torrent.magnet_url),
      element("comments", [], "#{base_url}/torrents/#{torrent.id}"),
      element("pubDate", [], pub_date(torrent.published_at)),
      element("size", [], torrent.size_in_bytes),
      element("category", [], category.id),
      element("enclosure",
        url: torrent.magnet_url,
        length: torrent.size_in_bytes,
        type: "application/x-bittorrent"
      ),
      Enum.map(category_ids, &attr("category", &1)),
      attr("size", torrent.size_in_bytes),
      attr("seeders", seeders),
      attr("leechers", leechers),
      attr("peers", seeders + leechers),
      attr("infohash", torrent.magnet_hash),
      attr("magneturl", torrent.magnet_url),
      attr("downloadvolumefactor", 0),
      attr("uploadvolumefactor", 1)
    ])
  end

  defp attr(name, value), do: element("torznab:attr", name: name, value: value)

  defp pub_date(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S +0000")
  end

  defp element(name, attrs), do: ["<", name, attributes(attrs), "/>"]

  defp element(name, attrs, content) when is_list(content) do
    ["<", name, attributes(attrs), ">", content, "</", name, ">"]
  end

  defp element(name, attrs, text), do: element(name, attrs, [escape(text)])

  defp attributes(attrs) do
    for {key, value} <- attrs, do: [" ", to_string(key), ~s(="), escape(value), ~s(")]
  end

  defp escape(value) do
    value
    |> to_string()
    |> String.replace_invalid("")
    |> String.replace(@not_xml, "")
    |> Plug.HTML.html_escape()
  end
end
