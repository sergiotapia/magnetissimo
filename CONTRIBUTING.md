# Contributing

Thanks for wanting to work on Magnetissimo. This guide covers how to get set
up, what every commit has to pass, how the code is laid out, how to add a
torrent source, and the decisions that look odd until you know why they
were made.

If you are an AI agent, `AGENTS.md` is written for you and says the same
things more tersely.

## Setup

Tool versions are pinned in `.mise.toml`: Elixir 1.20.4 on OTP 29.1.1.

```bash
mise install
mix setup             # deps, SQLite database, migrations, sources, assets
iex -S mix phx.server # http://localhost:4000
```

`mix setup` seeds the `sources` table and, in dev only, about fifty demo
torrents (`priv/repo/seeds.exs`) so the page has something on it. Their
hashes and URLs are made up. Everything else gets into the index because
someone searched for it. `mix ecto.reset` starts over.

## Where things are

```
lib/magnetissimo/
  torrents.ex              the context: list, count, index, search
  torrents/search.ex       free text to FTS5 SQL, ranking
  torrents/{torrent,source,search_hit}.ex
  taxonomy.ex              the Torznab category list, in code
  source_search.ex         asks every source at once, caches, broadcasts
  crawlers.ex              runs one crawler's search and indexes the result
  crawlers/crawler.ex      the behaviour every source implements
  crawlers/http.ex         the single Req GET every crawler makes
  crawlers/categories.ex   compile-time site→Torznab category mapping
  crawlers/pacer.ex        holds each site to two searches at a time
  crawlers/<source>.ex     one module per site
  dht.ex                   the DHT source: config, presets, PubSub
  dht/                     the DHT crawler: KRPC over UDP, metadata over TCP,
                           sampler, fetcher, classifier, indexer, stats
  seeds.ex                 the sources rows
  release.ex               migrate and seed, for a release with no Mix
lib/magnetissimo_web/
  live/home_live.ex        search, filters, sources, results
  live/torrent_live.ex     one torrent, with its files when known
  live/dht_live.ex         the DHT page: what the crawler just found, live
  controllers/torznab_*    the Torznab API at /api, for the *arr apps
  controllers/torrent_*    the JSON API
  components/              layouts, core and dossier components
  format.ex                sizes, counts, ages, hashes
config/runtime.exs         production settings, read from the environment
rel/overlays/bin/          bin/server and bin/migrate, copied into a release
Dockerfile, compose.yaml   the image and how homelabs run it
.github/workflows/docker.yml  publishes the image to ghcr.io
docs/design.md             the visual design system
docs/dht.md                how the DHT crawler works, and its measured rates
```

### How a search flows

1. `HomeLive` patches the URL (`?q=`). `handle_params/3` subscribes to the
   term and calls `SourceSearch.request/1`, then reads the index through
   `Torrents.search_torrents/2` and renders it straight away.
2. `SourceSearch` starts one supervised task per crawler. If the same term,
   or the same words in another order, is already in flight, a second
   reader joins it. If every source answered it
   within the last 15 minutes, nothing is asked again.
3. Each task calls `Crawlers.search/2`, which waits for the site's turn in
   `Crawlers.Pacer` (two searches per site at a time, a second apart, from
   readers and Torznab clients alike). The crawler fetches and parses, then
   `Torrents.index_torrents/2` upserts the batch by `magnet_hash` and
   records each hit for the term in `search_hits`, all in one transaction.
4. Each answer is broadcast on PubSub. `HomeLive` reloads from the index and
   marks the rows that weren't there before, which then slide in.
5. A source gets 20 seconds. After that its task is killed, which rolls back
   its transaction, and it is shown as failed.

`GET /api/search/:term` and a Torznab search (`GET /api?t=search&q=…`, or
`tvsearch`, `movie`, `music`, `book`) do the same thing, but wait for every
source to answer or time out (`SourceSearch.await/1`) before reading the
index, since an API client can't receive results later.

A Torznab request with no text is a client's RSS poll or Test button. It
comes every 15 to 30 minutes from every app, so `TorznabController`
answers it from the index alone and never calls `SourceSearch`.
`TorznabRequest` rebuilds each function's parameters (`season` and `ep`,
`artist` and `album`, `author` and `title`) into one free-text term, and
the caps advertise only those. Don't advertise `imdbid` or `tvdbid`:
nothing here can resolve an id, and Radarr would then send searches with
nothing else in them.

