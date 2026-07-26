# AppIntents gap audit (lean)

Date: **2026-07-26**  
Peer: [viticci/shortcuts-playground](https://github.com/viticci/shortcuts-playground-plugin) `APPINTENTS.md` + ToolKit v63/v78 snapshots.

## Models (do not conflate)

| Ours | Peer |
|------|------|
| Curated **154** short `AppIntentIdentifier` names for `is.workflow.actions.appintentexecution` (`data/appintents.json`) | **~1632+** first-party ToolKit identifiers (often full `com.apple.*` action IDs) + gated v78 dumps |
| Authoring-safe subset with Hermes docs | Validator allowlists; many IDs are coverage-only |

## Decision

- **Keep** curated SSOT. Do **not** vendor ToolKit JSON dumps (size + OS gating + MIT lean policy).
- Prefer WF*Actions + documented goldens for Mac-first workflows.
- When a user needs an intent absent from `appintents.json`, add **one batch ≤20** after verifying BundleIdentifier + Name from an exported shortcut — never invent descriptors.

## Observed peer deltas worth watching (OS 26→27)

Documented in peer `APPINTENTS.md` (not absorbed here): battery charge limit, multitasking mode, Safari tab groups, Messages tapback/search, Photos enhance/favorite, Reminders groups/sections, VPN settings intents.

Add to our SSOT only when a teaching/community golden or user shortcut needs them.

## Counts

| Catalog | Count |
|---------|------:|
| `data/appintents.json` | 154 |
| Peer APPINTENTS “complete” claim | ~1632 |
| Peer ToolKit v78 tool-ids (actions+intents) | ~2731 |

**Agent rule:** missing intent ≠ copy peer dump; export from Shortcuts.app or skip with MATRIX note.
