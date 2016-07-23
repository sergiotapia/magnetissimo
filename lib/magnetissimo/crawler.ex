defmodule Magnetissimo.Crawler do
  alias Magnetissimo.Torrent
  alias Magnetissimo.Repo

  def crawl(url, root, previously_crawled) do
    cond do
      url in previously_crawled -> nil
      true ->
        canonical_url = clean_up_url(root, url)
        IO.puts "Crawling: #{canonical_url}"
        case HTTPoison.get(canonical_url) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            body
            |> Floki.find("a")
            |> Floki.attribute("href")
            |> Enum.each(fn(href) ->
              cond do
                is_magnet_link(href) ->
                  create_torrent(href, root)
                is_internal_url(href) ->
                  crawl(href, root, [url | previously_crawled])
                true ->
                  nil
              end
            end)
          {:ok, %HTTPoison.Response{status_code: 404}} ->
            nil
          _ ->
            nil
        end
    end
  end

  def clean_up_url(root, url) do
    cond do
      String.starts_with?(url, "/") -> root <> url
      String.starts_with?(url, "http") -> url
      true -> "#{root}/#{url}"
    end
  end

  def is_magnet_link(url) do
    String.starts_with?(url, "magnet")
  end

  def is_internal_url(url) do
    !String.starts_with?(url, "http")
  end

  def create_torrent(url, root) do
    params = %{
      name: magnet_torrent_name(url),
      magnet: url,
      source: URI.parse(root).host
    }

    changeset = Torrent.changeset(%Torrent{}, params)

    case Repo.insert(changeset) do
      {:ok, _torrent} ->
        IO.puts "Torrent saved to database"
      _ ->
        nil
    end
  end

  def magnet_torrent_name(magnet) do
    params = URI.parse(magnet).query |> URI.query_decoder |> Enum.to_list() |> Enum.into(%{})
    HtmlEntities.decode(params["dn"])
  end
end
