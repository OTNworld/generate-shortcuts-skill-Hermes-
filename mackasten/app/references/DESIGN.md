# Design direction — Mackasten

Mackasten is a **companion marketplace**, not a generic AI dashboard.

## First viewport

One composition:

- Brand wordmark **Mackasten** (hero-level)
- One headline (marketplace promise)
- One short supporting sentence
- One CTA (Browse catalog)
- One full-bleed atmospheric visual (Shortcuts / on-device craft — not purple glow cliché)

No stat strips, no card grid in the hero, no floating badges on the hero image.

## Visual system

Define CSS/SwiftUI tokens early in the app repo:

- Background: layered gradient or subtle texture (not flat gray, not cream+terracotta cliché)
- Typography: expressive display + readable sans (avoid Inter/Roboto/system-only default pairing)
- Accent: single decisive hue (not purple-on-white default)

## Motion (ship 2–3)

1. Catalog row appear (staggered fade/slide)
2. Detail policy badge subtle settle
3. Install success check haptic + short confirmation

## Sections

| Section | One job |
|---------|---------|
| Hero / Home | Brand + enter catalog |
| Catalog | Browse packages |
| Detail | Understand + install/run |
| Library | Re-run installed |
| Settings | Pin skill ref, capabilities |

## Exception

If Apple HIG / Liquid Glass chrome conflicts with a rule, prefer system chrome for
navigation; keep content surfaces uncluttered.
