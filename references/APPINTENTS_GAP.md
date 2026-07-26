# AppIntents gap audit (lean)

Date: **2026-07-26** (batch +14 Settings/VPN; Horizon watchlist)  
Peer: [viticci/shortcuts-playground](https://github.com/viticci/shortcuts-playground-plugin) `APPINTENTS.md` + ToolKit v63/v78 snapshots.

## Models (do not conflate)

| Ours | Peer |
|------|------|
| Curated **168** short `AppIntentIdentifier` names for `is.workflow.actions.appintentexecution` (`data/appintents.json`) | **~1632+** first-party ToolKit identifiers (often full `com.apple.*` action IDs) + gated v78 dumps |
| Authoring-safe subset with Hermes docs | Validator allowlists; many IDs are coverage-only |

## Decision

- **Keep** curated SSOT. Do **not** vendor ToolKit JSON dumps (size + OS gating + MIT lean policy).
- Prefer WF*Actions + documented goldens for Mac-first workflows.
- When a user needs an intent absent from `appintents.json`, add **one batch ≤20** after verifying BundleIdentifier + Name from an exported shortcut — never invent descriptors.
- Settings deep-link batch (Open*SettingsStaticDeepLinks / VPN Set|Toggle) follows existing SSOT grammar; **verify on Mac** before teaching `appintentexecution` goldens.

## 2026-07-26 curated batch (+14)

`OpenVPN|Developer|Wallpaper|LockScreen|Safari|Photos|Messages|Camera|AppStore|Health|GameCenter|Translate` + `SettingsStaticDeepLinks`, plus `SetVPNIntent` / `ToggleVPNIntent`.

## Horizon watchlist (do not invent IDs)

Companion app / next-gen Siri / on-device models ([`HORIZON.md`](HORIZON.md)):

- On-device rewrite / summarize / proofread extensions beyond current `RewriteIntent` / `SummarizeIntent` / `ProofreadIntent`
- Marketplace install / run intents (app-owned, not Apple system)
- Any new Siri App Intents shipped with the next OS — capture via **export-diff** only

## Observed peer deltas worth watching (OS 26→27)

Documented in peer `APPINTENTS.md` (not absorbed here): battery charge limit, multitasking mode, Safari tab groups, Messages tapback/search, Photos enhance/favorite, Reminders groups/sections, VPN settings intents (VPN deep links now partially in our SSOT).

Add to our SSOT only when a teaching/community golden or user shortcut needs them.

## Counts

| Catalog | Count |
|---------|------:|
| `data/appintents.json` | 168 |
| Peer APPINTENTS “complete” claim | ~1632 |
| Peer ToolKit v78 tool-ids (actions+intents) | ~2731 |

**Agent rule:** missing intent ≠ copy peer dump; export from Shortcuts.app or skip with MATRIX note.
