defmodule Magnetissimo.RSSParser do
  @moduledoc """
  Enforces a shared behaviour between all RSS parsers in charge of scraping
  content from RSS feeds.
  """

  @callback initial_queue() :: :queue
  @callback start_link() :: any
  @callback process({:page_link, String.t}, :queue) :: :queue
  @callback torrent_information(String.t) :: List
end
