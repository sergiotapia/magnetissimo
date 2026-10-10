# Contributing

## Where this project is

Magnetissimo is being rewritten from the 2.0.0 app at `~/Work/magnetissimo-old`.
Read `legacy-project.md` in that repo for what the app does, how the crawlers
worked, and which of its rough edges are deliberate. That repo is the reference
for **intent**, not for code: it is Elixir 1.14 / Phoenix 1.7 / Postgres, and
this one is Phoenix 1.8 / LiveView 1.2 / SQLite.

Built so far:

- The data layer: `sources`, `torrents`, `search_hits`, and the
  `torrents_search` (trigram) and `torrents_words` FTS5 indexes. Categories
  are the Torznab standard, in code: `Magnetissimo.Taxonomy`.
- `Magnetissimo.Torrents`, the context over them.
- Phoenix 1.8 on Bandit, plain Tailwind.
- The UI: `HomeLive` (search, category filter, per-source status, latest
  torrents) and `TorrentLive` (one torrent as a dossier). The look is a CRT
  reading of the mood board in `docs/moodboard/`; `docs/design.md` is the
  design system, read it before adding a page.
- The JSON API, `GET /api/latest` and `GET /api/search/:term`, with the
  2.0.0 field names.
- Tests for the context, the LiveViews, the API and the formatting helpers.

Not built yet — don't assume any of it exists:

- Crawlers and the background jobs that run them.
- The Torznab endpoint for Sonarr and Radarr.

## Environment

Tool versions are pinned in `.mise.toml` (Elixir 1.20.4, OTP 29.1.1).

```bash
mise install
mix setup          # deps, database, migrations, seeds, assets
iex -S mix phx.server
```

## Committing

There is no remote yet. The commit log is the only record of how this was
built, so commit early and often and locally.

- **One logical change per commit.** Commit as soon as a step works — a
  migration, a crawler, a passing check — even if the feature around it is
  unfinished. Do not hold work back until it is finished or pretty. A messy
  honest step beats one large opaque commit at the end.
- **Never `--amend`, rebase, or force-push a commit that already exists.**
  Add a follow-up commit instead. The course corrections are part of the
  history. Never squash.
- `git add -A` is fine here; there is no unrelated churn to worry about.
- Run `mix precommit` before committing when the change touches Elixir. If it
  fails for a reason unrelated to your change, commit anyway and say so in the
  body.
- **Subject line:** imperative, capitalized, no trailing period, under ~72
  characters, and it says what the change gets you. `Index torrents with SQLite
  FTS5`, not `wip`.
- **Body** for anything non-trivial: explain *why* and any non-obvious
  constraint, wrapped at ~72 characters. When a decision replaced something the
  2.0.0 app did differently, say what and why — that is the part nobody can
  reconstruct later.
- Never commit secrets, `.env` files, or database files (`*.db` is gitignored).

## Checks

`mix precommit` must pass:

