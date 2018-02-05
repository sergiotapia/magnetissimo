defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller
  import Ecto.Query
  alias Magnetissimo.Torrent
  alias Magnetissimo.Repo

  def index(conn, params) do
    results = case params do
      %{"term" => term, "nsfw" => "on", "website_source" => website_source}
        when website_source != "" ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{term}%"),
          where: t.website_source == ^website_source,
          order_by: [desc: :inserted_at]
      %{"term" => term, "website_source" => website_source}
        when website_source != "" ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{term}%"),
          where: t.website_source == ^website_source,
          where: t.nsfw == false,
          order_by: [desc: :inserted_at]
      %{"term" => term, "nsfw" => "on"} ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{term}%"),
          order_by: [desc: :inserted_at]
      _ ->
          from t in Torrent,
          where: ilike(t.name, ^"%#{params["term"]}%"),
          where: t.nsfw == false,
          order_by: [desc: :inserted_at]
    end

    page = results |> Repo.paginate(params)

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
