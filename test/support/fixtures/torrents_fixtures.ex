defmodule Magnetissimo.TorrentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Magnetissimo.Torrents` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name",
        slug: "some slug",
        alternative_names: ["some alternative name"]
      })
      |> Magnetissimo.Torrents.create_category()

    category
  end

  @doc """
  Generate a source.
  """
  def source_fixture(attrs \\ %{}) do
    {:ok, source} =
      attrs
      |> Enum.into(%{
        name: "some name",
        slug: "some slug",
        url: "some url"
      })
      |> Magnetissimo.Torrents.create_source()

    source
  end

  @doc """
  Generate a torrent.
  """
  def torrent_fixture(attrs \\ %{}) do
    category = category_fixture()
    source = source_fixture()

    {:ok, torrent} =
      attrs
      |> Enum.into(%{
        canonical_url: "some canonical_url",
        description: "some description",
        leechers: 42,
        magnet_hash: "some magnet_hash",
        magnet_url: "some magnet_url",
        name: "some name",
        published_at: ~U[2024-01-17 00:11:00.000000Z],
        seeders: 42,
        size_in_bytes: 42,
        slug: "some slug",
        category_id: category.id,
        source_id: source.id
      })
      |> Magnetissimo.Torrents.create_torrent()

    torrent =
      torrent
      |> Magnetissimo.Repo.preload([:category, :source])

    torrent
  end
end
