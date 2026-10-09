# Design

The UI is a CRT. One phosphor blue on near-black glass, dossier panels with
corner ticks, pixel labels, dithered bitmap art. The reference images are in
`moodboard/`; this file is what was taken from them so the next page matches
without re-reading nine posters.

## Palette

Printed in the header of every page, the way the Blue Flax poster prints its
own hex codes in the margin. Defined as `@theme` tokens in `assets/css/app.css`.

| Token | Hex | Use |
|-------|-----|-----|
| `ink-950` | `#04050A` | page background |
| `ink-900` | `#080B16` | panel fill |
| `phos-900` / `phos-700` | `#1A2240` / `#2F3F7A` | grid lines, dim rules, placeholder text |
| `phos-500` | `#6699FF` | the phosphor: borders, labels, bars |
| `phos-300` | `#99CCFF` | bright phosphor: panel titles, corner ticks, links |
| `phos-100` | `#E4F0FF` | the brightest text, the title, values |
| `acid` | `#CCCC33` | the one accent: seeders, the active filter, the power LED |
| `rose` | `#FF6B9D` | leechers and errors, nothing else |

Blue is the whole page. Acid is for "alive" (seeders, lock, active). Rose is
for "draining" (leechers) and for something wrong. Never use either for
decoration.

## Type

Four faces, all OFL, served from `priv/static/fonts`:

- **Jura** (`font-display`, weight 300) — the page title and the tagline only.
  The thin geometric sans from the Blue Flax poster.
- **VT323** (`font-dossier`) — dossier labels and values, panel titles, the
  search prompt, nav. Always uppercase with `.dossier`. This is the voice of
  the SUBJECT A-34 card.
- **Silkscreen** (`font-pixel`) — the tiny caption layer (`.label`): the BIOS
  line, column headers, chips, the hex legend. Under 10px, tracked wide.
- **Space Mono** (`font-mono`, the body default) — torrent names, sizes,
  hashes, descriptions. The one face that has to stay readable at length.

## Primitives

All in `app.css`:

- `.panel` — the bordered box. Corner ticks are drawn with eight background
  gradients so no extra markup is needed. `.panel-hot` adds a hover glow.
- `.panel-title` — the title bar: VT323 uppercase, a left-to-right fade.
- `.dossier-row` — `label ...... value` with a dotted leader between.
- `.glow` / `.glow-lg` / `.glow-acid` / `.glow-rose` — phosphor bloom. These
  are `@utility`, so `hover:glow` works.
- `.cursor` — the blinking block after a status line.
- `.ticker` — a row that drifts left forever; render its content twice.
- `.crt-scanlines`, `.crt-vignette`, `.crt-sweep` — the glass, fixed over the
  page. `prefers-reduced-motion` turns the sweep and every animation off.

Components in `MagnetissimoWeb.DossierComponents`: the pixel magnet icon,
category chips, the swarm bar, stars, the fingerprint, the signal chart and a
hexdump. Formatting in `MagnetissimoWeb.Format`.

## Art

Nothing is an image file.

- The **fingerprint** on a torrent page is its infohash drawn as a mirrored
  12×12 bitmap, server-rendered SVG. 72 of the 160 bits, left half mirrored,
  so every hash has its own symmetrical glyph.
- The **orb** is the one JavaScript hook (`assets/js/dither.js`): a lit
  sphere, Bayer-dithered to 1-bit on a 96px canvas and scaled up with
  `image-rendering: pixelated`. It is seeded from the page's data so the home
  page and each torrent get a different turn and tilt.
- The **signal chart** is an SVG grid with two drifting sine paths, the
  chart under the SUBJECT card. Decoration, not data.

## Rules of thumb

- Labels in Silkscreen, values in VT323 or Space Mono. Never a label in Jura.
- Everything is square. No border radius except the three status dots.
- Borders are `phos-500` at 30% alpha; ticks and titles are `phos-300` at
  full. Hover brightens the border, never changes the fill.
- Dates are `YYYY.MM.DD HH:MM UTC` with a relative age beside them.
- The URL is the state. A search or a filter is a link.
