# Horizon packages (paper MVP)

Marketplace **package manifests** for the future companion app.
This directory is validated on Linux CI — it does **not** ship an app binary.

| Package | Model policy | Primary shortcut |
|---------|--------------|------------------|
| [`hello-world`](packages/hello-world/) | `none` | `templates/examples/01-hello-world.shortcut.xml` |
| [`clipboard-set`](packages/clipboard-set/) | `none` | `templates/palette/03-setclipboard.shortcut.xml` |
| [`local-ask-llm`](packages/local-ask-llm/) | `apple-intelligence` | `templates/examples/03-ask-llm.shortcut.xml` |
| [`local-rewrite`](packages/local-rewrite/) | `apple-intelligence` | `templates/examples/10-rewrite-text.shortcut.xml` |

## Format

- Schema: [`data/schemas/horizon-package.v1.json`](../data/schemas/horizon-package.v1.json)
- Checker: `python3 scripts/check_horizon_packages.py`
- Checklist: [`references/HORIZON_CHECKLIST.md`](../references/HORIZON_CHECKLIST.md)
- Vision: [`references/HORIZON.md`](../references/HORIZON.md)

## Rules

1. `shortcuts[].path` must exist and pass grammar when under `templates/`.
2. Do not reference AppIntents listed in `data/appintents.json` → `unverified`.
3. `model_policy` for `local-*` packages must not be `cloud-allowed` unless explicitly justified.
4. Attestation `status` must not claim `mac-run` unless MATRIX says so.

## Deep link (convention only)

`hermes-shortcuts://edit?path=<repo-relative-xml>`

Resolved by the future app / Cursor skill — not registered by this repo.
