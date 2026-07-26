# Remix protocol (lean)

Surgical edits to an **existing unsigned** Shortcuts XML — Hermes equivalent of Viticci
`/shortcuts-playground:remix`, without absorbing their agent tree.

## When to remix

- User asks to change / fix / extend an existing `.shortcut.xml`
- Do **not** regenerate the whole file if a local edit suffices

## Agent steps

1. Read the source XML (golden or user file).
2. Plan the minimal change (which actions / UUIDs / text).
3. Prefer `scripts/remix_shortcut.py` for mechanical text/param swaps.
4. For structural edits (add If/Repeat/action), edit carefully then validate.
5. **Mandatory:** `./scripts/validate_on_write.sh <file>`
6. On Mac: sign → optional `import_shortcut_ui` → `shortcuts run` if behavior changed.
7. Summarize: actions touched, UUIDs kept/added, validation result.

## Tool

```bash
# Dry-run
python3 scripts/remix_shortcut.py --dry-run \
  templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!"

# Write in place (or --output path)
python3 scripts/remix_shortcut.py \
  templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!" \
  --output /tmp/hello-bonjour.shortcut.xml

./scripts/validate_on_write.sh /tmp/hello-bonjour.shortcut.xml
```

### Supported operations (MVP)

| Flag | Effect |
|------|--------|
| `--replace-text OLD NEW` | Replace exact string in plist `<string>` values (repeatable) |
| `--set-name NAME` | Set `WFWorkflowName` |
| `--dry-run` | Print planned replacements; no write |
| `--output PATH` | Write to PATH instead of in-place |

### Hard rules

- Keep UUIDs stable unless adding new producer actions
- Never turn `WFControlFlowMode` into a string
- Preserve U+FFFC + `attachmentsByRange` pairs
- Do not invent action parameters — export-diff from Shortcuts.app if unsure
- Re-run grammar `--strict` after every remix

## Failure modes

See `FAILURE_MODES.md`. Remix-specific:

| Symptom | Fix |
|---------|-----|
| Broken greeting / missing variable | Replaced a string that included `￼` or broke range keys |
| Validate red after remix | Restore from git; smaller `--replace-text` |
| Sign OK but wrong runtime text | Confirm you edited `WFTextActionText` / `Text`, not only `WFWorkflowName` |

## Example scenarios

1. **Hello → Bonjour** — `01-hello-world` text swap (fixture below).
2. **Rename only** — `--set-name "My Hello"` without touching actions.
