# Checklist — Mackasten paper MVP (sans app native)

Dernière màj : **2026-07-26** · Skill : **1.13.0**  
**Périmètre :** format marketplace + manifests + validation dans *ce* repo.  
**Hors scope :** binaire Swift, App Store, Siri runtime (repo app séparé).

Vision : [`MACKASTEN.md`](MACKASTEN.md) · index : [`../mackasten/README.md`](../mackasten/README.md)

---

## Tableau de suivi

| Sprint | Cible | Status |
|--------|------:|--------|
| H1 Package schema | 10 | [x] |
| H2 Sample packages | 10 | [x] |
| H3 Validate gate | 10 | [x] |
| H4 Edit-in-skill / deep-link conventions | 10 | [x] |
| H5 Local-model SKU metadata | 10 | [x] |

---

## H1–H5 — **DONE (paper MVP)**

- [x] `data/schemas/mackasten-package.v1.json`
- [x] `mackasten/packages/hello-world` + `local-ask-llm`
- [x] `scripts/check_mackasten_packages.py` in `validate.sh` + unittest
- [x] Deep-link convention in `MACKASTEN.md` / package `edit`
- [x] `model_policy` enum + `local-*` ≠ `cloud-allowed` gate

**DoD paper MVP :** validate/selftest verts ; app runtime reste hors repo.

---

## Next (app repo — not this skill)

Blueprint oneshot + **Swift scaffold** lives in [`../mackasten/app/`](../mackasten/app/) — **seed ready**.

Private repo: **`OTNworld/Mackasten`** (create under your account; see `app/REPO_BOOTSTRAP.md`).

- [ ] Grant Cursor GitHub App access to `Mackasten`
- [ ] Push seed from `mackasten/app/` (`scripts/push_seed_to_mackasten.sh`)
- [ ] Mac: `xcodegen generate` + Simulator catalog / install / run Hello World
- [ ] Complete remaining P0 gates in [`../mackasten/app/CHECKLIST.md`](../mackasten/app/CHECKLIST.md)
- [ ] On-device Siri / Apple Intelligence smokes

## Anti-goals

- [x] Ne pas shipper de binaire App Store depuis ce skill (seed Swift OK ; runtime = repo privé)
- [x] Ne pas revendiquer attestation marketplace sans MATRIX
- [x] Ne pas utiliser AppIntents `unverified` dans un package teaching
