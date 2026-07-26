# Ecosystem — external sources (central index)

This skill stays **small and Hermes-focused**. It does **not** absorb every Shortcuts
repo on GitHub. Instead we keep a machine-readable registry and selective vendors.

| Artifact | Role |
|----------|------|
| [`data/sources.json`](../data/sources.json) | SSOT registry (URL, license, use policy) |
| [`data/external/*.index.jsonl`](../data/external/) | Remote corpus indexes (metadata only) |
| [`templates/examples/community/`](../templates/examples/community/) | Few MIT-vendored goldens that fill gaps |
| [`THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md) | Attribution |

## Policy (short)

1. **Link** peer skills and GPL tooling — do not copy wholesale.
2. **Index** large golden corpora (titles/tags/paths) without cloning XML by default.
3. **Vendor** only when: compatible license + passes `./scripts/validate.sh` + fills a gap + attributed.
4. Prefer **export-diff from Shortcuts.app** over inventing parameters for undocumented actions.

## Map

```mermaid
flowchart TB
  hermesSkill[This Hermes skill]
  upstream[drewocarr generate-shortcuts-skill]
  playground[viticci shortcuts-playground MIT]
  sebj[sebj iOS-Shortcuts-Reference]
  shortcutsjs[joshfarrant shortcuts-js GPL]
  apple[Apple URL scheme docs]
  hermesSkill -->|lineage| upstream
  hermesSkill -->|selective goldens + URL docs| playground
  hermesSkill -->|icon colors types ImportQuestions| sebj
  hermesSkill -->|link only| shortcutsjs
  hermesSkill -->|canonical URLs| apple
```

## Highest-value peers

| Source | Why it matters | What we take |
|--------|----------------|--------------|
| [viticci/shortcuts-playground-plugin](https://github.com/viticci/shortcuts-playground-plugin) | Best-in-class agent skill + 19 goldens | Index + 2 community XMLs + URL scheme patterns |
| [drewocarr/generate-shortcuts-skill](https://github.com/drewocarr/generate-shortcuts-skill) | Upstream skill lineage | Historical baseline |
| [sebj/iOS-Shortcuts-Reference](https://github.com/sebj/iOS-Shortcuts-Reference) | Classic format/ARGB/types | Colors + types cited into PLIST_FORMAT / URL_SCHEMES |
| [joshfarrant/shortcuts-js](https://github.com/joshfarrant/shortcuts-js) | Mature JS generator (archived, GPL) | **Link only** |
| [0xdevalias gist](https://gist.github.com/0xdevalias/27d9aea9529be7b6ce59055332a94477) | iCloud → bplist → `plutil` | Linked in extract roadmap |
| [RoutineHub Source Tool](https://routinehub.co/shortcut/5256/) | On-device source inspect | Link for human debugging |

**Closing the authoring gap (without absorbing Viticci):** see [`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md).

## Parity notes (V0 — 2026-07-26)

Snapshot of [viticci/shortcuts-playground](https://github.com/viticci/shortcuts-playground-plugin) authoring surface vs this skill:

| Peer capability | Viticci | Our lean equivalent (target) |
|-----------------|---------|------------------------------|
| Build from scratch | `/shortcuts-playground:build` + builder agent | `SKILL.md` steps 1–9 + goldens |
| Remix / surgical diff | `/shortcuts-playground:remix` + remixer agent | **`references/REMIX.md` + `scripts/remix_shortcut.py`** (V1) |
| Validate on edit | PostToolUse → `validate-shortcut` (Craig Loop) | **`scripts/validate_on_write.sh`** after each Write (V2) |
| Sign wrapper | `sign-shortcut` (archive + sign, no `_signed` suffix) | `scripts/sign_shortcut.sh` (keep; attest uses `_signed` temp names) |
| Icon resolver | `resolve-icon` / `select_shortcut_icon_color.py` | Table in `PLIST_FORMAT.md` (V3 lite later) |
| ToolKit allowlists | v63 + v78 gated JSON catalogs | `data/wf_actions.json` (**438**) + `appintents.json` (168 curated; see `APPINTENTS_GAP.md`) |
| Goldens | ~19 playground XMLs | 9 teaching + **16** palette + **8** community |
| Attestation Mac import/run | Not first-class | **`attest_local.sh --auto` + `results.json`** (lead) |

**MVP attack order chosen:** V1 remix → V2 validate_on_write → V3 goldens batch (see `COMPETITIVE_CHECKLIST.md`).

**Do not copy:** BEST_PRACTICES monolith, ToolKit v78 dumps wholesale, Claude-only hooks/agents, HealthKit pack until needed.

## Community goldens vendored here

See [`templates/examples/community/README.md`](../templates/examples/community/README.md).

| File | Upstream title | Gap filled |
|------|----------------|------------|
| `09-url-cleaner.shortcut.xml` | URL Cleaner | Real-world URL/text cleanup |
| `10-parse-json-feed.shortcut.xml` | Parse JSON Feed | HTTP + dictionary + choose-from-list |
| `11-invert-names.shortcut.xml` | Invert Names | Text / list transform |
| `12-days-in-a-month.shortcut.xml` | Days in a Month | Date math |
| `13-electricity-price.shortcut.xml` | Electricity Price | Network + dictionary |
| `14-preview-folder-contents.shortcut.xml` | Preview Folder Contents | Files / folder listing |
| `15-masto-redirect.shortcut.xml` | Masto Redirect | HTTP + URL rewrite |
| `16-calendar-locations.shortcut.xml` | Calendar Locations | Calendar + locations |

Full upstream catalog (19 entries): `data/external/viticci-playground-goldens.index.jsonl`.

## Refreshing indexes

```bash
curl -sL \
  https://raw.githubusercontent.com/viticci/shortcuts-playground-plugin/main/claude/skills/shortcuts-playground/golden-shortcuts/index.jsonl \
  -o data/external/viticci-playground-goldens.index.jsonl
```

To vendor another MIT golden: download XML → add attribution comment → place under
`templates/examples/community/` → run `./scripts/validate.sh` → update notices + this table.

## What not to do

- Do not submodule GPL `shortcuts-js` into this MIT repo.
- Do not paste Viticci’s entire ~12k-line skill tree (keep Hermes skill lean; point agents at ECOSYSTEM when needed).
- Do not treat RoutineHub iCloud links as permanent fixtures (they rot).
- Do not revive Locally→Obsidian as a golden — product direction is [`HORIZON.md`](HORIZON.md).
