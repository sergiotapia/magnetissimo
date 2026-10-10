# Magnetissimo — agent guide

Magnetissimo is a self-hosted torrent indexer. When someone searches, it asks
eight torrent sites' own search at once, extracts the magnet links, indexes
them in SQLite, and serves them through a LiveView UI and a JSON API.
Phoenix 1.8, LiveView 1.2, Ecto on SQLite with FTS5, Req, Bandit, and
hand-written Tailwind 4.

It is a rewrite of the 2.0.0 app at `~/Work/magnetissimo-old` (Elixir 1.14,
Phoenix 1.7, Postgres). Read `legacy-project.md` in that repo before changing
behaviour. Use it to understand what the app was for, and don't copy its
code.

`README.md` is for users and `CONTRIBUTING.md` is for human contributors.
This file covers what you need to change the code without breaking it.

## Commands

```bash
mise install                 # Elixir 1.20.4 / OTP 29.1.1, from .mise.toml
mix setup                    # deps, db, migrations, sources + dev demo torrents, assets
iex -S mix phx.server        # localhost:4000, code reloader on
mix test test/path_test.exs  # one file; `mix test --failed` reruns failures
mix precommit                # must pass before committing Elixir changes
```

The developer usually has a dev server running on :4000 already. Check with
`curl -s -o /dev/null -w '%{http_code}' localhost:4000` before starting
another one. The code reloader picks up edits, so you don't need to restart
it.

## Map

| Path | What it is |
| --- | --- |
| `lib/magnetissimo/torrents.ex` | The context: list, count, `index_torrents/2`, `search_torrents/2`. |
| `lib/magnetissimo/torrents/search.ex` | Tokenizes free text, routes each token to an FTS5 index, ranks the results. |
| `lib/magnetissimo/taxonomy.ex` | The Torznab category list, in code. `category_id` is a Torznab number. |
| `lib/magnetissimo/source_search.ex` | A GenServer that asks every crawler at once, dedupes in-flight terms, caches answered terms for 15 minutes, gives up after 20s, and broadcasts on PubSub. |
| `lib/magnetissimo/crawlers.ex` | `all/0`, plus `search/2`, which runs one crawler and indexes its result. |
| `lib/magnetissimo/crawlers/crawler.ex` | The behaviour: `source_name/0`, `categories/0`, `search/1`. |
| `lib/magnetissimo/crawlers/http.ex` | The single `Req.get` every crawler makes. Doesn't retry. A non-200 response is an `{:error, _}`. |
| `lib/magnetissimo/crawlers/categories.ex` | `mapping!/3`: the site's category key mapped to a Torznab name, checked at compile time. |
| `lib/magnetissimo/crawlers/*.ex` | One module per site: Yts, Nyaa, Sukebei, TorrentDownloads, AudioBookBay, ThePirateBay, Eztv, OxTorrent. |
| `lib/magnetissimo/seeds.ex` | The `sources` rows. Every crawler has one. |
| `lib/magnetissimo/release.ex` | `migrate/0` for `bin/migrate`, and `migrator/3`, which migrates and then seeds on release boot. |
| `config/runtime.exs` | Production env: `DATABASE_PATH`, generated `SECRET_KEY_BASE`, optional `PHX_HOST`, `check_origin: :conn`. |
| `Dockerfile`, `compose.yaml`, `.github/workflows/docker.yml` | The image (debian-slim, runs as `nobody`, data in `/data`), the homelab compose file, and multi-arch publishing to `ghcr.io/sergiotapia/magnetissimo`. |
| `lib/magnetissimo_web/live/home_live.ex` | Search, category and source filters, sorting, paging, live source status. |
| `lib/magnetissimo_web/live/torrent_live.ex` | One torrent's detail page. |
| `lib/magnetissimo_web/controllers/torrent_*.ex` | `GET /api/latest` and `GET /api/search/:term`, keeping the 2.0.0 field names. |
| `lib/magnetissimo_web/components/dossier_components.ex` | Art and data components: orb, fingerprint, swarm bar, chips. |
| `lib/magnetissimo_web/format.ex` | Sizes in binary units, counts, ages, hashes. |
| `docs/design.md` | The design system. Read it before touching UI. |

Every module has a moduledoc that explains *why* it works the way it does.
Read the moduledoc before you edit a module, and update it when what it says
stops being true.

## Invariants

Breaking any of these causes bugs that tests may not catch:

- **Sources are asked only on a search.** Don't add timers, schedulers, job
  queues or "latest" crawls. Polling got the project blocked by Nyaa and
  AudioBookBay in October 2026.
- **Crawlers fetch and parse, and never write.** `Crawlers.search/2` passes
  their attrs to `Torrents.index_torrents/2`, which upserts by `magnet_hash`
  and records `search_hits` in a single transaction.
- **A crawler never raises on a bad site.** It returns `{:error, reason}`, and
  the UI shows that source as failed. Don't retry: retries make rate limits
  worse.
