# v1.15.0 — Shortcuts Generator Skill (Hermes)

Mac-attested track (verify MATRIX before publish)

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

**Mac attestation:** intended for use after `MAC_10_CHECKLIST` is completed on device. Confirm `fixtures/attested/MATRIX.md` + `results.json` `skill_version` == **1.15.0** before publishing this claim. If MATRIX is still on an older skill version, use `--mode linux` instead.

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
