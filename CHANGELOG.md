# Changelog

All notable changes to this skill are documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows the `version` field in `SKILL.md`.

## [Unreleased]

### Added
- Local Mac finalize pack: `LOCAL_FINALIZE.md`, `scripts/attest_local.sh`, `fixtures/attested/MATRIX.md`

## [1.8.0] - 2026-07-26

### Added
- Strict grammar gate: UTF-16 range checks, menu title balance (`check_shortcut_grammar.py --strict`)
- Starter palette: 12 XML under `templates/palette/` + `references/STARTER_PALETTE.md`
- Community goldens: Invert Names, Days In a Month, Electricity Price
- `scripts/extract_shortcut.sh` (plutil/plistlib) + iCloud extract notes
- `scripts/render_refs.py` (+ `--check` in CI) to regenerate catalog fences from SSOT
- `fixtures/attested/MAC_HANDOFF.md` checklist for later Mac attestation

### Changed
- Skill version 1.8.0

## [1.7.0] - 2026-07-26

### Added
- Ecosystem hub: `data/sources.json`, `references/ECOSYSTEM.md`, `THIRD_PARTY_NOTICES.md`
- Viticci playground golden index: `data/external/viticci-playground-goldens.index.jsonl`
- Community MIT goldens: URL Cleaner, Parse JSON Feed under `templates/examples/community/`
- `references/URL_SCHEMES.md` (Apple-documented schemes + x-callback)

### Changed
- Icon color table aligned with sebj iOS-Shortcuts-Reference (RGBA-8)
- Skill version 1.7.0

## [1.6.0] - 2026-07-26

### Added
- SSOT catalogs: `data/wf_actions.json`, `data/appintents.json` with CI count asserts
- Importable goldens `templates/examples/01`–`08` (hello, ask, askllm, menu, weather, conditional, repeats)
- `references/FAILURE_MODES.md`, `PLATFORM_MATRIX.md`, `POWER_ACTIONS.md`, `OBSIDIAN_BRIDGE.md`
- `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`
- `fixtures/attested/` scaffold for macOS/iOS import attestation (10/10 prep)
- `scripts/check_shortcut_grammar.py` deeper grammar checker scaffold (10/10 prep)
- `references/ROADMAP_10.md` checklist for the 10/10 milestone

### Changed
- `references/APPINTENTS.md` rebuilt from SSOT (single authoritative list)
- `references/EXAMPLES.md` now indexes goldens instead of embedding XML
- `SKILL.md` focused on Shortcuts protocol; Obsidian moved to bridge doc
- Icon color samples corrected in `PLIST_FORMAT.md`
- Skill version bumped to 1.6.0

### Fixed
- Weather example invalid UUID (`GGGG…`) and attachment range
- Hello World description mismatched Ask/GetText vs actual GetText → Show Result

## [1.5.0] - 2026-07-26

### Added
- MIT `LICENSE`, `scripts/validate.sh`, GitHub Actions validate workflow
- `templates/hello-world.shortcut.xml` golden
- Language policy in README

### Changed
- AppIntents claim corrected to curated subset
- Locally template renamed to `locally-obsidian.stub.xml` (non-importable)
- Hardened `scripts/sign_shortcut.sh`
- Skeleton includes `WFWorkflowClientRelease`
