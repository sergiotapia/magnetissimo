# Design

Soft Y2K. Pale icy sky, frosted glass panels, glossy gel buttons, chrome
lettering, a pearl orb, sparkles. The reference is the bottom row of
`moodboard/`: the PS2 posters, the silver and Bondi-blue plastics, the
speaker-ring decals. The top row (CRT dossiers) was the first direction and is
kept for the fingerprint and the pixel captions only.

## Palette

Defined as `@theme` tokens in `assets/css/app.css`. Light only.

| Token | Hex | Use |
|-------|-----|-----|
| `frost-50` … `frost-300` | `#F7FAFF` … `#C9D6EF` | page, wells, hairlines |
| `ink-900` | `#141C46` | primary text |
| `ink-700` / `ink-500` | `#34407A` / `#67739F` | secondary text, labels |
| `ink-300` | `#A3AED2` | placeholders, ordinals, the hexdump |
| `cobalt-700` … `cobalt-100` | `#1F3FD1` … `#E2EAFF` | the blue: gel buttons, links, bars |
| `lilac` | `#B49CFF` | the second stop of every gradient |
| `mint` / `mint-soft` | `#12B886` / `#C6F2E2` | seeders, "online" |
| `bubble` / `bubble-soft` | `#FF4F9A` / `#FFD6E8` | leechers and errors, nothing else |

Blue is the page. Gradients go cobalt → lilac. Mint means alive, bubble means
draining or wrong; never use either for decoration.

## Type

Four faces, all OFL, served from `priv/static/fonts`:

- **Jura** (`font-display`) — panel titles, nav and button labels.
  Uppercase and tracked wide.
- **Quicksand** (`font-sans`, the body default) — torrent names, copy, spec
  rows. Weight 500 by default, 600–700 for values.
- **Silkscreen** (`font-pixel`) — the tiny caption layer (`.label`): column
  headers, source names, panel-title asides. Under 10px, tracked wide.
- **Space Mono** (`font-mono`) — sizes, counts, ages, hashes. Anything that
  should line up.

## Primitives

All in `app.css`:

- `.sky` — fixed behind the page: speaker rings top right and bottom left.
  The layout puts a few `<.sparkle>`s in it.
- `.panel` — frosted glass: translucent white, white rim, backdrop blur,
  24px radius, soft cobalt shadow. `.panel-hot` lifts it on hover.
- `.panel-title` — the glossy title bar: Jura uppercase over a split
  white-to-ice gradient, the Aqua toolbar.
- `.gel` — the Aqua lozenge: cobalt gradient with a white gloss on the top
  half. Primary buttons, the magnet link, the active chip.
- `.pill` — frosted secondary button and chip.
- `.well` — a recessed track: the search field, progress bars, the
  fingerprint frame.
- `.bar-fill` — glossy cobalt-to-lilac fill inside a `.well`.
- `.spec-row` — `label ······ value` with a dotted leader.
- `.orb`, `.disc`, `.sparkle` — see Art.
- `.ticker` — a row that drifts left forever; render its content twice.
- `.focus-ring` — the keyboard focus outline.

`prefers-reduced-motion` stops every animation, including the orb and the CD.

Components in `MagnetissimoWeb.DossierComponents`: the magnet icon, sparkle,
category chips, the swarm bar, health sparkles, the fingerprint, the orb, the
disc, the wave chart and the hexdump. Formatting in `MagnetissimoWeb.Format`.

## Art

The wordmark is a local image; the remaining artwork is CSS or server-rendered
SVG. None of the artwork requires JavaScript.

- The **wordmark** is Cobalt Chrome, generated with `gpt-image-2` and stored
  as a cropped, transparent WebP at `priv/static/images/wordmark.webp`.
  It sits above the search input, scales to the available width up to 640px,
  and retains the accessible heading name "Magnetissimo" through its alt text.
- The **favicon** reuses the wordmark's cobalt-chrome M on an ice tile:
  `priv/static/images/favicon.png` at 64px, with 16/32/48px variants in
  `priv/static/favicon.ico` for the browser fallback.
- The **orb** is a pearl: a blurred conic gradient turning slowly under fixed
  radial highlights. Its starting angle and a small hue shift come from a
  seed (the counts on the home page, the infohash on a torrent page).
- The **fingerprint** is the infohash as a mirrored 12×12 grid of rounded
  beads, server-rendered SVG. 72 of the 160 bits, left half mirrored.
- The **disc** is a CD that spins beside the "now spinning" ticker.
- The **wave chart** is two soft sine paths drifting under a panel, like a
  stereo visualiser. Decoration, not data.
- **Sparkles** are a four-point star that twinkles; a few in the sky, one or
  two inside panels.

## Rules of thumb

- Everything is round: panels 24px, buttons and chips fully pill-shaped.
- One primary (`.gel`) action per area; everything else is a `.pill`.
- Labels in Silkscreen or tracked Jura, values in Quicksand or Space Mono.
- Dates are `YYYY.MM.DD HH:MM UTC` with a relative age beside them.
- The URL is the state. A search or a filter is a link.
