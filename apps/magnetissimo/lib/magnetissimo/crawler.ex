defmodule Magnetissimo.Crawler do
  require Logger

  def get_torrents_from_feed(url, xml_map) do
    Logger.debug("[#{__MODULE__}] Getting torrents from feed: #{url}")

    with  {:ok, rss_body} <- get_page_body(url),
          {:ok, torrents} <- map_torrents(rss_body, xml_map) do

      Logger.debug("[#{__MODULE__}] Got torrents from feed: #{url}")         
      {:ok, torrents}
    else
      {:error, {:map_torrents, reason}} ->
        Logger.error("[#{__MODULE__}] Error mapping feed: #{url}")
        {:error, {:map_torrents, reason}}

      {:error, reason} -> {:error, reason}
      _ -> :error
    end
  end

  def get_page_body(url) do
    Logger.debug("[#{__MODULE__}] Downloading: #{url}")

    case url |> HTTPoison.get() do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.warn("[#{__MODULE__}] HTTP status not okay: #{url} (#{status_code})")
        {:error, {:status_code, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warn("[#{__MODULE__}] Failed to download: #{url} (#{reason})")
        {:error, {:failed_download, reason}}
    end
  end

  def map_torrents(feed_body, mapping) do
    import SweetXml
    Logger.debug("[#{__MODULE__}] Mapping torrents.")

    case Wormhole.capture(fn ->
        feed_body |> :erlang.binary_to_list |> xmap(torrents: mapping) end, timeout: 30_000) do

      {:ok, %{torrents: torrents}} -> {:ok, torrents}
      {:error, reason} -> {:error, {:map_torrents, reason}}
    end
  end

end
