defmodule Magnetissimo.Crawler do
  def crawl(url) do
    html_source = HTTPoison.get! url
    html_source
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> process_link
  end

  def process_link(url) when String.starts_with?(url, "magnet:") do
    # create Torrent model object and save to database.
  end

  def process_link(url) when String.starts_with?(url, "/") do
    crawl(url)
  end
end
