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
| `attest_local.sh` | **Darwin only** | Sign/import/run + results.json |
| `render_refs.py` | After catalog ID changes | Docs fences match SSOT (`--check` in CI) |

## Tracks

| Track | Checklist |
|-------|-----------|
| Linux 10/10 (this machine) | [`LINUX_10_CHECKLIST.md`](LINUX_10_CHECKLIST.md) |
| Mac attestation 10/10 | [`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md) |
| Product app / marketplace | [`HORIZON.md`](HORIZON.md) |
| Lean peer parity | [`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md) |

## Language

| Surface | Lang |
|---------|------|
| `SKILL.md` | FR |
| `SKILL.en.md` + `references/*` | EN (checklists may be FR) |

**Anti-goals:** invent AppIntent IDs as `verified`; attest from Linux; revive Locally stub; vendor Viticci tree / GPL.
