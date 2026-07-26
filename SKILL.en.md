---
name: shortcuts-generator
description: >
  Use when the user wants to create, inspect, modify, or import a macOS/iOS
  Shortcut. Covers generating valid `.shortcut` files from plist XML,
  signing them for import, and understanding the Shortcuts action grammar:
  WF*Actions, AppIntents, variables, and control flow. Optionally bridges to
  Obsidian vault workflows (see references/OBSIDIAN_BRIDGE.md).
version: 1.10.0
author: OTNworld fork / Hermes adaptation
license: MIT
platforms: [macos, ios]
metadata:
  hermes:
    tags: [shortcuts, automation, apple, plist, ios, macos]
    related_skills: [obsidian, apple-reminders, imessage]
---

# macOS/iOS Shortcuts Generator (EN)

English mirror of the agent protocol. The Hermes-facing `SKILL.md` remains French;
follow the same steps and scripts.

## Commands (virtual)

| Intent | How |
|--------|-----|
| **build** | `SKILL.md` / this file steps 1–11 |
| **remix** | `references/REMIX.md` + `python3 scripts/remix_shortcut.py` |
| **attest** | `./scripts/attest_local.sh --auto` (local Mac only) |
| **validate** | `./scripts/validate_on_write.sh <file>` after every plist edit |

## Steps

1. Collect name, inputs, actions, order.
2. Prefer `references/POWER_ACTIONS.md`, then `data/wf_actions.json` / `ACTIONS.md` / `appintents.json`.
3. Uppercase hex UUIDs per producer action.
4. Build plist per `PLIST_FORMAT.md` + `PARAMETER_TYPES.md`.
5. Wire outputs with `attachmentsByRange` + U+FFFC (`VARIABLES.md`).
6. Control flow: `CONTROL_FLOW.md` + goldens 04/06/07/08.
7. `./scripts/validate.sh` / `FAILURE_MODES.md`.
8. Sign (`scripts/sign_shortcut.sh`).
9. **After every Write/Edit:** `./scripts/validate_on_write.sh <file>`.
10. **Remix** existing XML via `REMIX.md` — do not full-regenerate.
11. Mac attestation: `./scripts/attest_local.sh --auto` (`ATTEST_AUTOMATION.md`).

## Hard rules

- UUIDs `0-9A-F` uppercase only.
- `WFControlFlowMode` is `<integer>`, never string.
- Ranges `{position, length}`; variable mark is `￼` (U+FFFC).
- English `OutputName` labels only (`OUTPUT_NAMES.md`).
- Never `is.workflow.actions.savefile` → use `documentpicker.save`.

## Differentiation

Mac **sign → import UI → run → results.json** is first-class. See `COMPETITIVE_CHECKLIST.md` for lean parity vs larger playground plugins.
