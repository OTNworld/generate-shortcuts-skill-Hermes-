# Checklist — sprints Linux → 10/10 (sans Mac/iOS)

Dernière màj : **2026-07-26** · Skill : **1.12.0**  
Branche : `cursor/mackasten-app-and-improvements-df7d`

**Périmètre :** tout ce qui atteint 10/10 **sans** `shortcuts` CLI, sans import UI, sans device.  
**Hors scope :** attestation MATRIX live, iOS, Mackasten app runtime, AppIntents *verified* via export.

**Légende :** `[ ]` todo · `[~]` partiel · `[x]` done · **DoD** = critère d’acceptation

Liens : [`AGENT_ENTRY.md`](AGENT_ENTRY.md) · [`MACKASTEN.md`](MACKASTEN.md) · [`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md) (Mac)

---

## Tableau de suivi

| Sprint | Critère rating | Cible | Status |
|--------|----------------|------:|--------|
| L1 | CI / tests | 10 | [x] |
| L2 | Documentation | 10 | [x] |
| L3 | SSOT mécanique | 10 | [x] |
| L4 | DX agent | 10 | [x] |
| L5 | Sécurité / licence | 10 | [x] |

**Anti-checklist**

- [x] Ne pas promettre Import/Run depuis Linux
- [x] Ne pas inventer des AppIntent IDs `verified: true`
- [x] Ne pas gonfler ToolKit dumps
- [x] Ne pas rouvrir Locally→Obsidian

---

## L1 — CI / tests → 10/10 — **DONE**

- [x] `tests/test_linux10.py` + `python3 -m unittest discover -s tests -v`
- [x] `data/schemas/attest-results.v1.json` + check in validate
- [x] `fixtures/remix/hello-bonjour.{input,expected}.xml`

**DoD :** `selftest.sh` rouge si unittest / schema / remix I/O casse.

---

## L2 — Documentation → 10/10 — **DONE**

- [x] `references/AGENT_ENTRY.md`
- [x] Liens SKILL / SKILL.en / README
- [x] Drift branche / counts / script DoD index

---

## L3 — SSOT mécanique → 10/10 — **DONE**

- [x] `data/schemas/wf_actions.v1.json` + `appintents.v1.json`
- [x] `unverified` ⊆ identifiers (14)
- [x] `platform_hints` palette-centric (31)

---

## L4 — DX agent → 10/10 — **DONE**

- [x] FAILURE_MODES « Erreur → une commande »
- [x] Craig `savefile` → `documentpicker.save` + fixture
- [x] Agent contract via AGENT_ENTRY + selftest CI

---

## L5 — Sécurité / licence → 10/10 — **DONE**

- [x] Lineage `sources.json` + THIRD_PARTY + SECURITY
- [x] `check_no_secrets.py` in validate
- [x] Signing hygiene note (default `anyone`)

---

## Definition of Done — track Linux 10/10

- [x] L1–L5 toutes `[x]`
- [x] `validate.sh` + `selftest.sh` + unittest verts
- [x] `SKILL.md` **1.12.0** + CHANGELOG
- [x] Aucune promesse Mac/iOS non tenue
- [x] Rating interne : CI/Docs/SSOT/DX/Security = **10** (attestation/Mackasten inchangés — Mac/app)

### Commandes de clôture

```bash
./scripts/validate.sh
./scripts/selftest.sh
python3 -m unittest discover -s tests -v
```