## Checks

`mix precommit` has to pass before you commit Elixir changes. It runs:

| Step | What fails it |
| --- | --- |
| `compile --warnings-as-errors` | Any compiler warning. |
| `deps.unlock --unused`, `format` | Nothing. They tidy the lockfile and format the code. |
| `credo --strict` | Any Credo issue, including every [ExSlop](https://github.com/elixir-vibe/ex_slop) check for patterns generated code tends to have. See `.credo.exs`. |
| `ex_dna` | Duplicated code in `lib/` or `test/`. That includes copies with renamed variables or changed literals, and near-misses at 85% similarity. Extract the shared code. |
| `reach.check --arch` | A break of the rules in `.reach.exs`: the domain calling `MagnetissimoWeb`, web code calling `Repo` or `Ecto.Query`, any HTTP client other than Req, `System.cmd`/`Port.open`, `String.to_atom`, or `IO.puts`/`IO.inspect`. |
| `dialyzer` | Any warning, including an ignored return value. Write `_ = call()` when ignoring one is deliberate. The first run builds a PLT and takes a few minutes. |
| `test` | Any failing test. |

When a check finds something, fix the code. Don't turn the check off. If a
check is genuinely wrong about one line, disable it on that line only and
give the reason:
`# credo:disable-for-next-line Check.Name because …`.

## Commits

- **One logical change per commit, committed as soon as it works.** That
  might be a migration, a crawler, or a passing test. A small honest step is
  better than one large commit at the end.
- **Never amend, rebase, squash or force-push an existing commit.** Fix it
  in a follow-up commit. The course corrections are part of the history.
- **Subject:** imperative and capitalized, no trailing period, under 72
  characters. Say what the change gets you: `Crawl OxTorrent, a page per
  release`, not `add oxtorrent`.
- **Body:** explain *why*, wrapped at about 72 characters, whenever the
  subject doesn't make it obvious. When you replace something the 2.0.0 app
  did, say what it did and why you changed it.
- If `mix precommit` fails for a reason unrelated to your change, commit
  anyway and say so in the body.
- Never commit secrets or database files. `*.db` is gitignored.

## Adding a source

Most contributions will be this one. Keep `Magnetissimo.Crawlers.Yts` open
for the simplest example, and `AudioBookBay` or `OxTorrent` for a site that
needs a second request per result.

1. **Find the cheapest way in.** Look for a JSON API, an RSS feed with a
   search parameter, or the endpoint the site's own JavaScript calls (The
   Pirate Bay's pages are filled from `apibay.org`). Scrape HTML only when
   there's nothing else. One request per search is ideal. If you need one
   per result, cap how many, skip pages already in the index
   (`Torrents.torrents_by_canonical_url/1`), and pace the requests.
2. **Write the crawler** at `lib/magnetissimo/crawlers/<site>.ex`,
   implementing `Magnetissimo.Crawlers.Crawler`:
   - `source_name/0` is the `sources.name` row.
   - `categories/0` is a `Categories.mapping!/3` from the site's most stable
     category key (an id rather than a display name) to Torznab names, with
     a `:fallback`. Start from the `categorymappings` in the site's
     [Prowlarr indexer definition](https://github.com/Prowlarr/Indexers)
     and refine it. An adult site falls back to `XXX`.
   - `search/1` returns `{:ok, [attrs]}` or `{:error, reason}`, and must
     never raise because a site is down. Fetch through `Crawlers.Http.get/2`,
     merging in `Application.get_env(:magnetissimo, __MODULE__, [])` so tests
     can stub it.
   - Attrs need `name`, `canonical_url`, `published_at`, `size_in_bytes`, a
     lowercase 40-character `magnet_hash`, a full `magnet_url`,
     `category_id` and `source_id`. If the site gives only an infohash, build
     the magnet with `Crawlers.Magnet`. If it names its own trackers, use
     those.
   - Write the moduledoc as notes for the next person. Cover how the site is
     read, what it gets wrong, and what you had to work around.
3. **Register it.** Add it to `@crawlers` in `Magnetissimo.Crawlers`, add its
   row to `Magnetissimo.Seeds`, and add a `Req.Test` plug for it in
   `config/test.exs`.
4. **Test it from saved fixtures.** Put a trimmed real response in
   `test/support/fixtures/<site>_fixtures.ex` and write
   `test/magnetissimo/crawlers/<site>_test.exs` against it. Never let a test
   reach the live site. List every category the site publishes in
   `test/magnetissimo/crawlers/categories_test.exs`.
5. **Try it for real.** Run `mix run priv/repo/seeds.exs`, start the server,
   search, and check the logs (`[Site] search "term": N found, M new`).

## Decisions worth knowing

These are the parts most likely to surprise you. Each was a deliberate choice.

- **Sites are asked only when someone searches.** The 2.0.0 app polled
  every site every five minutes. In October 2026 Nyaa and AudioBookBay both
  started dropping our connections, so the timers were removed. Please don't
  add a scheduler, a job queue, or a "latest" crawl of a site back.
- **The DHT is the one source crawled in the background, and it is off by
  default.** It is not a site: there is nobody to block us, and it can't
  answer a text search, only map infohashes to peers. So `Magnetissimo.DHT`
  walks it all the time once someone switches it on at `/dht`, inside the
  packet budget the rate slider picks. Those two settings are a database row,
  and `DHT.Runner` starts, stops or restarts the crawler when they change. It doesn't go through `Crawlers.Pacer`, which paces HTTP to
  sites, and it isn't in `Crawlers.all/0`, so a search never waits on it.
  What it finds stays out of the views without a search ("Fresh magnets",
  the Torznab RSS poll, `/api/latest`), where it would bury the sites'
  releases, and shows on `/dht` instead. Its rates were measured on a home
  connection; see `docs/dht.md` before changing them.
- **A home router counts connections, not bytes.** The DHT crawler's
  bandwidth is tiny. What hurts a household is the router's
  connection-tracking table: every distinct address the crawler talks to
  is an entry for 30 seconds to 2 minutes. The crawler is a read-only node
  (BEP 43), sends no packet outside its budget, stops sampling while the
  fetch queue is full, and resets every TCP connection it closes.
- **Nothing is retried.** A non-200 response comes back as
  `{:error, {:http_status, n}}` and is shown as that source failing.
  Retrying only adds to the burst that gets a rate-limited site to shut us
  out.
- **`magnet_hash` is a torrent's identity, not its name.** YTS returns 720p,
  1080p and 2160p under one name. A duplicate hash is the normal result of
  a source returning something already indexed. The existing row keeps its
  data, but takes the fresh seeder and leecher counts (unless the source
  knows none, as AudioBookBay and the DHT don't), gains a file list if it
  had none, and it can move out of `Other` if a source knows a better
  category.
- **`magnet_url` is the whole URI, scheme included.** The old column
  stored the URI without `magnet:`, so its name didn't match its contents.
- **Categories are the Torznab standard, defined in code** in
  `Magnetissimo.Taxonomy`, and `category_id` is the Torznab number. Never
  invent a category. A mapping to a name that doesn't exist fails to compile.
- **Primary keys are integers.** On SQLite the integer primary key *is* the
  rowid that the FTS5 indexes join on. Don't use `:binary_id` or UUIDs, and
  never pass `--binary-id`.
- **Never hand user text to FTS5 `MATCH`.** `Torrents.Search` splits the
  text into tokens and quotes each one. Without the quotes, `ubuntu:24.04`
  and `x265-` are query syntax and raise. Search through
  `Torrents.search_torrents/2`.
- **The FTS5 delete trigger uses the special `'delete'` command.** A plain
  insert of the old values silently corrupts the index. After touching that
  table, run
  `insert into torrents_search(torrents_search) values('integrity-check')`.
- **Migrations must roll back.** Before a data change counts as done, run
  `mix ecto.rollback --all && mix ecto.migrate`. Always generate migration
  files with `mix ecto.gen.migration`.
- **The URL is the page state.** The query, category, sources, sort and page
  all live in the URL, so every view is a link and the page works without
  JavaScript.
- **Two themes, hand-written Tailwind.** Light and dark share one set of
  tokens, so use the tokens rather than raw colours and both stay right.
  daisyUI was removed on purpose. Read `docs/design.md` before adding UI.

## Tests

- `Magnetissimo.DataCase` gives each test a SQL sandbox, `ConnCase` runs
  requests through the router, and `Magnetissimo.TorrentsFixtures` seeds the
  sources and inserts torrents with sensible defaults.
- Anything that writes to the database is `async: false`, because SQLite
  has a single writer. Pure tests stay async.
- No network calls. Stub HTTP with `Req.Test`.
- `Magnetissimo.FastCrawler` and `SlowCrawler` in `test/support/crawlers/`
  are stand-in sources for testing `SourceSearch` and the LiveView. A term
  containing `crash` or `fail` makes the fast one misbehave.
- Never use `Process.sleep`. Wait on a message, a `:DOWN`, or
  `:sys.get_state/1`.
- LiveView tests target DOM ids with `element/2` and `has_element?/2`, and
  check outcomes rather than exact wording.

| What you changed | Where its tests go |
| --- | --- |
| Search, ranking, filters, sorting | `test/magnetissimo/torrents/search_test.exs` |
| Source search, caching, timeouts | `test/magnetissimo/source_search_test.exs` |
| A crawler | `test/magnetissimo/crawlers/<site>_test.exs` |
| Category mappings | `test/magnetissimo/crawlers/categories_test.exs` |
| The home page | `test/magnetissimo_web/live/home_live_test.exs` |
| The pacer | `test/magnetissimo/crawlers/pacer_test.exs` |
| The JSON API | `test/magnetissimo_web/controllers/torrent_controller_test.exs` |
| The Torznab API | `test/magnetissimo_web/controllers/torznab_{request,controller}_test.exs` |
| Formatting | `test/magnetissimo_web/format_test.exs` |

## Releasing

The image is built by `.github/workflows/docker.yml` with Docker's
`github-builder` reusable workflow. It builds amd64 and arm64 on native
runners and pushes to `ghcr.io/sergiotapia/magnetissimo`:

- Every push to `master` publishes `:master` and `:edge`.
- A `vX.Y.Z` tag publishes `:X.Y.Z`, `:X.Y`, `:X` and `:latest`.
- Pull requests build the image without pushing it.

To cut a release, bump `version` in `mix.exs`, commit, then tag and push:
`git tag v3.2.0 && git push origin v3.2.0`. GHCR packages are private when
first created, so after the first push, make the package public in its
settings on GitHub.

Things to keep working when you touch the release or the image:

- **A release migrates and seeds on boot.** `Application.start/2` calls
  `Release.migrate/0` whenever `RELEASE_NAME` is set, before the
  supervision tree starts. A new source's row is therefore created on the
  first boot after an upgrade, with nobody running seeds. It migrates on a
  single connection of its own. An `Ecto.Migrator` child sharing the Repo's
  pool crashed about one fresh boot in three: a connection opened on the
  empty file still had the empty schema, and a later migration ran on it.
- **Zero required configuration in Docker.** The image sets
  `DATABASE_PATH`. `SECRET_KEY_BASE` falls back to a key generated once and
  stored next to the database (`config/runtime.exs`). Don't add a required
  variable without a sensible default.
- **No `force_ssl`, and `check_origin: :conn`.** Most installs are reached
  at `http://<lan-ip>:4000`. Redirecting that to HTTPS breaks them, and so
  does a socket that only accepts one configured host. TLS is the reverse
  proxy's job.
- **The runner is `debian-slim` and runs as `nobody`,** with `/data` owned by
  `nobody` so a named volume starts out writable. Keep the builder and
  runner on the same Debian release, and on the Elixir/OTP versions in
  `.mise.toml`.
- **To test the image locally:**
  `docker compose up -d --build`, then open http://localhost:4000. To start
  from a clean database, run `docker compose down -v` first.

To try a bare release without Docker:

```bash
MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release --overwrite
mkdir -p /tmp/mg && DATABASE_PATH=/tmp/mg/m.db PORT=4100 \
  _build/prod/rel/magnetissimo/bin/server
```

## Still to build

- A health check route, for Docker's `HEALTHCHECK` and uptime monitors.
- More tests for `TorrentLive`; there are a few, for its file list.
- The DHT crawler's metadata fetch speaks plaintext only. Some peers insist
  on Message Stream Encryption (MSE) and close the connection; supporting
  it would raise the fetch success rate.
