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
- **One SQLite database.** No Postgres and no job queue. To back it up,
  stop the app and copy the data folder.

## Running it

### With Docker

This is the easiest way, and works on anything that runs Docker: a
homelab server, a NAS, or a Raspberry Pi (the image is built for amd64 and
arm64). Save this as `compose.yaml`:

```yaml
services:
  magnetissimo:
    image: ghcr.io/sergiotapia/magnetissimo:latest
    container_name: magnetissimo
    restart: unless-stopped
    ports:
      - "4000:4000"
    volumes:
      - magnetissimo-data:/data

volumes:
  magnetissimo-data:
```

Then start it:

```bash
docker compose up -d
```

Open `http://<your server>:4000`. Nothing else needs configuring. The
database and a generated secret key are kept in the `magnetissimo-data`
volume, and every start runs any pending migrations. To upgrade, run
`docker compose pull && docker compose up -d`.

To keep the data in a folder instead of a volume, mount the folder at
`/data` and run the container as the folder's owner. The image runs as
`nobody` by default, which can't write to a folder Docker created as root:

```yaml
    user: "1000:1000"
    volumes:
      - ./data:/data
```

If you've cloned the repository, the `compose.yaml` there also builds the
image from source when it can't be pulled: run `docker compose up -d --build`.

`:latest` is the newest release. `:edge` follows every commit to `master`,
and `:0.1` or `:0.1.0` pin a version.

### As an Elixir release

A [release](https://mix.hexdocs.pm/Mix.Tasks.Release.html) is a
self-contained directory with the Erlang runtime included. Build it on the
same OS and CPU architecture as the server it will run on:

```bash
mise install                     # Elixir 1.20.4 / OTP 29.1.1
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix assets.setup
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

Copy `_build/prod/rel/magnetissimo` to the server and start it:

```bash
mkdir -p /var/lib/magnetissimo
DATABASE_PATH=/var/lib/magnetissimo/magnetissimo.db bin/server
```

`bin/server` starts the web server. `bin/magnetissimo` has the rest of the
commands: `daemon`, `stop`, `remote` for a console into the running app,
and `eval`. `bin/migrate` migrates the database without starting the app,
although starting the app already does that.

### Configuration

Only `DATABASE_PATH` is required, and the Docker image already sets it.

| Variable | Default | What it does |
| --- | --- | --- |
| `DATABASE_PATH` | `/data/magnetissimo.db` in Docker | The SQLite file. Its directory must exist and be writable. |
| `PORT` | `4000` | The HTTP port. |
| `SECRET_KEY_BASE` | generated | Signs cookies. If you don't set it, a random one is generated on first start and saved as `secret_key_base` next to the database. |
| `PHX_HOST` | none | Your public hostname, if the app is behind an HTTPS reverse proxy. Leave it unset for plain `http://<ip>:4000`. |
| `POOL_SIZE` | `5` | Database connections. |

Magnetissimo speaks plain HTTP. To serve it over HTTPS, put it behind a
reverse proxy such as Caddy, Traefik or nginx, and forward WebSockets, which
is what makes results stream in. Any host name or IP the app is reached at
works without extra configuration. The live-update socket only accepts
pages served from the same host.

### For development

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
