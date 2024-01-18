defmodule Magnetissimo.TorrentsTest do
  use Magnetissimo.DataCase

  alias Magnetissimo.Torrents

  describe "categories" do
    alias Magnetissimo.Torrents.Category

    import Magnetissimo.TorrentsFixtures

    @invalid_attrs %{name: nil, slug: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Torrents.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Torrents.get_category!(category.id) == category
    end

    test "get_category_by_name_or_alias!/1 returns the category with name" do
      category = category_fixture(%{name: "Donut"})
      assert Torrents.get_category_by_name_or_alias!("Donut") == category
    end

    test "get_category_by_name_or_alias!/1 returns the category with alias" do
      category = category_fixture(%{alternative_names: ["donut", "biscuit"]})
      assert Torrents.get_category_by_name_or_alias!("biscuit") == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", slug: "some slug"}

      assert {:ok, %Category{} = category} = Torrents.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.slug == "some-name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Torrents.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", slug: "some updated slug"}

      assert {:ok, %Category{} = category} = Torrents.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.slug == "some-updated-name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Torrents.update_category(category, @invalid_attrs)
      assert category == Torrents.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Torrents.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Torrents.change_category(category)
    end
  end

  describe "sources" do
    alias Magnetissimo.Torrents.Source

    import Magnetissimo.TorrentsFixtures

    @invalid_attrs %{name: nil, url: nil, slug: nil}

    test "list_sources/0 returns all sources" do
      source = source_fixture()
      assert Torrents.list_sources() == [source]
    end

    test "get_source!/1 returns the source with given id" do
      source = source_fixture()
      assert Torrents.get_source!(source.id) == source
    end

    test "create_source/1 with valid data creates a source" do
      valid_attrs = %{name: "some name", url: "some url", slug: "some slug"}

      assert {:ok, %Source{} = source} = Torrents.create_source(valid_attrs)
      assert source.name == "some name"
      assert source.url == "some url"
      assert source.slug == "some-name"
    end

    test "create_source/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Torrents.create_source(@invalid_attrs)
    end

    test "update_source/2 with valid data updates the source" do
      source = source_fixture()

      update_attrs = %{
        name: "some updated name",
        url: "some updated url",
        slug: "some updated slug"
      }

      assert {:ok, %Source{} = source} = Torrents.update_source(source, update_attrs)
      assert source.name == "some updated name"
      assert source.url == "some updated url"
      assert source.slug == "some-updated-name"
    end

    test "update_source/2 with invalid data returns error changeset" do
      source = source_fixture()
      assert {:error, %Ecto.Changeset{}} = Torrents.update_source(source, @invalid_attrs)
      assert source == Torrents.get_source!(source.id)
    end

    test "delete_source/1 deletes the source" do
      source = source_fixture()
      assert {:ok, %Source{}} = Torrents.delete_source(source)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_source!(source.id) end
    end

    test "change_source/1 returns a source changeset" do
      source = source_fixture()
      assert %Ecto.Changeset{} = Torrents.change_source(source)
    end
  end

  describe "torrents" do
    alias Magnetissimo.Torrents.Torrent

    import Magnetissimo.TorrentsFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      slug: nil,
      published_at: nil,
      canonical_url: nil,
      magnet_url: nil,
      magnet_hash: nil,
      leechers: nil,
      seeders: nil,
      size_in_bytes: nil
    }

    test "list_torrents/0 returns all torrents" do
      torrent = torrent_fixture()
      assert Torrents.list_torrents() == [torrent]
    end

    test "get_torrent!/1 returns the torrent with given id" do
      torrent = torrent_fixture()
      assert Torrents.get_torrent!(torrent.id) == torrent
    end

    test "create_torrent/1 with valid data creates a torrent" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        slug: "some slug",
        published_at: ~U[2024-01-17 00:11:00.000000Z],
        canonical_url: "some canonical_url",
        magnet_url: "some magnet_url",
        magnet_hash: "some magnet_hash",
        leechers: 42,
        seeders: 42,
        size_in_bytes: 42,
        category_id: category_fixture().id,
        source_id: source_fixture().id
      }

      assert {:ok, %Torrent{} = torrent} = Torrents.create_torrent(valid_attrs)
      assert torrent.name == "some name"
      assert torrent.description == "some description"
      assert torrent.slug == "some-name"
      assert torrent.published_at == ~U[2024-01-17 00:11:00.000000Z]
      assert torrent.canonical_url == "some canonical_url"
      assert torrent.magnet_url == "some magnet_url"
      assert torrent.magnet_hash == "some magnet_hash"
      assert torrent.leechers == 42
      assert torrent.seeders == 42
      assert torrent.size_in_bytes == 42
    end

    test "create_torrent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Torrents.create_torrent(@invalid_attrs)
    end

    test "update_torrent/2 with valid data updates the torrent" do
      torrent = torrent_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        slug: "some updated slug",
        published_at: ~U[2024-01-18 00:11:00.000000Z],
        canonical_url: "some updated canonical_url",
        magnet_url: "some updated magnet_url",
        magnet_hash: "some updated magnet_hash",
        leechers: 43,
        seeders: 43,
        size_in_bytes: 43
      }

      assert {:ok, %Torrent{} = torrent} = Torrents.update_torrent(torrent, update_attrs)
      assert torrent.name == "some updated name"
      assert torrent.description == "some updated description"
      assert torrent.slug == "some-updated-name"
      assert torrent.published_at == ~U[2024-01-18 00:11:00.000000Z]
      assert torrent.canonical_url == "some updated canonical_url"
      assert torrent.magnet_url == "some updated magnet_url"
      assert torrent.magnet_hash == "some updated magnet_hash"
      assert torrent.leechers == 43
      assert torrent.seeders == 43
      assert torrent.size_in_bytes == 43
    end

    test "update_torrent/2 with invalid data returns error changeset" do
      torrent = torrent_fixture()
      assert {:error, %Ecto.Changeset{}} = Torrents.update_torrent(torrent, @invalid_attrs)
      assert torrent == Torrents.get_torrent!(torrent.id)
    end

    test "delete_torrent/1 deletes the torrent" do
      torrent = torrent_fixture()
      assert {:ok, %Torrent{}} = Torrents.delete_torrent(torrent)
      assert_raise Ecto.NoResultsError, fn -> Torrents.get_torrent!(torrent.id) end
    end

    test "change_torrent/1 returns a torrent changeset" do
      torrent = torrent_fixture()
      assert %Ecto.Changeset{} = Torrents.change_torrent(torrent)
    end
  end
end
