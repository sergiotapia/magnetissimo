# Design

Corporate Y2K. An overexposed glass atrium at 9am: fluorescent strips on a
cyan ceiling, white light from a skylight, a blue-tiled floor, escalator
steel, and one navy suit walking through it. Frosted glass panels, glossy
azure gel buttons, chrome lettering, a pearl orb, sparkles. Cool, airy,
optimistic, a little sterile. The palette was sampled from a stock photo of
exactly that scene. The reference is the bottom row of
`moodboard/`: the PS2 posters, the silver and Bondi-blue plastics, the
speaker-ring decals. The top row (CRT dossiers) was the first direction and is
kept for the fingerprint and the pixel captions only.

## Palette

Defined as `@theme` tokens in `assets/css/app.css`. Light only.

| Token | Hex | Use |
|-------|-----|-----|
| `frost-50` … `frost-300` | `#F4FAFC` … `#B9D8E4` | page, wells, hairlines (skylight white to glass) |
| `ink-900` | `#0D2132` | primary text (the suit) |
| `ink-700` / `ink-500` | `#2A506C` / `#5A7F95` | secondary text, labels (shadow, steel) |
| `ink-300` | `#9BBCCB` | placeholders, ordinals, the hexdump |
| `azure-700` … `azure-100` | `#1D5A88` … `#DCF0F7` | the glass: gel buttons, links, bars (briefcase to floor tile) |
| `aqua` | `#8FD9EA` | the ceiling glow, the second stop of every gradient |
| `mint` / `mint-soft` | `#11A07C` / `#C6EFE2` | seeders, "online" |
| `bubble` / `bubble-soft` | `#E04A64` / `#FBD9DF` | leechers and errors, nothing else |

Azure is the page. Gradients go azure → aqua. Nothing is warm except
`bubble`, which is why it reads as a warning. The background is a cyan
ceiling fading to a pale middle and a blue floor, with a white skylight
bloom top right and `.ceiling` light strips across the top. Mint means alive, bubble means
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
  The layout puts the `.ceiling` strips and a few `<.sparkle>`s in it.
- `.ceiling` — fluorescent strips across the top of the page, fading out
  towards the middle and the walls. They show in the gutters between panels.
- `.panel` — frosted glass: translucent white, white rim, backdrop blur,
  24px radius, soft azure shadow. `.panel-hot` lifts it on hover.
- `.panel-title` — the glossy title bar: Jura uppercase over a split
  white-to-glass gradient, the Aqua toolbar.
- `.gel` — the Aqua lozenge: azure gradient with a white gloss on the top
  half. Primary buttons, the magnet link, the active chip.
- `.pill` — frosted secondary button and chip.
- `.well` — a recessed track: the search field, progress bars, the
  fingerprint frame.
- `.bar-fill` — glossy azure-to-aqua fill inside a `.well`.
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

- The **wordmark** is Azure Chrome, generated with `gpt-image-2` as Cobalt
  Chrome and hue-shifted to match the palette
  (`magick … -modulate 100,88,89` on the cobalt original in `d13c65e`). Stored as a cropped, transparent WebP at
  `priv/static/images/wordmark.webp`.
  It sits above the search input, scales to the available width up to 640px,
  and retains the accessible heading name "Magnetissimo" through its alt text.
- The **favicon** reuses the wordmark's azure-chrome M on an ice tile, with the same hue shift:
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
