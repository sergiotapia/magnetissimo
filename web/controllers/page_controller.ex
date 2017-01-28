defmodule Magnetissimo.PageController do
  use Magnetissimo.Web, :controller
  alias Magnetissimo.Torrent

  def index(conn, params) do
    results =
      from t in Torrent,
      where: ilike(t.name, ^"%#{params["term"]}%"),
      order_by: [desc: :inserted_at]

    page = results |> Magnetissimo.Repo.paginate(params)

    render conn, :index,
      page: page,
      term: params["term"],
      torrents: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
  end
end
