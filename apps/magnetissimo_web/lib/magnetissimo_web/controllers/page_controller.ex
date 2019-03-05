defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller

  def index(conn, params) do
    page = Magnetissimo.Torrents.search(params)

    render(conn, :index,
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
