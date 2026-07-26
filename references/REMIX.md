# Remix protocol (lean)

Surgical **and structural** edits to an **existing unsigned** Shortcuts XML — Hermes
equivalent of Viticci `/shortcuts-playground:remix`, without absorbing their agent tree.

## When to remix

- User asks to change / fix / extend an existing `.shortcut.xml`
- Do **not** regenerate the whole file if a local edit suffices

## Agent steps

1. Read the source XML (golden or user file).
2. Plan the minimal change (which actions / UUIDs / text).
3. Prefer `scripts/remix_shortcut.py` for mechanical text/param/structure ops.
4. For complex control-flow (If/Repeat/Menu), edit carefully then validate.
5. **Mandatory:** `./scripts/validate_on_write.sh <file>`
6. On Mac: sign → optional `import_shortcut_ui` → `shortcuts run` if behavior changed.
7. Summarize: actions touched, UUIDs kept/added, validation result.

## Tool

```bash
# Inspect
python3 scripts/remix_shortcut.py templates/examples/01-hello-world.shortcut.xml \
  --list-actions

# Text swap (dry-run)
python3 scripts/remix_shortcut.py --dry-run \
  templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!"

# Structural: insert delay after gettext, rename
python3 scripts/remix_shortcut.py \
  templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!" \
  --insert-action 1 '{"identifier":"delay","parameters":{"WFDelayTime":1}}' \
  --set-name "Hello Remix" \
  --output /tmp/hello-remix.shortcut.xml

./scripts/validate_on_write.sh /tmp/hello-remix.shortcut.xml
```

### Supported operations

| Flag | Effect |
|------|--------|
| `--list-actions` | Print `index`, identifier, UUID (no write) |
| `--replace-text OLD NEW` | Replace exact string in plist string values (repeatable) |
| `--set-name NAME` | Set `WFWorkflowName` |
| `--set-param INDEX KEY VALUE` | Set parameter (VALUE: JSON or string/bool/int) |
| `--insert-action INDEX JSON` | Insert action at INDEX (`identifier`+`parameters` or full dict) |
| `--remove-action INDEX` | Remove action (repeatable; high→low) |
| `--move-action FROM TO` | Reorder actions |
| `--dry-run` | Print plan; no write |
| `--output PATH` | Write to PATH instead of in-place |

Insert JSON shorthand:

```json
{"identifier": "delay", "parameters": {"WFDelayTime": 1}, "with_uuid": true}
```

### Hard rules

- Keep UUIDs stable unless adding new producer actions (`with_uuid` / explicit UUID)
- Never turn `WFControlFlowMode` into a string
- Preserve U+FFFC + `attachmentsByRange` pairs
- Do not invent action parameters — export-diff from Shortcuts.app if unsure
- Re-run grammar `--strict` after every remix
- After `--remove-action`, fix dangling OutputUUID references manually if needed

## Failure modes

See `FAILURE_MODES.md`. Remix-specific:

| Symptom | Fix |
|---------|-----|
| Broken greeting / missing variable | Replaced a string that included `￼` or broke range keys |
| Validate red after remix | Restore from git; smaller ops; Craig Loop lite for UUID/mode |
| Sign OK but wrong runtime text | Confirm you edited `WFTextActionText` / `Text`, not only `WFWorkflowName` |
| Dangling OutputUUID | Removed a producer; restore or retarget attachments |

## Example scenarios

1. **Hello → Bonjour** — `01-hello-world` text swap (fixture below).
2. **Rename only** — `--set-name "My Hello"` without touching actions.
3. **Insert delay** — `--insert-action 1 '{"identifier":"delay","parameters":{"WFDelayTime":1}}'`.
4. **Reorder** — `--move-action 1 0` then validate.

Fixtures: `fixtures/remix/`.
