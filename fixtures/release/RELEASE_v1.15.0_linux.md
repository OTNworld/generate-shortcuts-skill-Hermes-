# v1.15.0 — Shortcuts Generator Skill (Hermes)

Linux-complete (Mac attest pending for post-1.10 deltas)

## Highlights

### Added
- Selective Viticci gap vendors (MIT):
  - `community/17-create-calendar-event-from-template.shortcut.xml`
  - `community/18-select-folder-compress-share.shortcut.xml`
- SSOT WF actions **438 → 442** (`file.getfoldercontents`, `file.select`, `makezip`, `properties.files`)

### Changed
- Skill version 1.15.0
- Viticci gaps **11 → 9**; community goldens **8 → 10**
- Intentionally skipped heavy/API gaps (Evernote, Toggl, Dropbox, App Store, WordleBot, Clip to iCloud Clipboard)

## Support matrix (honest)

| Surface | Status |
|---------|--------|
| Linux CI (`validate` / `selftest` / schemas / sources) | Supported |
| macOS sign → import → run | See Mac claim below |
| iOS | Best-effort / **not** systematically attested |
| Horizon marketplace packages | **Paper MVP** (`horizon/packages/`) — not an App Store product |
| AppIntents listed in `unverified` | SSOT only — **no** teaching `appintentexecution` goldens yet |

**Mac attestation:** baseline remains **v1.10.0** MATRIX. Deltas in 1.11.0–1.15.0 (palette 13–16, community 17–18, AppIntents `unverified`, Horizon packages) are **CI/Linux-validated**; device re-attest is tracked in `references/MAC_10_CHECKLIST.md`.

## Security / license

- Skill license: **MIT** (this repository).
- Upstream lineage `drewocarr/generate-shortcuts-skill`: license **unspecified** — link only (see `THIRD_PARTY_NOTICES.md`).
- Community goldens from Viticci playground: **MIT**, attributed.
- Do not distribute `*_signed.shortcut` binaries from attestation runs.

## Install (Hermes)

```bash
mkdir -p ~/.hermes/skills
cd ~/.hermes/skills
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git shortcuts-generator
cd shortcuts-generator && git checkout v1.15.0
```

## Agent map

See `references/AGENT_ENTRY.md`, `references/RELEASE.md`.
