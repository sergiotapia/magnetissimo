<h1 align="center">Magnetissimo</h1>

<p align="center">
  A self-hosted torrent indexer. Search once, ask eight torrent sites at the
  same time, and keep every magnet link they hand back.
</p>

<p align="center">
  <img src="docs/screenshot.webp" alt="The Magnetissimo home page: a search box under the chrome wordmark, source and category filters on the left, and the freshest magnets listed with size, swarm and age" width="820">
</p>

## What it does

You type a term. Magnetissimo answers from its own index straight away, and
at the same moment asks every source's own search for that term. Each site's
answer is indexed as it lands, and the new rows slide into the page while
you watch. The next person to search for the same thing gets it from the
index.

Nothing is crawled on a timer. A site only hears from Magnetissimo when
someone searches, so the index grows into a record of what you looked for.

- **Eight sources:** YTS, Nyaa.si, Sukebei, TorrentDownloads, AudioBookBay,
  The Pirate Bay, EZTV and OxTorrent.
- **Torznab categories.** Every torrent is filed under the standard
  Newznab/Torznab category list that Sonarr, Radarr, Prowlarr and Jackett
  use, whatever the source called it.
- **Search that copes with real names.** `spider-man` finds
  `Spider.Man.2002`, `toy story 4` matches the `4`, and a fragment of a
  Japanese title matches without any spaces to split on. Better-seeded
  copies rank first among near-identical names.
- **Works without JavaScript.** Searching, filtering, sorting and paging are
  all links and plain GET forms. With JavaScript on, results stream in live.
- **A JSON API** for scripts and for Sonarr and Radarr.
- **One SQLite file.** No Postgres and no job queue. Back it up by copying
  one file.

## Running it

You need Elixir 1.20 and Erlang/OTP 29. The exact versions are pinned in
`.mise.toml`, so with [mise](https://mise.jdx.dev):

```bash
git clone https://github.com/sergiotapia/magnetissimo
cd magnetissimo
mise install
mix setup          # dependencies, database, sources, assets
mix phx.server
```

Then open [localhost:4000](http://localhost:4000). In development the
database starts with a few dozen demo torrents so the page isn't empty.
Search for something and the real sources start filling the index.

### In production

Build a release and set four environment variables:

```bash
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

DATABASE_PATH=/var/lib/magnetissimo/magnetissimo.db \
SECRET_KEY_BASE="$(mix phx.gen.secret)" \
PHX_HOST=magnetissimo.example.com \
PHX_SERVER=true \
_build/prod/rel/magnetissimo/bin/magnetissimo start
```

| Variable | Required | What it does |
| --- | --- | --- |
| `DATABASE_PATH` | yes | Where the SQLite file lives. It is created if it does not exist. |
| `SECRET_KEY_BASE` | yes | Signs cookies. Generate one with `mix phx.gen.secret`. |
| `PHX_HOST` | yes | The host name the app is reached at. |
| `PHX_SERVER` | yes | Set it to `true` to start the web server. |
| `PORT` | no | The HTTP port. Defaults to `4000`. |
| `POOL_SIZE` | no | Database connections. Defaults to `5`. |

A release runs its own migrations when it starts. In production the app
redirects plain HTTP to HTTPS for any host other than `localhost`, so put it
behind a proxy that terminates TLS and sets `X-Forwarded-Proto`. There is no
Docker image yet.

## API

| Endpoint | Returns |
| --- | --- |
| `GET /api/latest` | The 50 most recently published torrents in the index. |
| `GET /api/search/:term` | The best 50 matches for `term`. |

A search gives the sources up to ten seconds to answer before it reads the
index. A term that was searched in the last fifteen minutes is answered
straight from the index. Both endpoints return `{"data": [...]}`, where each
torrent looks like this:

```json
{
  "id": 11673,
  "name": "Dune Part Two (2024) [1080p] [WEBRip] 88",
  "description": null,
  "canonical_url": "https://thepiratebay.org/description.php?id=75005578",
  "published_at": "2024-04-06T04:39:43.000000Z",
  "seeders": 924,
  "leechers": 147,
  "size_in_bytes": 2968337547,
  "magnet_hash": "2770fe270845674966e184be60ed1be0fe494f3a",
  "magnet_url": "magnet:?xt=urn:btih:2770fe270845674966e184be60ed1be0fe494f3a&dn=Dune+Part+Two…&tr=…",
  "category": "Movies/HD",
  "category_id": 2040,
  "source": "The Pirate Bay"
}
```

The field names are the same as the 2.0.0 API, so anything that read the old
app keeps working. `category_id` is the Torznab number. A proper Torznab
endpoint, so Sonarr and Radarr can add Magnetissimo as an indexer directly,
is the next thing to build.

## How it is built

Phoenix 1.8 and LiveView 1.2 on Bandit, with Ecto on SQLite. Search runs
on two FTS5 indexes: one on trigrams for substrings in any script, and one on
whole words for the short tokens trigrams can't match. All HTTP goes through
[Req](https://hexdocs.pm/req). The interface is hand-written Tailwind with no
component library. Its look, a corporate Y2K glass atrium, is described in
[`docs/design.md`](docs/design.md).

This is a ground-up rewrite of Magnetissimo 2.0.0, which ran on Postgres,
crawled four sites every five minutes, and stored a magnet column that
didn't contain the `magnet:` scheme. The commit log tells the story of the
rewrite one step at a time.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). It covers setup, the checks every
commit has to pass, how to add a new source, and the handful of things in
this codebase that look odd but are deliberate.

## A note on use

Magnetissimo indexes magnet links that other sites already publish. It hosts
no content and downloads nothing. What you search for and what you do with
the links is your responsibility, under the laws where you live.
