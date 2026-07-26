# OutputName reference (English)

Shortcuts variable chips use **English** `OutputName` strings even when the UI is localized.
Wrong names break wiring silently.

## Common producer names

| Action family | Typical `OutputName` |
|---------------|----------------------|
| `gettext` | `Text` |
| `ask` | `Provided Input` |
| `askllm` | `Response` |
| `list` | `List` |
| `dictionary` | `Dictionary` |
| `getvalueforkey` | `Dictionary Value` |
| `url` / `downloadurl` | `URL` / `Contents of URL` |
| `number` / `count` | `Number` / `Count` |
| `repeat.count` end | `Repeat Index`, `Repeat Results` |
| `repeat.each` | `Repeat Item`, `Repeat Results` |
| `choosefromlist` | `Chosen Item` / `Selected Item` |
| Share Sheet / extension | `Shortcut Input` (`Type` often `ExtensionInput`) |
| `weather.currentconditions` | `Weather Conditions` |
| `setvariable` / `getvariable` | (use `VariableName` attachments) |

## Rules

1. Match the name Shortcuts shows in English when you create the action in-app.
2. Prefer export-diff from Shortcuts.app over guessing.
3. Grammar checker allowlist: `scripts/check_shortcut_grammar.py` (`KNOWN_OUTPUT_NAMES`).
4. When adding a new frequent name, update that allowlist + this table.

See also `VARIABLES.md`, `FAILURE_MODES.md`.
