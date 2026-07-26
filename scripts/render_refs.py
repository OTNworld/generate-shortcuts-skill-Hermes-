#!/usr/bin/env python3
"""Regenerate catalog markdown fences from data/*.json SSOT.

Usage:
  python3 scripts/render_refs.py
  python3 scripts/render_refs.py --check   # exit 1 if docs drift from SSOT
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fence_csv(items: list[str], width: int = 80) -> str:
    line, lines = [], []
    for it in items:
        candidate = (", ".join(line + [it])) if line else it
        if len(candidate) > width and line:
            lines.append(", ".join(line) + ",")
            line = [it]
        else:
            line.append(it)
    if line:
        lines.append(", ".join(line))
    return "\n".join(lines)


def group_appintents(ids: list[str]) -> list[tuple[str, list[str]]]:
    groups = {
        "Open* (Settings / deep links)": [],
        "Create*": [],
        "Toggle*": [],
        "Set*": [],
        "Find* / Search*": [],
        "Delete*": [],
        "Other": [],
    }
    for i in ids:
        if i.startswith("Open"):
            groups["Open* (Settings / deep links)"].append(i)
        elif i.startswith("Create"):
            groups["Create*"].append(i)
        elif i.startswith("Toggle"):
            groups["Toggle*"].append(i)
        elif i.startswith("Set"):
            groups["Set*"].append(i)
        elif i.startswith("Find") or i.startswith("Search"):
            groups["Find* / Search*"].append(i)
        elif i.startswith("Delete"):
            groups["Delete*"].append(i)
        else:
            groups["Other"].append(i)
    return [(k, v) for k, v in groups.items() if v]


def render_appintents(ids: list[str]) -> str:
    sections = []
    for title, items in group_appintents(ids):
        sections.append(f"### {title} ({len(items)})\n```\n{fence_csv(items)}\n```\n")
    header = f"""# AppIntents Reference

Curated subset of **{len(ids)}** AppIntent identifiers commonly used with Shortcuts
(`appintentexecution`). Source of truth: [`data/appintents.json`](../data/appintents.json).
This is not a complete dump of every system AppIntent on macOS/iOS.

## AppIntents vs WF*Actions

| Aspect | WF*Actions | AppIntents |
|--------|-----------|------------|
| Identifier format | `is.workflow.actions.*` | PascalCase intent / deep-link ids |
| Origin | Legacy Shortcuts (pre-iOS 16) | App Intents framework (iOS 16+) |
| Invocation | Direct identifier in action | Via `appintentexecution` wrapper |
| Scope | Core shortcut actions | System integrations, deep links, app extensions |

## How to Invoke AppIntents

AppIntents are invoked using the `WFAppIntentExecutionAction` wrapper:

```xml
<dict>
    <key>WFWorkflowActionIdentifier</key>
    <string>is.workflow.actions.appintentexecution</string>
    <key>WFWorkflowActionParameters</key>
    <dict>
        <key>AppIntentDescriptor</key>
        <dict>
            <key>BundleIdentifier</key>
            <string>com.apple.AccessibilityUtilities.AXSettingsShortcuts</string>
            <key>Name</key>
            <string>Open VoiceOver</string>
            <key>TeamIdentifier</key>
            <string>0000000000</string>
            <key>AppIntentIdentifier</key>
            <string>OpenAccessibilityVoiceOverStaticDeepLinks</string>
        </dict>
    </dict>
</dict>
```

---

## Complete AppIntent Identifier List

All **{len(ids)} curated** AppIntent identifiers in this skill (generated from SSOT):

"""
    footer = """
## Invocation Template

To invoke any AppIntent:

```xml
<dict>
    <key>WFWorkflowActionIdentifier</key>
    <string>is.workflow.actions.appintentexecution</string>
    <key>WFWorkflowActionParameters</key>
    <dict>
        <key>AppIntentDescriptor</key>
        <dict>
            <key>BundleIdentifier</key>
            <string>BUNDLE_ID</string>
            <key>Name</key>
            <string>DISPLAY_NAME</string>
            <key>AppIntentIdentifier</key>
            <string>APPINTENT_IDENTIFIER</string>
        </dict>
    </dict>
</dict>
```

Common Bundle Identifiers:
- `com.apple.AccessibilityUtilities.AXSettingsShortcuts` - Accessibility
- `com.apple.Preferences` - Settings
- `com.apple.clock` - Clock
- `com.apple.mobilenotes` - Notes
- `com.apple.reminders` - Reminders
- `com.apple.Safari` - Safari
- `com.apple.Home` - Home
- `com.apple.Photos` - Photos
"""
    return header + "\n".join(sections) + footer


def replace_actions_fence(actions_md: str, names: list[str]) -> str:
    count = len(names)
    # Update claim lines
    actions_md = re.sub(
        r"all \d+ WF\*Action",
        f"all {count} WF*Action",
        actions_md,
        count=1,
    )
    actions_md = re.sub(
        r"All \d+ action identifiers",
        f"All {count} action identifiers",
        actions_md,
        count=1,
    )
    fence = fence_csv(names)
    pattern = r"(All \d+ action identifiers[^\n]*:\n\n```\n)([\s\S]*?)(\n```)"
    m = re.search(pattern, actions_md)
    if not m:
        raise SystemExit("ACTIONS.md complete-list fence not found")
    return actions_md[: m.start(2)] + fence + actions_md[m.end(2) :]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    wf = json.loads((ROOT / "data/wf_actions.json").read_text())
    ai = json.loads((ROOT / "data/appintents.json").read_text())

    app_path = ROOT / "references/APPINTENTS.md"
    actions_path = ROOT / "references/ACTIONS.md"
    new_app = render_appintents(ai["identifiers"])
    new_actions = replace_actions_fence(actions_path.read_text(), wf["identifiers"])

    if args.check:
        drift = False
        if app_path.read_text() != new_app:
            print("DRIFT references/APPINTENTS.md (run scripts/render_refs.py)")
            drift = True
        if actions_path.read_text() != new_actions:
            print("DRIFT references/ACTIONS.md complete list fence")
            drift = True
        if drift:
            return 1
        print("OK  render_refs.py --check (no drift)")
        return 0

    app_path.write_text(new_app)
    actions_path.write_text(new_actions)
    print(f"OK  wrote APPINTENTS.md ({ai['count']}) and ACTIONS list ({wf['count']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
