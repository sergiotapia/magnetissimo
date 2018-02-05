defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller
  import Ecto.Query
  alias Magnetissimo.Torrent

  def index(conn, params) do
    results = case params do
      %{"term" => term, "website_source" => website_source}
        when website_source != "" ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{term}%"),
          where: t.website_source == ^website_source,
          order_by: [desc: :inserted_at]
      _ ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{params["term"]}%"),
          order_by: [desc: :inserted_at]
    end

    page = results |> Magnetissimo.Repo.paginate(params)

    render conn, :index,
      page: page,
      term: params["term"],
      nsfw: params["nsfw"],
      website_source: params["website_source"],
      torrents: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
  end
end
