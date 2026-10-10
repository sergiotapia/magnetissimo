defmodule Magnetissimo.Torrents.SearchHit do
  @moduledoc """
  A torrent a source returned when it was asked for `term`.

  `term` is normalised with `Magnetissimo.Torrents.Search.normalize/1`. The
  search treats these rows as matches for that term, so whatever a source's own
  search engine found stays findable here by the same words.
  """

  use Ecto.Schema

  alias Magnetissimo.Torrents.Torrent

  schema "search_hits" do
    field :term, :string

    belongs_to :torrent, Torrent

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end
end
