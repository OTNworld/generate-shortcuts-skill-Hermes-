# v1.16.0 — Shortcuts Generator Skill (Hermes)

Mac-attested track (verify MATRIX before publish)

## Highlights

### Added
- GitHub Actions `release.yml` — on `v*` tag: validate + selftest + `gh release create` (linux notes)
- Release tooling: `references/RELEASE.md`, `scripts/cut_release.sh` (dry-run default; `--mode linux|mac`)
- `scripts/shortcut_icon.py` — lean glyph/color helper from `PLIST_FORMAT.md`
- Teaching golden `examples/10-rewrite-text` + Mackasten packages `clipboard-set`, `local-rewrite`
- Community MIT vendor `19-app-release-notes` (Viticci gap); WF SSOT **446**
- `results.json` `attest_baseline` honesty block (snapshot remains skill **1.10.0**)

### Changed
- Skill version 1.16.0
- Viticci gaps **9 → 8**; community **10 → 11**; Mackasten packages **2 → 4**

## Support matrix (honest)

| Surface | Status |
|---------|--------|
| Linux CI (`validate` / `selftest` / schemas / sources) | Supported |
| macOS sign → import → run | See Mac claim below |
| iOS | Best-effort / **not** systematically attested |
| Mackasten marketplace packages | **Paper MVP** (`mackasten/packages/`) — not an App Store product |
| AppIntents listed in `unverified` | SSOT only — **no** teaching `appintentexecution` goldens yet |

**Mac attestation:** intended for use after `MAC_10_CHECKLIST` is completed on device. Confirm `fixtures/attested/MATRIX.md` + `results.json` `skill_version` == **1.16.0** before publishing this claim. If MATRIX is still on an older skill version, use `--mode linux` instead.

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
cd shortcuts-generator && git checkout v1.16.0
```

## Agent map

See `references/AGENT_ENTRY.md`, `references/RELEASE.md`.
