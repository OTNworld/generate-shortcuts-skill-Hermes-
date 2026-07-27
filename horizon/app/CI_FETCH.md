# CI fetch — skill packages → Horizon app

## Decision

The private app repo **does not submodule** the whole skill. It **fetches** at a
pinned ref:

- `horizon/packages/*/package.json`
- every `shortcuts[].path` XML referenced by those manifests
- `data/schemas/horizon-package.v1.json` (for validation)

## Why fetch (not submodule)

| Approach | Pros | Cons |
|----------|------|------|
| Submodule full skill | Exact tree | Heavy ; pulls unrelated Hermes skill surface |
| **Fetch sparse / archive** | Lean Vendor tree ; pin clear | Need rewrite of paths |
| Copy-paste packages | Simple | Drift ; no CI pin |

## Pin format

```bash
# SkillPin.env (not necessarily secret — ref is public)
SKILL_REPO_URL=https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git
SKILL_REF=v1.16.0          # tag preferred ; SHA OK
```

Release builds **fail** if `SKILL_REF` is `main` or empty.

## Local / CI command

```bash
./scripts/fetch_skill_packages.sh
# outputs:
#   Vendor/SkillPackages/<id>/package.json
#   Vendor/SkillPackages/<id>/shortcuts/<file>.xml
#   Vendor/SkillPackages/catalog.json
#   Vendor/SkillPackages/schema/horizon-package.v1.json
```

Seed script (runs against sibling checkout or clones temp):  
[`scripts/fetch_skill_packages.sh`](scripts/fetch_skill_packages.sh)

## Path rewrite

Manifests in the skill use repo-relative paths like:

`templates/examples/01-hello-world.shortcut.xml`

After fetch, package.json shortcuts paths become vendor-relative:

`shortcuts/01-hello-world.shortcut.xml`

Keep original under `edit.skill_path` / `edit.deep_link` for the skill bridge.

## GitHub Actions sketch (app repo)

```yaml
name: fetch-and-validate-packages
on: [push, pull_request]
jobs:
  fetch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Fetch skill packages
        env:
          SKILL_REF: ${{ vars.SKILL_REF }}
        run: ./scripts/fetch_skill_packages.sh
      - name: Upload Vendor tree
        uses: actions/upload-artifact@v4
        with:
          name: skill-packages
          path: Vendor/SkillPackages
```

Mac build job downloads the artifact before `xcodebuild`.

## Failure modes

| Symptom | Fix |
|---------|-----|
| Clone fails | Check network / repo URL ; skill is public |
| Missing XML | Manifest path broken upstream — fail fetch |
| Schema fail | Bump pin or fix skill package |
| Empty catalog | Do not ship ; fail CI |

## In-app refresh (P2)

Same script semantics over HTTPS (Codeload zip of tag). Must still pin ; never
float to skill `main` for production catalog without explicit user action.
