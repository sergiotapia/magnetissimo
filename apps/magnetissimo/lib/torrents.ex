defmodule Magnetissimo.Torrents do
  alias Magnetissimo.Repo
  alias Magnetissimo.Torrent
  import Ecto.Query

  def all() do
    Torrent |> order_by(desc: :inserted_at) |> Repo.all()
  end

  def search(params) do
    torrents =
      case params do
        %{"term" => term, "website_source" => website_source}
        when website_source != "" ->
          from(t in Torrent,
            where: ilike(t.name, ^"%#{term}%"),
            where: t.website_source == ^website_source,
            order_by: [desc: :inserted_at]
          )

        %{"term" => term} ->
          from(t in Torrent,
            where: ilike(t.name, ^"%#{term}%"),
            order_by: [desc: :inserted_at]
          )

        _ ->
          from(t in Torrent,
            order_by: [desc: :inserted_at]
          )
      end

    Repo.paginate(torrents, params)
  end
end
