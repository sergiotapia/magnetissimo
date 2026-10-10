defmodule Magnetissimo.Crawlers.Crawler do
  @moduledoc """
  What one crawl source implements.

  A crawler only talks to its site and turns the answer into torrent attrs.
  It never writes: `Magnetissimo.Crawlers` indexes what it returns, the same
  way for every source, whether it came from the scheduled crawl or a search.
  """

  @typedoc "Attrs for `Magnetissimo.Torrents.index_torrents/1`."
  @type attrs :: map()

  @doc "The `sources.name` row this crawler files torrents under."
  @callback source_name() :: String.t()

  @doc """
  The site's categories mapped onto `Magnetissimo.Taxonomy`, built with
  `Magnetissimo.Crawlers.Categories.mapping!/3`. Every torrent the crawler
  returns is filed through it.
  """
  @callback categories() :: Magnetissimo.Crawlers.Categories.t()

  @doc "Fetches the newest torrents on the site."
  @callback latest() :: {:ok, [attrs]} | {:error, term()}

  @doc """
  Asks the site's own search for a term.

  The index only ever holds the newest page of a site, so anything older has
  never been crawled. A search reaches the rest of the catalogue on demand,
  for terms someone actually asked for.
  """
  @callback search(term :: String.t()) :: {:ok, [attrs]} | {:error, term()}
end
