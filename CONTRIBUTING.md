# Contributing

Thanks for improving this Hermes Shortcuts skill.

## Principles

1. **SSOT first** — action / AppIntent IDs live in `data/*.json`. Docs and claims must match.
2. **Importable vs stub** — only commit XML under `templates/` as importable goldens if `./scripts/validate.sh` grammar checks pass. Use `*.stub.xml` for incomplete design snapshots.
3. **No invented parameters** — prefer `POWER_ACTIONS.md` or an export-diff from Shortcuts.app.
4. **Keep SKILL.md focused** — Shortcuts protocol in FR; optional Obsidian notes in `references/OBSIDIAN_BRIDGE.md`.

## Workflow

```bash
# 1. Edit data and/or templates
# 2. If catalogs change, regenerate / sync references lists
./scripts/validate.sh

# 3. Update CHANGELOG.md under [Unreleased] or the next version
# 4. Bump SKILL.md version when releasing
```

## Adding a golden

1. Place XML in `templates/examples/NN-name.shortcut.xml`
2. Use uppercase hex UUIDs, proper control-flow, and `￼` + `attachmentsByRange`
3. Link it from `references/EXAMPLES.md`
4. Run `./scripts/validate.sh`

## Adding catalog IDs

1. Update `data/wf_actions.json` or `data/appintents.json` (`count` + `identifiers`)
2. Sync the complete list fence in `references/ACTIONS.md` or `APPINTENTS.md`
3. Ensure README/SKILL numeric claims still match (validator enforces this)

## Attested fixtures (10/10 track)

Document macOS/iOS sign+import results under `fixtures/attested/` — see that folder’s README.
Do not commit signed binaries that contain personal data.
