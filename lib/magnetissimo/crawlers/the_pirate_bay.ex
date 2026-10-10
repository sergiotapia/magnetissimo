defmodule Magnetissimo.Crawlers.ThePirateBay do
  @moduledoc """
  Crawls The Pirate Bay through apibay, the JSON API behind its pages.

  thepiratebay.org renders nothing on the server: its search and description
  pages are empty shells that `main.js` fills from `apibay.org`. So the API is
  asked directly. `q.php` answers a search with up to 100 torrents, each
  carrying its infohash, category, size, swarm and upload time, so one request
  per search is enough and no torrent page is ever read.

  Every field arrives as a string, numbers included. Names keep the HTML
  escaping the site stores them with (`&amp;`), which is decoded. A search that
  matches nothing is not an empty list but one placeholder row with id `"0"`
  and an all-zero infohash, which is dropped.

  The API hands back only the infohash, so the magnet URI is built from the
  shared public tracker list, as the YTS crawler does. apibay answers a burst
  of requests with a 429; that is reported as the search failing, not retried.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Crawlers.Rss
  alias Magnetissimo.Torrents

  @api_url "https://apibay.org/q.php"
  @site_url "https://thepiratebay.org"
  @source_name "The Pirate Bay"
  @user_agent "Magnetissimo/0.1"

  # The site's category ids, as `main.js` names them, mapped the way Prowlarr's
  # `thepiratebay` indexer does. The hundreds are the top-level groups; a
  # torrent is normally filed under one of their children. The 500s are the
  # site's Porn group, so this mixed source can put a torrent into XXX, but
  # only from those ids: the fallback is Other, never XXX.
  @categories Categories.mapping!(
                @source_name,
                %{
                  "100" => "Audio",
                  "101" => "Audio",
                  "102" => "Audio/Audiobook",
                  "103" => "Audio",
                  "104" => "Audio/Lossless",
                  "199" => "Audio/Other",
                  "200" => "Movies",
                  "201" => "Movies",
                  "202" => "Movies/DVD",
                  "203" => "Audio/Video",
                  "204" => "Movies/Other",
                  "205" => "TV",
                  "206" => "Movies/Other",
                  "207" => "Movies/HD",
                  "208" => "TV/HD",
                  "209" => "Movies/3D",
                  "210" => "Movies/SD",
                  "211" => "Movies/UHD",
                  "212" => "TV/UHD",
                  "299" => "Movies/Other",
                  "300" => "PC",
                  "301" => "PC",
                  "302" => "PC/Mac",
                  "303" => "PC",
                  "304" => "PC/Mobile-Other",
                  "305" => "PC/Mobile-iOS",
                  "306" => "PC/Mobile-Android",
                  "399" => "PC",
                  "400" => "Console",
                  "401" => "PC/Games",
                  "402" => "PC/Mac",
                  "403" => "Console/PS4",
                  "404" => "Console/XBox 360",
                  "405" => "Console/Wii",
                  "406" => "Console/Other",
                  "407" => "PC/Mobile-iOS",
                  "408" => "PC/Mobile-Android",
                  "499" => "Console/Other",
                  "500" => "XXX",
                  "501" => "XXX",
                  "502" => "XXX/DVD",
                  "503" => "XXX/ImageSet",
                  "504" => "XXX/Other",
                  "505" => "XXX/x264",
                  "506" => "XXX/Other",
                  "507" => "XXX/UHD",
                  "599" => "XXX/Other",
                  "600" => "Other",
                  "601" => "Books/EBook",
                  "602" => "Books/Comics",
                  "603" => "Other/Misc",
                  "604" => "Other/Misc",
                  "605" => "Other/Misc",
                  "699" => "Other"
                },
                fallback: "Other"
              )

  @no_results_hash String.duplicate("0", 40)

  @impl true
  def source_name, do: @source_name

  @impl true
  def categories, do: @categories

  @doc "Looks one term up on apibay, across every category."
  @impl true
  def search(term) do
    with {:ok, rows} <- fetch_rows(q: term, cat: "") do
      source_id = Torrents.get_source_by_name!(@source_name).id

      {:ok, Enum.flat_map(rows, &attrs_for(&1, source_id))}
    end
  end

  defp fetch_rows(params) do
    # No retries: a search is a one-shot question, and apibay meets a burst
    # with a 429 that a quick retry only prolongs.
    options =
      Application.get_env(:magnetissimo, __MODULE__, []) ++
        [
          params: params,
          headers: [user_agent: @user_agent],
          retry: false
        ]

    case Req.get(@api_url, options) do
      {:ok, %{status: 200, body: rows}} when is_list(rows) -> {:ok, rows}
      {:ok, %{status: 200}} -> {:error, :unexpected_response}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  # The placeholder row a search with no matches comes back as.
  defp attrs_for(%{"info_hash" => @no_results_hash}, _source_id), do: []

  # A row missing a field the index needs is dropped rather than crashing the
  # search, so one malformed entry cannot cost the whole answer.
  defp attrs_for(row, source_id) do
    with %{"id" => id, "name" => name, "info_hash" => hash} <- row,
         {:ok, published_at} <- published_at(row["added"]) do
      name = Rss.unescape(name)
      # The API sends the infohash uppercased; the schema only accepts lowercase.
      hash = String.downcase(hash)

      [
        %{
          name: name,
          canonical_url: "#{@site_url}/description.php?id=#{id}",
          published_at: published_at,
          leechers: to_integer(row["leechers"]) || 0,
          seeders: to_integer(row["seeders"]) || 0,
          size_in_bytes: to_integer(row["size"]),
          magnet_hash: hash,
          magnet_url: Magnet.url(hash, name),
          category_id: Categories.resolve(@categories, row["category"]),
          source_id: source_id
        }
      ]
    else
      _ -> []
    end
  end

  defp published_at(added) do
    case to_integer(added) do
      unix when is_integer(unix) and unix > 0 -> DateTime.from_unix(unix)
      _ -> :error
    end
  end

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp to_integer(_value), do: nil
end
