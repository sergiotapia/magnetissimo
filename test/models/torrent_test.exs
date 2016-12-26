defmodule Magnetissimo.TorrentTest do
  use Magnetissimo.ModelCase

  alias Magnetissimo.Torrent

  @valid_attrs %{leechers: 42, magnet: "some content", name: "some content", seeders: 42, size: "some content", website_source: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Torrent.changeset(%Torrent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Torrent.changeset(%Torrent{}, @invalid_attrs)
    refute changeset.valid?
  end
end