| Step | What fails it |
| --- | --- |
| `compile --warnings-as-errors` | Any compiler warning. |
| `deps.unlock --unused`, `format` | Nothing. They clean the lockfile and format the code. |
| `credo --strict` | Any Credo issue, including every [ExSlop](https://github.com/elixir-vibe/ex_slop) check for the patterns generated code tends to have. `.credo.exs` holds the list. |
| `ex_dna` | Any duplicated code in `lib/` or `test/`, including copies with renamed variables or changed literals, and near-misses at 85% similarity (`.ex_dna.exs`). Extract the shared code. |
| `reach.check --arch` | A break of the architecture rules in `.reach.exs`: the domain calling `MagnetissimoWeb`, the web layer calling `Repo` or `Ecto.Query` directly, any HTTP client other than `Req`, `System.cmd`, `Port.open`, `String.to_atom`, or `IO.puts`. |
| `dialyzer` | Any Dialyzer warning, including an ignored return value. Write `_ = call()` when ignoring it is deliberate. The first run builds a PLT in `_build/` and takes a minute or two. |
| `test` | Any failing test. |

Fix what a check finds instead of disabling it. If a check is wrong for one
line, disable it on that line with a reason
(`# credo:disable-for-next-line Check.Name because …`).

`AGENTS.md` has the long-form Phoenix, LiveView, Ecto and HEEx conventions.
Read it before writing UI or Ecto code.

## How we build a feature

1. **Migration.** `mix ecto.gen.migration name_with_underscores`. Never
   hand-name migration files.
2. **Schema** under `lib/magnetissimo/torrents/`.
3. **Context function** in `Magnetissimo.Torrents`. LiveViews and controllers
   call contexts and never touch `Repo` directly.
4. **UI** in a LiveView under `lib/magnetissimo_web/live/`, plain Tailwind.
5. **Tests** for the context, and for the LiveView where there is one.

## Patterns we use

- **Integer primary keys are load-bearing, not a style choice.** Every table
  uses Ecto's default `"id" INTEGER PRIMARY KEY AUTOINCREMENT`. On SQLite that
  column *is* the rowid, which is what the `torrents_search` external-content
  index joins on. Never reach for `:binary_id`, UUIDs, nanoid, or
  `ecto_identifier`, and never pass `--binary-id` to a generator.
- **Never pass user text to FTS5 `MATCH`.** FTS5 parses its argument as a query
  language, so ordinary search text raises: `ubuntu:24.04` gives
  `no such column: ubuntu`, `x265-` and `NOT` give syntax errors, `*` gives
  `unknown special query`. `Torrents.match_query/1` quotes each token;
  query through `Torrents.search_torrents/2` rather than writing `MATCH` by
  hand.
- **`magnet_hash` is the identity, not the name.** One source page yields
  several torrents that share a name — YTS returns 720p, 1080p and 2160p for a
  single movie — and only the hash tells them apart. A duplicate `magnet_hash`
  is the expected result of re-crawling a feed, not an error.
- **`magnet_url` holds the complete magnet URI**, scheme included. The old
  column stored `?xt=urn:btih:…` with `magnet:` re-added at render time, so the
  column name lied about its contents.
- **Categories are the Torznab standard, and each crawler maps its own.**
  `Magnetissimo.Taxonomy` is the Newznab/Torznab list Sonarr and Radarr speak;
  `category_id` is a Torznab number. Never add a category of our own. Each
  crawler declares a `Magnetissimo.Crawlers.Categories.mapping!/3` from the
  site's most stable key (an id where the feed has one, not a display name) to
  a Torznab name, with a fallback. For a new source, start from the
  `categorymappings` in its Prowlarr indexer definition and refine where the
  site says more. An adult source falls back to `XXX`. List every category the
  site publishes in `test/magnetissimo/crawlers/categories_test.exs`; an
  unmapped one is logged at runtime.
- **HTTP goes through `Req`**, and `.reach.exs` enforces it. The old crawlers
  used `%{status_code: 200} = HTTPoison.get!(url)`, which turned a site hiccup
  into a supervisor crash loop. A non-200 is data; handle it.
- **Search reads the index, and asks the sources beside it.** The old
  `search_torrents/1` ran four scrapers inline on every keystroke and threw the
  results away. `Torrents.search_torrents/2` only ever reads the index;
  `Magnetissimo.SourceSearch` asks every source's own search in parallel,
  shares one search per term, caches answered terms, indexes the hits and
  broadcasts each answer so the page can slide them in.
- **Crawls run on a timer, not a job queue.** `Magnetissimo.Crawlers.Scheduler`
  runs each crawler every 5 minutes. That is enough because a crawl is
  stateless and idempotent: it reads a feed and upserts by infohash, so a
  missed or failed run loses nothing that the next one does not pick up, and
  every feed holds hours of uploads (in October 2026, Nyaa's about 7 hours,
  Sukebei's and TorrentDownloads' busiest category about 2). A job queue would buy persistence and retries a crawl does
  not need, and on SQLite its polling would compete with the crawlers and
  searches for the one writer. What the old app got wrong was crashing:
  a crawl never raises, it logs. Reach for Oban when work stops being
  idempotent, such as a multi-page backfill that must resume where it left
  off.
- **One theme, and it is dark.** Plain Tailwind with the tokens in
  `assets/css/app.css`; `docs/design.md` says what each one is for. There is
  no light mode and no component library — daisyUI was deliberately removed.
  Don't add one back.
- **Database tests are `async: false`.** SQLite has one writer; two sandboxed
  tests inserting at once fail with `Database busy`. Pure tests (formatting,
  components) stay async.
- **The FTS5 index is maintained by triggers, and the delete path is subtle.**
  The delete trigger must use FTS5's special `'delete'` command; a plain
  `INSERT` of the old values re-adds the tokens instead of removing them and
  silently corrupts the index. After changing anything about that table, check
  it with
  `insert into torrents_search(torrents_search) values('integrity-check')`.
- **Migrations must roll back.** `mix ecto.rollback --all` followed by
  `mix ecto.migrate` is part of verifying a data change. The FTS5 migration
  hand-writes `up`/`down` because `create virtual table` has no Ecto DSL.

## Tests

`test/support/data_case.ex` runs database tests in one SQL sandbox per test,
`test/support/conn_case.ex` runs tests through the router, and
`Magnetissimo.TorrentsFixtures` (`test/support/fixtures/`) seeds the taxonomy
and inserts a torrent with sensible defaults.

Tests cover the ground the checks cannot:

| Change | Where |
| --- | --- |
| Context and schema logic | `test/magnetissimo/torrents_test.exs` |
| The FTS5 index | `torrents_search` stays in sync on insert, update and delete, and `match_query/1` survives hostile input such as `ubuntu:24.04`, `x265-` and `*` (still to write) |
| Crawlers | one file per source, parsing saved fixtures, never the live site |
| LiveView UI | `test/magnetissimo_web/live/`, one file per LiveView |
| The JSON API | `test/magnetissimo_web/controllers/` |
| Formatting and components | `test/magnetissimo_web/format_test.exs`, `test/magnetissimo_web/components/` |

Rules:

- `async: true` for pure tests; `async: false` for anything that writes to the
  database, because SQLite has one writer.
- **Never make real network calls.** Stub `Req` with
  `req_options: [plug: {Req.Test, name}]`.
- Don't use `Process.sleep`; wait on messages or `:sys.get_state/1`.
- For LiveView, assert against DOM ids with `element/2` / `has_element?/2`.
  Test outcomes, not raw HTML or exact copy.
