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

## iOS app blueprint (`app/`) — oneshot seed

Private app repo target: **`OTNworld/mackasten-iOS`** (you create it; agent cannot).  
Former codename: `mackasten-iOS` — use that slug if the private repo already exists.  
Link mode: **fetch CI** of packages + XML from this skill @ pinned tag/SHA.

| Entry | Role |
|-------|------|
| [`app/README.md`](app/README.md) | Map + decisions |
| [`app/SKILL.md`](app/SKILL.md) | Agent skill to oneshot the app |
| [`app/VISION.md`](app/VISION.md) | Final product vision |
| [`app/ONESHOT_PLAN.md`](app/ONESHOT_PLAN.md) | Phased build plan |
| [`app/CHECKLIST.md`](app/CHECKLIST.md) | Creation + full tests |
| [`app/REPO_BOOTSTRAP.md`](app/REPO_BOOTSTRAP.md) | Create private repo + seed push |
| [`app/CI_FETCH.md`](app/CI_FETCH.md) | Fetch contract |
| [`app/scripts/fetch_skill_packages.sh`](app/scripts/fetch_skill_packages.sh) | Materialize `Vendor/SkillPackages/` |

Smoke fetch inside this skill tree:

```bash
./mackasten/app/scripts/fetch_skill_packages.sh
python3 mackasten/app/scripts/check_oneshot_ready.py
```
