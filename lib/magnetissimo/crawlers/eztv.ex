defmodule Magnetissimo.Crawlers.Eztv do
  @moduledoc """
  Crawls EZTV through its JSON API, finding the show through IMDb.

  eztvx.to puts every HTML page a crawler would read (its search, its show
  pages, its episode pages) behind a Cloudflare JavaScript challenge. Only its
  API answers a plain HTTP client, and the API cannot search by title: it lists
  either the newest torrents or one show's, by IMDb id. So a search takes two
  steps:

    1. The term is looked up in IMDb's title suggestions, the endpoint behind
       imdb.com's search box, which needs no key. Season, episode and
       resolution tokens are left out of the lookup ("baki s02e01" asks for
       "baki"), since IMDb suggests nothing for them. The first few TV series
       it suggests are the candidate shows.
    2. EZTV's API is asked for each show's torrents, newest first, a few pages
       deep. A long-running show's older episodes are out of reach.

  A show's torrents are kept only when their title contains every token of
  the term, the way the local trigram index would match it. Everything kept is
  recorded as a hit for the term, so without this a search for one episode
  would list the whole show.

  A show IMDb does not suggest, or EZTV has not linked to an IMDb id, cannot be
  found. EZTV carries only TV, so the category is read off the resolution in
  the title.
  """

  @behaviour Magnetissimo.Crawlers.Crawler

  alias Magnetissimo.Crawlers.Categories
  alias Magnetissimo.Crawlers.Http
  alias Magnetissimo.Crawlers.Magnet
  alias Magnetissimo.Torrents
  alias Magnetissimo.Torrents.Search

  @api_url "https://eztvx.to/api/get-torrents"
  @site_url "https://eztvx.to"
  # The single letter in the path is the bucket imdb.com's own search box
  # picks by the first letter of the query; any letter answers any query.
  @suggestion_url "https://v3.sg.media-imdb.com/suggestion/x/"
  @source_name "EZTV"

  # How many of IMDb's suggested shows are asked for, and how many pages of
  # each. The API serves at most 100 torrents a page, newest first.
  @max_shows 3
  @max_pages 5
  @per_page 100

  @show_kinds ["tvSeries", "tvMiniSeries"]

  # Tokens that name an episode or a release rather than a show.
  @release_token ~r/^(s\d{1,2}(e\d{1,3})?|e\d{1,3}|\d{1,2}x\d{1,3}|\d{3,4}p)$/i

  @resolution ~r/\b(480p|720p|1080p|2160p)\b/i

  # Mapped the way Prowlarr's `eztv` indexer does: everything is TV, split by
  # the resolution in the release name.
  @categories Categories.mapping!(
                @source_name,
                %{
                  "480p" => "TV/SD",
                  "720p" => "TV/HD",
                  "1080p" => "TV/HD",
                  "2160p" => "TV/UHD"
                },
                fallback: "TV"
              )

  @impl true
  def source_name, do: @source_name

  @impl true
  def categories, do: @categories

  @doc "Finds the term's shows on IMDb and asks EZTV for their torrents."
  @impl true
  def search(term) do
    with {:ok, imdb_ids} <- shows(term),
         {:ok, rows} <- torrents(imdb_ids) do
      source_id = Torrents.get_source_by_name!(@source_name).id
      tokens = for {_kind, token} <- Search.tokens(term), do: String.downcase(token)

      attrs =
        rows
        |> Enum.flat_map(&attrs_for(&1, source_id))
        |> Enum.filter(&matches?(&1.name, tokens))
        |> Enum.uniq_by(& &1.magnet_hash)

      {:ok, attrs}
    end
  end

  defp shows(term) do
    case show_query(term) do
      "" ->
        {:ok, []}

      query ->
        with {:ok, body} <-
               get(@suggestion_url <> URI.encode(query, &URI.char_unreserved?/1) <> ".json", []) do
          suggestions(body)
        end
    end
  end

  defp show_query(term) do
    term
    |> String.split()
    |> Enum.reject(&Regex.match?(@release_token, &1))
    |> Enum.join(" ")
    |> String.downcase()
  end

  defp suggestions(%{"d" => suggestions}) when is_list(suggestions) do
    ids =
      for %{"id" => "tt" <> digits, "qid" => kind} <- suggestions, kind in @show_kinds do
        digits
      end

    {:ok, Enum.take(ids, @max_shows)}
  end

  # A query IMDb has no suggestions for comes back without "d" at all.
  defp suggestions(_body), do: {:ok, []}

  defp torrents(imdb_ids), do: collect(imdb_ids, &show_torrents/1)

  # The first page says how many torrents the show has, and so how many more
  # pages there are to ask for.
  defp show_torrents(imdb_id) do
    with {:ok, count, rows} <- page(imdb_id, 1),
         last_page = min(@max_pages, div(count + @per_page - 1, @per_page)),
         {:ok, more} <- collect(2..last_page//1, &page_rows(imdb_id, &1)) do
      {:ok, rows ++ more}
    end
  end

  defp page_rows(imdb_id, n) do
    with {:ok, _count, rows} <- page(imdb_id, n), do: {:ok, rows}
  end

  # Runs `fetch` over `items` in turn, stopping at the first failure.
  defp collect(items, fetch) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      case fetch.(item) do
        {:ok, rows} -> {:cont, {:ok, acc ++ rows}}
        error -> {:halt, error}
      end
    end)
  end

  defp page(imdb_id, n) do
    params = [imdb_id: imdb_id, limit: @per_page, page: n]

    case get(@api_url, params: params) do
      # An id EZTV has no torrents for comes back with no "torrents" key.
      {:ok, %{"torrents_count" => count} = body} when is_integer(count) ->
        case Map.get(body, "torrents", []) do
          rows when is_list(rows) -> {:ok, count, rows}
          _ -> {:error, :unexpected_response}
        end

      {:ok, _body} ->
        {:error, :unexpected_response}

      error ->
        error
    end
  end

  # Both APIs answer with a JSON object; anything else on a 200, such as the
  # HTML of a Cloudflare challenge, is not an answer.
  defp get(url, options) do
    case Http.get(url, Application.get_env(:magnetissimo, __MODULE__, []) ++ options) do
      {:ok, body} when is_map(body) -> {:ok, body}
      {:ok, _body} -> {:error, :unexpected_response}
      error -> error
    end
  end

  # A row missing a field the index needs is dropped rather than crashing the
  # search, so one malformed entry cannot cost the whole answer.
  defp attrs_for(row, source_id) do
    with %{"id" => id, "title" => title, "hash" => hash} <- row,
         true <- is_binary(title) and is_binary(hash),
         {:ok, published_at} <- published_at(row["date_released_unix"]) do
      # The API tags every title with the site's name.
      name = String.replace_suffix(title, " EZTV", "")
      hash = String.downcase(hash)

      [
        %{
          name: name,
          canonical_url: "#{@site_url}/ep/#{id}/#{slug(name)}/",
          published_at: published_at,
          # EZTV reports seeds and peers; its peers are the leechers.
          leechers: to_integer(row["peers"]) || 0,
          seeders: to_integer(row["seeds"]) || 0,
          size_in_bytes: to_integer(row["size_bytes"]),
          magnet_hash: hash,
          magnet_url: Magnet.url(hash, name),
          category_id: Categories.resolve(@categories, resolution(name)),
          source_id: source_id
        }
      ]
    else
      _ -> []
    end
  end

  defp matches?(name, tokens) do
    name = String.downcase(name)
    Enum.all?(tokens, &String.contains?(name, &1))
  end

  defp resolution(name) do
    case Regex.run(@resolution, name, capture: :all_but_first) do
      [resolution] -> String.downcase(resolution)
      nil -> nil
    end
  end

  # The site's own episode URLs end in the release name, lowercased, with
  # every run of other characters made a dash.
  defp slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  defp published_at(unix) when is_integer(unix) and unix > 0, do: DateTime.from_unix(unix)
  defp published_at(_unix), do: :error

  defp to_integer(value) when is_integer(value), do: value

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp to_integer(_value), do: nil
end
