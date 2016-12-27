defmodule Magnetissimo.TorrentController do
  use Magnetissimo.Web, :controller
  alias Magnetissimo.Torrent

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
