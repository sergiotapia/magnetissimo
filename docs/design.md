# Design

Soft-core Y2K. A lavender haze, frosted glass panels, glossy grape gel
buttons, chrome lettering, a pearl orb, sparkles. Gel pens, frosted lip
gloss, the Grape iMac: pastel, warm, a little sugary. The reference is the bottom row of
`moodboard/`: the PS2 posters, the silver and Bondi-blue plastics, the
speaker-ring decals. The top row (CRT dossiers) was the first direction and is
kept for the fingerprint and the pixel captions only.

## Palette

Defined as `@theme` tokens in `assets/css/app.css`. Light only.

| Token | Hex | Use |
|-------|-----|-----|
| `frost-50` … `frost-300` | `#FDF8FF` … `#E2CDEE` | page, wells, hairlines (lavender-white) |
| `ink-900` | `#2A1840` | primary text (grape) |
| `ink-700` / `ink-500` | `#4F3670` / `#86709F` | secondary text, labels |
| `ink-300` | `#C3B1D6` | placeholders, ordinals, the hexdump |
| `iris-700` … `iris-100` | `#5B3FD0` … `#EFE9FF` | the periwinkle-grape: gel buttons, links, bars |
| `blush` | `#FF9FD2` | bubblegum, the second stop of every gradient |
| `butter` | `#FFE48F` | a sparkle, the bottom bloom, a stop in the orb and the CD |
| `mint` / `mint-soft` | `#12B39A` / `#C8F3EA` | seeders, "online" |
| `bubble` / `bubble-soft` | `#F2468F` / `#FFD6EA` | leechers and errors, nothing else |

Iris is the page. Gradients go iris → blush. The page background is a
lavender base with bubblegum (top left), periwinkle (top right), a faint sky
blue and a butter bloom at the bottom. Mint means alive, bubble means
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
  24px radius, soft grape shadow. `.panel-hot` lifts it on hover.
- `.panel-title` — the glossy title bar: Jura uppercase over a split
  white-to-lavender gradient, the Aqua toolbar.
- `.gel` — the Aqua lozenge: periwinkle-to-grape gradient with a white gloss on the top
  half. Primary buttons, the magnet link, the active chip.
- `.pill` — frosted secondary button and chip.
- `.well` — a recessed track: the search field, progress bars, the
  fingerprint frame.
- `.bar-fill` — glossy iris-to-blush fill inside a `.well`.
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

- The **wordmark** is Grape Chrome, generated with `gpt-image-2` as Cobalt
  Chrome and hue-shifted to match the palette
  (`magick … -modulate 103,92,124`). Stored as a cropped, transparent WebP at
  `priv/static/images/wordmark.webp`.
  It sits above the search input, scales to the available width up to 640px,
  and retains the accessible heading name "Magnetissimo" through its alt text.
- The **favicon** reuses the wordmark's grape-chrome M on a lavender tile, with the same hue shift:
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
