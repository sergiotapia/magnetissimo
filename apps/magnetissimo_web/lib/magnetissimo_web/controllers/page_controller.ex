defmodule MagnetissimoWeb.PageController do
  use MagnetissimoWeb, :controller

  def index(conn, params) do
    torrents = Magnetissimo.Torrents.all()
    # results =
    #   case params do
    #     %{"term" => term, "nsfw" => "on", "website_source" => website_source}
    #     when website_source != "" ->
    #       from(t in Torrent,
    #         where: ilike(t.name, ^"%#{term}%"),
    #         where: t.website_source == ^website_source,
    #         order_by: [desc: :inserted_at]
    #       )

    #     %{"term" => term, "website_source" => website_source}
    #     when website_source != "" ->
    #       from(t in Torrent,
    #         where: ilike(t.name, ^"%#{term}%"),
    #         where: t.website_source == ^website_source,
    #         where: t.nsfw == false,
    #         order_by: [desc: :inserted_at]
    #       )

    #     %{"term" => term, "nsfw" => "on"} ->
    #       from(t in Torrent,
    #         where: ilike(t.name, ^"%#{term}%"),
    #         order_by: [desc: :inserted_at]
    #       )

    #     _ ->
    #       from(t in Torrent,
    #         where: ilike(t.name, ^"%#{params["term"]}%"),
    #         where: t.nsfw == false,
    #         order_by: [desc: :inserted_at]
    #       )
    #   end

    # page = results |> Repo.paginate(params)

    render(conn, :index,
      torrents: torrents,
      term: params["term"],
      website_source: params["website_source"]
    )
  end
end
