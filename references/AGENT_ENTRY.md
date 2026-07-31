# Agent entry (≤2 minutes)

Single map for Hermes / Cursor agents. Details live in linked docs — start here.

| Intent | Do this | DoD |
|--------|---------|-----|
| **build** | Follow `SKILL.md` steps 1–9; compose from `templates/palette/` + `templates/examples/` | XML valid; UUIDs uppercase; control-flow complete |
| **remix** | `references/REMIX.md` + `python3 scripts/remix_shortcut.py` | Minimal diff; then validate_on_write |
| **validate** | `./scripts/validate_on_write.sh <file>` (optionally `--fix`) | Exit 0 |
| **selftest** | `./scripts/selftest.sh` | Exit 0 (Linux CI contract) |
| **attest** | Mac only: `./scripts/attest_local.sh --auto` | `results.json` + MATRIX — **not** Cloud Linux |
| **Horizon** | `references/HORIZON.md` | Product direction only; no Locally golden |

## Mandatory after every plist Write/Edit

```bash
./scripts/validate_on_write.sh path/to/file.shortcut.xml
# mechanical safe fixes:
./scripts/validate_on_write.sh --fix path/to/file.shortcut.xml
```

## Script index (DoD)

| Script | When | DoD |
|--------|------|-----|
| `validate.sh` | Before PR / release | All SSOT + XML + grammar + secrets + schemas green |
| `validate_on_write.sh` | After each golden edit | Single-file grammar + SSOT IDs |
| `selftest.sh` | Local + CI | validate + unittest + craig + remix |
| `remix_shortcut.py` | Surgical / structural edit | Writes plist; always re-validate |
| `craig_loop_lite.py` | Via `--fix` | UUID case, mode int, legacy IDs only |
| `check_json_schema.py` | Catalogs / results | Shape matches `data/schemas/*` |
| `check_no_secrets.py` | CI gate | No token-like strings in templates/fixtures |
| `shortcut_icon.py` | Icon glyph/tint | Prints integers / XML from PLIST_FORMAT table |
| `cut_release.sh` | GitHub tag/release | **Dry-run default**; `--apply` on `main` only |
| `check_sources.py` | Ecosystem registry | `sources.json` + vendored paths + Viticci gaps |
| `refresh_external_indexes.sh` | Refresh Viticci index | Rewrites index + `viticci-gaps.jsonl` |
| `check_horizon_packages.py` | Marketplace manifests | Each `horizon/packages/*/package.json` valid |
| `attest_local.sh` | **Darwin only** | Sign/import/run + results.json |
| `render_refs.py` | After catalog ID changes | Docs fences match SSOT (`--check` in CI) |

## Tracks

| Track | Checklist | Status |
|-------|-----------|--------|
| Linux 10/10 | [`LINUX_10_CHECKLIST.md`](LINUX_10_CHECKLIST.md) | **Done (1.12.0)** |
| Horizon paper MVP | [`HORIZON_CHECKLIST.md`](HORIZON_CHECKLIST.md) | **Done (1.13.0)** |
| Horizon agent (MCP / market) | [`HORIZON_AGENT_CHECKLIST.md`](HORIZON_AGENT_CHECKLIST.md) | H0–H3 stub / blurbs |
| Mac attestation 10/10 | [`MAC_10_CHECKLIST.md`](MAC_10_CHECKLIST.md) | **Open — needs Darwin** |
| Release / publish | [`RELEASE.md`](RELEASE.md) | Tooling ready (`cut_release.sh`) |
| Lean peer parity | [`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md) | MVP done |
| Product app runtime | [`HORIZON.md`](HORIZON.md) | Out of band |

## Language

| Surface | Lang |
|---------|------|
| `SKILL.md` | FR |
| `SKILL.en.md` + `references/*` | EN (checklists may be FR) |

**Anti-goals:** invent AppIntent IDs as `verified`; attest from Linux; revive Locally stub; vendor Viticci tree / GPL.
