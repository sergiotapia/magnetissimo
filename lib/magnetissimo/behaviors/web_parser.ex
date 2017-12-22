defmodule Magnetissimo.WebParser do
  @moduledoc """
  Enforces a shared behaviour between all web parsers in charge of scraping
  content from the HTML of websites.
  """

  @callback initial_queue() :: :queue
  @callback start_link() :: any
  @callback process({:page_link, String.t}, :queue) :: :queue
  @callback process({:torrent_link, String.t}, :queue) :: :queue
  @callback torrent_links(String.t) :: Enum
  @callback torrent_information(String.t) :: Map
end
