# Roadmap: 10/10 (next)

Palier A (9/10) is implemented in v1.6.0. Remaining for a credible **10/10 skill**:

| ID | Item | Status |
|----|------|--------|
| B1 | Make `check_shortcut_grammar.py --strict` the default CI gate + range-vs-string-length checks | **Done (1.8.0)** |
| B2 | Starter palette 12–20 full XML schemas (`templates/palette/`) | **Done (16 in 1.11.0)** |
| B3 | Fill `fixtures/attested/MATRIX.md` with real macOS/iOS import proofs | **Done (1.9.0 Mac 26.5)** — palette 13–16 pending Mac re-attest |
| B4 | Generate markdown catalogs from `data/*.json` (`scripts/render_refs.py`) | **Done (1.8.0)** |
| B5 | `SECURITY.md` | Done (prep) |
| B6 | `SKILL.en.md` + `OUTPUT_NAMES.md` | **Done (1.10.0)** |
| B7 | Share Sheet / ImportQuestions golden (`09-share-sheet-input`) | **Done (1.10.0)** |
| B8 | `URL_SCHEMES.md` + Locally track | **URL_SCHEMES done**; **Locally abandoned** → [`MACKASTEN.md`](MACKASTEN.md) |
| B9 | `scripts/extract_shortcut.sh` (`plutil` round-trip helper) | **Done (1.8.0)** |
| B10 | Expand community vendors from `data/external/*.index.jsonl` as needed | **11 goldens (1.16.0)**; 8 gaps remain |
| B11 | Attestation automation (import UI + run) | **Done (scripts)** — sheets / NET harden in 1.11.0 |
| B12 | Lean remix + validate-on-write | **Done (1.10.0)**; structural remix **1.11.0** |
| B13 | Mackasten companion app / Siri / marketplace | **Paper MVP (1.13.0)** + **oneshot blueprint (`mackasten/app/`)** — private `mackasten-iOS` + fetch CI; see [`../mackasten/app/`](../mackasten/app/) |

**Prochains pas détaillés (checklist active) :**  
[`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md) (attestation / 10/10 Mac)  
[`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md) (parité auteur vs Viticci, lean)  
[`MACKASTEN.md`](MACKASTEN.md) (app / marketplace — hors skill lean)


Ecosystem hub: `references/ECOSYSTEM.md` + `data/sources.json`.

See `CONTRIBUTING.md` and `fixtures/attested/README.md`.

Mac next step: [`fixtures/attested/MAC_HANDOFF.md`](../fixtures/attested/MAC_HANDOFF.md).
