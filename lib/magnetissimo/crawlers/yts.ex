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

  Two ways in: `latest/0` for the newest page, and `search/1`, which reaches
  the rest of the catalogue on demand for a term someone actually searched
  for.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Torrents

  @api_url "https://movies-api.accel.li/api/v2/list_movies.json"
  @source_name "YTS"
  @category_name "Movies"
  @limit 50
  @user_agent "Magnetissimo/0.1"

  @impl true
  def source_name, do: @source_name

  @doc "Fetches the newest movies, one torrent per quality variant."
  @impl true
  def latest, do: fetch_attrs(limit: @limit, sort_by: "date_added")

  @doc "Looks one term up on the API, one torrent per quality variant."
  @impl true
  def search(term), do: fetch_attrs(limit: @limit, query_term: term)

  defp fetch_attrs(params) do
    with {:ok, movies} <- fetch_movies(params) do
      category_id = Torrents.get_category_by_name_or_alias!(@category_name).id
      source_id = Torrents.get_source_by_name!(@source_name).id

      {:ok, Enum.flat_map(movies, &torrent_attrs(&1, category_id, source_id))}
    end
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