- **`magnet_hash` is identity.** It is 40 lowercase hex characters. A
  duplicate is normal. On conflict, only the seeders, leechers and
  `updated_at` refresh, and the category is replaced only if it was `Other`.
- **`magnet_url` is a complete `magnet:?xt=urn:btih:` URI.**
- **Categories are Torznab only.** Never invent one. Each crawler maps its
  site's most stable key with `Categories.mapping!/3` and a `:fallback`.
  Adult sources fall back to `XXX`. Every category a site publishes is
  listed in `test/magnetissimo/crawlers/categories_test.exs`.
- **Primary keys are integer ids.** The integer primary key is SQLite's
  rowid, which the `torrents_search` and `torrents_words` FTS5 tables join
  on. Never use `:binary_id`, UUIDs, nanoid, `ecto_identifier`, or
  `--binary-id`.
- **Never pass raw user text to FTS5 `MATCH`.** Go through
  `Torrents.search_torrents/2`, where `Torrents.Search` tokenizes the text
  and quotes each token.
- **FTS5 triggers delete with the `'delete'` command.** After touching that
  schema, run
  `insert into torrents_search(torrents_search) values('integrity-check')`.
- **Migrations roll back.** Verify with
  `mix ecto.rollback --all && mix ecto.migrate`. Create migration files with
  `mix ecto.gen.migration name_with_underscores`, and never hand-name them.
- **The URL is the page state.** `?q`, `?category`, `?sources` (slugs),
  `?sort`, `?dir` and `?page` are all read in `handle_params/3`. Every
  control is a link or a GET form, so the page works without JavaScript.
- **A release needs no setup.** It migrates and seeds on boot
  (`Release.migrator/3` via `Ecto.Migrator`), generates and keeps its own
  secret beside the database, and accepts any host. Don't add a required
  env var, `force_ssl`, or a fixed `check_origin`. Homelab installs run on
  plain `http://<lan-ip>:4000`. See "Releasing" in `CONTRIBUTING.md`.
- **JSON API field names are frozen** to the 2.0.0 shape, because Sonarr and
  Radarr setups depend on them.

## Architecture rules (enforced by `mix reach.check --arch`)

- The domain (`Magnetissimo.*`) never calls `MagnetissimoWeb.*`.
- Web code never calls `Repo` or `Ecto.Query`. It calls the context.
- All HTTP goes through Req, via `Crawlers.Http.get/2`. Never use HTTPoison,
  Tesla, `:httpc`, or raw Finch.
- Never use `System.cmd`, `System.shell` or `Port.open`.
- Never use `String.to_atom`/`List.to_atom` on input.
- Output goes through `Logger`. Never use `IO.puts` or `IO.inspect`.

## Adding a source

1. Find the cheapest endpoint that answers a search: a JSON API, a search
   RSS feed, or the XHR the site's own JS makes. Use HTML only as a last
   resort.
2. Write `lib/magnetissimo/crawlers/<site>.ex` with
   `@behaviour Magnetissimo.Crawlers.Crawler`. Fetch with
   `Http.get(url, opts ++ Application.get_env(:magnetissimo, __MODULE__, []))`
   so tests can inject a plug. If the site only gives an infohash, build
   magnets with `Crawlers.Magnet`. If a search needs one request per result,
   skip URLs already indexed (`Torrents.torrents_by_canonical_url/1`), cap the
   number fetched, and pace the requests the way `AudioBookBay` does.
3. Add it to `@crawlers` in `Magnetissimo.Crawlers` and to
   `Magnetissimo.Seeds`, and add `plug: {Req.Test, Module}` in
   `config/test.exs`.
4. Add fixtures in `test/support/fixtures/<site>_fixtures.ex`, a test at
   `test/magnetissimo/crawlers/<site>_test.exs`, and the site's categories
   in `categories_test.exs`.
5. Write the moduledoc: how the site is read, its quirks, and what you
   worked around.

## Tests

- Database tests use `Magnetissimo.DataCase, async: false`, because SQLite
  has one writer. Pure tests use `async: true`.
- Never make real network calls. Use `Req.Test.stub(Module, fn conn -> … end)`.
- `Magnetissimo.FastCrawler` and `SlowCrawler` (`test/support/crawlers/`)
  stand in for sources in `SourceSearch` and LiveView tests. Point
  `config :magnetissimo, Magnetissimo.SourceSearch, crawlers: […]` at them.
- Start processes with `start_supervised!/1`. Never use `Process.sleep/1`
  or `Process.alive?/1`. Use `Process.monitor/1` with
  `assert_receive {:DOWN, …}`, or `_ = :sys.get_state(pid)`.
- In LiveView tests, give key elements DOM ids and assert with `element/2`
  and `has_element?/2`. Don't assert on raw HTML or exact copy. To debug a
  selector, print a `LazyHTML.filter/2` of `render(view)`, never the whole
  page.

