# Mackasten packages (paper MVP) + iOS app blueprint

## Packages (this skill — Linux CI)

Marketplace **package manifests** for the future companion app.
Validated on Linux CI — this skill does **not** ship an app binary.

| Package | Model policy | Primary shortcut |
|---------|--------------|------------------|
| [`hello-world`](packages/hello-world/) | `none` | `templates/examples/01-hello-world.shortcut.xml` |
| [`clipboard-set`](packages/clipboard-set/) | `none` | `templates/palette/03-setclipboard.shortcut.xml` |
| [`local-ask-llm`](packages/local-ask-llm/) | `apple-intelligence` | `templates/examples/03-ask-llm.shortcut.xml` |
| [`local-rewrite`](packages/local-rewrite/) | `apple-intelligence` | `templates/examples/10-rewrite-text.shortcut.xml` |

## Format

- Schema: [`data/schemas/mackasten-package.v1.json`](../data/schemas/mackasten-package.v1.json)
- Checker: `python3 scripts/check_mackasten_packages.py`
- Checklist: [`references/MACKASTEN_CHECKLIST.md`](../references/MACKASTEN_CHECKLIST.md)
- Vision: [`references/MACKASTEN.md`](../references/MACKASTEN.md)

## Rules

1. `shortcuts[].path` must exist and pass grammar when under `templates/`.
2. Do not reference AppIntents listed in `data/appintents.json` → `unverified`.
3. `model_policy` for `local-*` packages must not be `cloud-allowed` unless explicitly justified.
4. Attestation `status` must not claim `mac-run` unless MATRIX says so.

## Deep link (convention only)

`hermes-shortcuts://edit?path=<repo-relative-xml>`

Resolved by the companion app — not registered by this skill repo.

---

## iOS app blueprint (`app/`) — oneshot seed + Swift scaffold

Private app repo target: **`OTNworld/Mackasten`** (slug without `-iOS`).  
Link mode: **fetch CI** of packages + XML from this skill @ pinned tag/SHA.

Includes XcodeGen `project.yml`, SwiftUI catalog/library, deep link, App Intents,
Shortcuts bridge, and Linux-mirrored logic tests.

| Entry | Role |
|-------|------|
| [`app/README.md`](app/README.md) | Map + Mac/Linux commands |
| [`app/SKILL.md`](app/SKILL.md) | Agent skill |
| [`app/project.yml`](app/project.yml) | XcodeGen |
| [`app/Mackasten/`](app/Mackasten/) | App sources |
| [`app/ONESHOT_PLAN.md`](app/ONESHOT_PLAN.md) | Phased plan (A–E seeded) |
| [`app/REPO_BOOTSTRAP.md`](app/REPO_BOOTSTRAP.md) | Create private repo + seed |

```bash
./mackasten/app/scripts/fetch_skill_packages.sh
python3 mackasten/app/scripts/check_oneshot_ready.py
python3 -m unittest tests.test_mackasten_app_logic -v
```
