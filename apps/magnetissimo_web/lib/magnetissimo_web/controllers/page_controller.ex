defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller

  def index(conn, params) do
    page = Magnetissimo.Torrents.search(params)
    tallies = Magnetissimo.Torrents.tallies()
    total_torrent_count = Magnetissimo.Torrents.total_torrent_count()

    render(conn, :index,
      tallies: tallies,
      total_torrent_count: total_torrent_count,
      page: page,
      torrents: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      term: params["term"],
      website_source: params["website_source"]
    )
  end
end