## Checks

`mix precommit` runs `compile --warnings-as-errors`, `deps.unlock --unused`,
`format`, `credo --strict` (with ExSlop), `ex_dna` (any clone at 85%
similarity fails), `reach.check --arch`, `dialyzer` (ignored return values
fail, so write `_ = call()`), and `test`.

Fix whatever a check finds. When a check is wrong for one specific line,
disable it on that line with a reason:
`# credo:disable-for-next-line Check.Name because …`. Config is in
`.credo.exs`, `.ex_dna.exs` and `.reach.exs`.

## Git

There is no remote yet, so the commit log is the only history.

- Commit each working step as soon as it works: a migration, a crawler, a
  passing test. Don't save everything for one big commit at the end.
- Never `--amend`, rebase, squash or force-push an existing commit. Fix
  mistakes in a follow-up commit.
- `git add -A` is fine.
- Run `mix precommit` first when the change touches Elixir. If it fails for
  an unrelated reason, commit anyway and say so in the body.
- Write an imperative subject under 72 characters that says what the change
  gets you (`Crawl OxTorrent, a page per release`). Add a body explaining
  *why* when the subject doesn't cover it, and say what 2.0.0 did if you
  replaced it.

## UI

- The design is light-only corporate Y2K: frosted glass panels, azure gel
  buttons, chrome. Tokens and primitives (`.panel`, `.gel`, `.pill`,
  `.well`, `.label`, …) are in `assets/css/app.css` and described in
  `docs/design.md`. Use them before inventing new ones.
- Use plain Tailwind 4 and no component library. daisyUI was removed on
  purpose. Never use `@apply`. Keep the
  `@import "tailwindcss" source(none)` / `@source` header in `app.css`
  as it is.
- Every artwork piece must render without JavaScript. Respect
  `prefers-reduced-motion`, which stops every animation.
- Only `app.js` and `app.css` are bundled. Never write inline
  `<script>`s. Use a colocated hook
  (`<script :type={Phoenix.LiveView.ColocatedHook} name=".Name">`) if JS is
  ever needed. A hook that owns its DOM needs `phx-update="ignore"` and an
  id.
- To screenshot the app, run headless Chromium with
  `--force-prefers-reduced-motion` wrapped in `timeout 40`. Without
  reduced motion the capture freezes mid-animation.

## Phoenix, LiveView and HEEx

These are the conventions this codebase follows and the mistakes that are
easy to make:

- LiveView templates start with `<Layouts.app flash={@flash}>`.
  `<.flash_group>` lives only in `layouts.ex`. There is no auth, and no
  `current_scope`.
- Use `<.icon name="hero-…">` for icons and `<.input>` for form fields. If
  you pass a `class` to `<.input>`, it replaces all the default classes.
- Build forms with `to_form/2` assigned in the LiveView and
  `<.form for={@form} id="…">`, and access fields as `@form[:field]`. Never
  pass a changeset to a template, and never use `<.form let={f}>`.
- Use `<.link navigate>`/`<.link patch>` and `push_navigate`/`push_patch`.
  Never use `live_redirect`/`live_patch`.
- In HEEx, use `{…}` for interpolation in attributes and values, and
  `<%= … %>` for block constructs in bodies. Class lists use `[...]` with
  `if(…, do: …, else: …)` in parens. Comments are `<%!-- --%>`. Literal
  braces need `phx-no-curly-interpolation`. Build lists with `:for` or
  `<%= for %>`, never `Enum.each`.
- Use streams for collections, as `HomeLive` does for its results
  (`phx-update="stream"`, an id on the parent and on each child). Streams
  can't be counted or filtered, so keep a separate count assign and
  re-stream with `reset: true`. To redraw a streamed row after an assign
  changes, re-insert that row.
- LiveViews are named `…Live`, and routes inside
  `scope "/", MagnetissimoWeb` don't need an alias.

## Elixir and Ecto

- Lists have no index access. Use `Enum.at/2` or pattern matching.
- Bind the result of `if`/`case`/`cond`. A rebinding inside the block is
  lost. There is no `else if`, so use `cond`.
- Structs don't implement Access. Use `struct.field` or
  `Ecto.Changeset.get_field/2`.
- Name predicates `thing?`. `is_thing` is reserved for guards.
- Keep one module per file.
- Use `Task.async_stream/3` (usually `timeout: :infinity`) for bounded
  concurrency, and `Task.Supervisor.async_nolink` when one failure mustn't
  take down the caller, as `SourceSearch` does.
- Ecto fields are `:string` even for text columns. `validate_number` has no
  `:allow_nil`. Read changeset fields with `get_field/2`. Preload
  associations that templates read. The context already preloads `:source`.
  Nothing a reader submits is written to the database. If you ever add a
  form that writes, don't `cast` fields the server sets.
- For date and time use the standard library (`DateTime`, `Calendar`). Add
  no dependency without asking.
