# Mackasten — companion app, Siri, marketplace

**Status:** product direction (2026-07-26). Not implemented in this Hermes skill repo yet.  
**Replaces:** Locally → Obsidian golden track (`templates/locally-obsidian.stub.xml` **abandoned**).

## Why abandon Locally / Obsidian golden

The Locally stub was an honest design snapshot, never importable, and depended on a third-party AI app + vault conventions. Maintaining that path diluted Mac-first Shortcuts quality without a shippable artifact.

Obsidian URL notes remain optional in [`OBSIDIAN_BRIDGE.md`](OBSIDIAN_BRIDGE.md) for users who already live in a vault. They are **not** a product commitment of this skill.

## Product thesis

Build a **companion app** that sits next to this repo’s skill / goldens / attestation loop:

| Layer | Role |
|-------|------|
| **This skill (Hermes)** | Author, remix, validate, sign, attest Shortcuts XML |
| **Companion app** | Runtime surface: browse, install, run, personalize shortcuts; talk to **on-device / local models** |
| **Siri (next-gen + App Intents)** | Invoke marketplace items and local-model workflows by voice / system intents |
| **Marketplace** | Curated shortcut packs — especially **local-model** recipes (summarize, rewrite, tag, draft) that stay on-device when possible |

## Design principles

1. **Skill stays lean MIT** — catalogs, goldens, validators; no mega ToolKit dump.
2. **App owns UX + distribution** — signing modes, trust, updates, model routing.
3. **Prefer App Intents + Shortcuts** over fragile URL-scheme bridges to third-party AI apps.
4. **Local models first** for marketplace SKUs that would otherwise send vault/notes off-device.
5. **Attestation culture** — marketplace listings should cite skill-style MATRIX / `results.json` where feasible (Mac/iOS).

## Near-term hooks in *this* repo

Until the app repo exists:

- Keep generating/validating Shortcuts that the app will eventually host.
- Expand palette + remix so agents can author marketplace-ready goldens.
- Track App Intent gaps for Siri / on-device AI in [`APPINTENTS_GAP.md`](APPINTENTS_GAP.md) (watchlist only — no invented IDs).
- Do **not** revive `locally-obsidian.stub.xml` as an importable golden.
- **Paper MVP:** package manifests under [`mackasten/`](../mackasten/) — see [`MACKASTEN_CHECKLIST.md`](MACKASTEN_CHECKLIST.md).

## Package format (`mackasten-package/v1`)

Validated by `scripts/check_mackasten_packages.py` (CI):

| Field | Role |
|-------|------|
| `shortcuts[].path` | Repo-relative unsigned XML |
| `model_policy` | `none` / `apple-intelligence` / `on-device-preferred` / `cloud-allowed` |
| `siri_phrases` | Future Siri / App Intent invocation hints |
| `attestation` | Pointers to MATRIX / `results.json` + coarse status |
| `edit.deep_link` | `hermes-shortcuts://edit?path=…` (convention only) |

Samples: `mackasten/packages/hello-world`, `mackasten/packages/local-ask-llm`.

## Deep link (convention)

```
hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml
```

Not registered by this skill repo — reserved for the companion app / IDE bridge.

## Suggested app backlog (out of band)

1. Scaffold native app (Swift / App Intents) with Shortcuts import + run helpers.
2. Consume `mackasten/packages/*/package.json` as marketplace catalog seed.
3. Local-model adapter (Apple Intelligence / third-party on-device) behind a stable App Intent.
4. Siri phrases → install/run marketplace shortcut.
5. Resolve `hermes-shortcuts://edit` back into this skill workspace.

## Anti-goals

- Rebuilding Locally as a Shortcuts-only stub.
- Vendoring large playground plugins into this skill.
- Promising Cloud Agent Linux can attest Mac/iOS runs.
