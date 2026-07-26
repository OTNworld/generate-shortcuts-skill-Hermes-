# Failure Modes (Agent Playbook)

Common ways generated Shortcuts fail — and how to fix them before signing.

## Import / parse failures

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| File won’t open / invalid shortcut | Malformed XML or non-plist root | `xmllint --noout file.shortcut` then `./scripts/validate.sh` |
| Unknown action | ID not on this OS / typo | Check `data/wf_actions.json` + `PLATFORM_MATRIX.md` |
| Missing End Menu / If / Repeat | Control-flow block incomplete | Every start (`WFControlFlowMode` 0) needs end (2); menus need a case (1) per item |
| Menu does nothing | Missing `GroupingIdentifier` or modes as strings | Same UUID for start/cases/end; modes as `<integer>` |
| Variable shows as blank / literal `￼` | U+FFFC without `attachmentsByRange` | Pair every `￼` with a range key `{pos, len}` |
| Wrong substitution | Bad range or wrong `OutputUUID` | Count UTF-16-ish positions from start of the string; UUID must match producer |
| Wrong field wired | Incorrect `OutputName` | Use English OutputNames from Shortcuts (`Text`, `Provided Input`, `Response`, `List`, …) |
| Lowercase UUID rejected / rewritten oddly | UUID not uppercase hex | Always `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` |
| Invalid UUID | Non-hex chars (e.g. `GGGG…`) | Hex digits only `0-9A-F` |
| Save File action missing | Used `is.workflow.actions.savefile` | Use `documentpicker.save` |
| Unsigned import blocked | Not signed | `./scripts/sign_shortcut.sh …` on macOS |
| Works on iOS, fails on Mac | Platform-only action | Prefer `ask` over `shareextension`; avoid unavailable App Intents |

## Control-flow checklist

1. One shared `GroupingIdentifier` per block
2. `WFControlFlowMode`: `0` start, `1` middle (else / menu case), `2` end
3. Modes are `<integer>`, never `<string>`
4. Menu: `WFMenuItems` titles must match each case’s `WFMenuItemTitle`
5. Repeat Index / Repeat Item: reference the **End** action UUID (`CONTROL_FLOW.md`)

## Variable wiring checklist

1. Producer action has `UUID`
2. Consumer text uses `￼` (U+FFFC) exactly where the value inserts
3. `attachmentsByRange` key `{position, length}` matches that index (`length` usually `1`)
4. `OutputUUID` = producer UUID; `Type` = `ActionOutput`
5. `OutputName` is the English name Shortcuts expects

## Signing checklist

1. `./scripts/validate.sh` passes
2. Input is XML plist (or set `SKIP_XMLLINT=1` for binary)
3. Mode is `anyone` or `people-who-know-me`
4. Do not commit signed files that embed secrets / personal vault paths

## Debugging strategy

1. Start from a golden in `templates/examples/`
2. Change one action at a time
3. If still failing: build the same flow in Shortcuts.app, export, diff the plist
