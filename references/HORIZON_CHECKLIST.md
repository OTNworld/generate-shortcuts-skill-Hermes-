# Checklist — Horizon paper MVP (sans app native)

Dernière màj : **2026-07-26** · Skill : **1.13.0**  
**Périmètre :** format marketplace + manifests + validation dans *ce* repo.  
**Hors scope :** binaire Swift, App Store, Siri runtime (repo app séparé).

Vision : [`HORIZON.md`](HORIZON.md) · index : [`../horizon/README.md`](../horizon/README.md)

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

- [x] `data/schemas/horizon-package.v1.json`
- [x] `horizon/packages/hello-world` + `local-ask-llm`
- [x] `scripts/check_horizon_packages.py` in `validate.sh` + unittest
- [x] Deep-link convention in `HORIZON.md` / package `edit`
- [x] `model_policy` enum + `local-*` ≠ `cloud-allowed` gate

**DoD paper MVP :** validate/selftest verts ; app runtime reste hors repo.

---

## Next (app repo — not this skill)

- [ ] Swift scaffold consuming `horizon/packages/`
- [ ] Register `hermes-shortcuts://` URL scheme
- [ ] On-device model adapter + Siri phrases → install/run

## Anti-goals

- [x] Ne pas implémenter l’app dans ce repo
- [x] Ne pas revendiquer attestation marketplace sans MATRIX
- [x] Ne pas utiliser AppIntents `unverified` dans un package teaching
