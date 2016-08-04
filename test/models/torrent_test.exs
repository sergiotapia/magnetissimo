defmodule Magnetissimo.TorrentTest do
  use Magnetissimo.ModelCase

  alias Magnetissimo.Torrent

  @valid_attrs %{leechers: 42, magnet: "some content", name: "some content", seeders: 42, source: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Torrent.changeset(%Torrent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Torrent.changeset(%Torrent{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "change is invalid if existing magnet link is in db" do
    Torrent.changeset(%Torrent{}, %{magnet: "some_content", leechers: 10, seeders: 10, name: "example", source: "example"})
    |> Magnetissimo.Repo.insert

    new_torrent = Torrent.changeset(%Torrent{}, %{magnet: "some_content", leechers: 10, seeders: 10, name: "example", source: "example"})
    {:error, changeset} = Repo.insert(new_torrent)
    assert {"has already been taken", []} == changeset.errors[:magnet]
  end
end
