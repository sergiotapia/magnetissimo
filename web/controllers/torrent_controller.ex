defmodule Magnetissimo.TorrentController do
  use Magnetissimo.Web, :controller

  def index(conn, params) do
   	page =
      Magnetissimo.Torrent
      |> order_by(desc: :inserted_at)
      |> Magnetissimo.Repo.paginate(params)

    render conn, :index,
      page: page,
      torrents: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    end
end
