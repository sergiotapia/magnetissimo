defmodule Magnetissimo.TorrentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Magnetissimo.Torrents` context.
  """

  @doc """
  Generate a source.
  """
  def source_fixture(attrs \\ %{}) do
    {:ok, source} =
      attrs
      |> Enum.into(%{
        name: "Nyaa",
        url: "https://nyaa.si"
      })
      |> Magnetissimo.Torrents.create_source()

    source
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name",
        slug: "some slug"
      })
      |> Magnetissimo.Torrents.create_category()

    category
  end

  @doc """
  Generate a torrent.
  """
  def torrent_fixture(attrs \\ %{}) do
    {:ok, torrent} =
      attrs
      |> Enum.into(%{
        leechers: 42,
        magnet_url: "some magnet_url",
        magnet_hash: "a1426da021392a1dd76ddbffa8c1b635b09538f6",
        name: "some name",
        canonical_url: attrs[:canonical_url] || "https://nyaa.si/",
        seeders: 42,
        slug: "some slug",
        description: "Foobarbaz",
        published_at: DateTime.utc_now(),
        size_in_bytes: 42,
        source_id: attrs[:source_id] || source_fixture().id,
        category_id: attrs[:category_id] || category_fixture().id
      })
      |> Magnetissimo.Torrents.create_torrent()

    Magnetissimo.Repo.preload(torrent, [:source, :category])
  end
end
