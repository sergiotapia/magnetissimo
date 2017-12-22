defmodule Magnetissimo.Contents do

  alias Magnetissimo.{Repo, Torrent}
  require Logger
  import Ecto.Query

  def save_torrent(torrent) do
    changeset = Torrent.changeset(%Torrent{}, torrent)
    case Repo.insert(changeset) do
      {:ok, _torrent} ->
        Logger.info "Torrent saved to database: #{torrent.name}"
      {:error, changeset} ->
        errors = for {key, {message, _}} <- changeset.errors do
          "#{key} #{message}"
        end
        Logger.error "Torrent skipped: #{torrent.name} - Errors: #{Enum.join(errors, ", ")}"
    end
  end

  def total_by_website_source(website_source) when website_source == "" do
    query = from t in Torrent,
            select: count("*")
    Repo.one(query)
  end

  def total_by_website_source(website_source) do
    query = from t in Torrent,
            where: t.website_source == ^website_source,
            select: count("*")
    Repo.one(query)
  end
end
