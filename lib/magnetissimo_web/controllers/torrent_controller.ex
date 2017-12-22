defmodule MagnetissimoWeb.TorrentController do
  use MagnetissimoWeb, :controller
  alias Magnetissimo.{Repo,Torrent}
  import Ecto.Query

  def summary(conn, _) do
    tallies =
      from t in Torrent,
      group_by: t.website_source,
      select: %{
        name: t.website_source,
        totals: count(t.id)
      }
    tallies = Repo.all(tallies)

    render conn, :summary, tallies: tallies
  end
end
