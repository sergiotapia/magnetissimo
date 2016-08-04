# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Magnetissimo.Repo.insert!(%Magnetissimo.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Magnetissimo.Repo
alias Magnetissimo.Torrent

(1..1000)
|> Enum.each(fn i ->
  Repo.insert! %Torrent{
    name: Elixilorem.sentence,
    magnet: "magnet:#{:random.uniform(200000)}#{i}",
    leechers: :random.uniform(1000),
    seeders: :random.uniform(1000),
    source: ""
  }
end)