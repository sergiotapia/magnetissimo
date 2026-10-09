// A Bayer-dithered, slowly turning sphere drawn on a tiny canvas and scaled up
// with image-rendering: pixelated, so it reads as 1-bit bitmap art on a CRT.
//
// Usage: <canvas id="orb" phx-hook="Dither" phx-update="ignore" data-seed="..."></canvas>
// The hook owns the element; LiveView never patches it.

const BAYER = [
  [0, 8, 2, 10],
  [12, 4, 14, 6],
  [3, 11, 1, 9],
  [15, 7, 13, 5],
]

const SIZE = 96
const FG = [153, 204, 255]
const FG_DIM = [102, 153, 255]

function seedFrom(text) {
  let h = 2166136261
  for (const ch of text || "magnetissimo") {
    h ^= ch.charCodeAt(0)
    h = Math.imul(h, 16777619) >>> 0
  }
  return h
}

export const Dither = {
  mounted() {
    const canvas = this.el
    canvas.width = SIZE
    canvas.height = SIZE
    const ctx = canvas.getContext("2d")
    const image = ctx.createImageData(SIZE, SIZE)
    const seed = seedFrom(canvas.dataset.seed)
    const tilt = ((seed % 1000) / 1000) * 0.8 - 0.4
    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    let t = (seed % 360) / 60
    let last = 0

    const frame = (now) => {
      if (now - last > 1000 / 24) {
        last = now
        this.draw(ctx, image, t, tilt)
        if (!reduced) t += 0.016
      }
      if (!reduced || !this.drawn) {
        this.drawn = true
        this.raf = requestAnimationFrame(frame)
      }
    }
    this.raf = requestAnimationFrame(frame)
  },

  destroyed() {
    cancelAnimationFrame(this.raf)
  },

  draw(ctx, image, t, tilt) {
    const data = image.data
    const half = SIZE / 2
    const radius = SIZE * 0.42
    // A light source orbiting the sphere.
    const lx = Math.cos(t) * 0.8
    const ly = -0.45 + Math.sin(t * 0.7) * 0.25
    const lz = Math.sin(t) * 0.6 + 0.5
    const ll = Math.hypot(lx, ly, lz)

    for (let y = 0; y < SIZE; y++) {
      for (let x = 0; x < SIZE; x++) {
        const i = (y * SIZE + x) * 4
        const dx = (x - half) / radius
        const dy = (y - half) / radius
        const d2 = dx * dx + dy * dy
        let v = 0
        let dim = false

        if (d2 <= 1) {
          const dz = Math.sqrt(1 - d2)
          // Diffuse lighting plus latitude bands, so the turn is visible.
          const diffuse = Math.max(0, (dx * lx + dy * ly + dz * lz) / ll)
          const lon = Math.atan2(dx, dz) + t * 1.4
          const lat = Math.asin(Math.max(-1, Math.min(1, dy * Math.cos(tilt) + dz * Math.sin(tilt))))
          const bands = 0.5 + 0.5 * Math.sin(lat * 9)
          const meridians = 0.5 + 0.5 * Math.sin(lon * 6)
          v = 0.12 + diffuse * 0.75 + bands * 0.08 + meridians * 0.05
          // Scan band sweeping down the sphere.
          const scan = ((t * 0.6) % 2.4) - 1.2
          if (Math.abs(dy - scan) < 0.05) v += 0.5
        } else {
          // A faint halo outside the limb.
          const ring = Math.abs(Math.sqrt(d2) - 1.12)
          if (ring < 0.03) { v = 0.35; dim = true }
          const ring2 = Math.abs(Math.sqrt(d2) - 1.0)
          if (ring2 < 0.02) { v = 0.6 }
        }

        const threshold = (BAYER[y & 3][x & 3] + 0.5) / 16
        const on = v > threshold
        const c = dim ? FG_DIM : FG
        data[i] = on ? c[0] : 0
        data[i + 1] = on ? c[1] : 0
        data[i + 2] = on ? c[2] : 0
        data[i + 3] = on ? 255 : 0
      }
    }

    ctx.putImageData(image, 0, 0)
  },
}
