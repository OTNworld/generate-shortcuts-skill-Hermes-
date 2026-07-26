# Checklist — Mac 10/10 (device only)

Dernière màj : **2026-07-26** · Prérequis skill : **≥1.12.0**  
Branche : `cursor/horizon-app-and-improvements-df7d`

**Périmètre :** uniquement ce qui exige Darwin + Shortcuts.app.  
**Déjà clos hors device :** [`LINUX_10_CHECKLIST.md`](LINUX_10_CHECKLIST.md) · historique détaillé : [`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md)

Handoff opérationnel : [`../fixtures/attested/MAC_HANDOFF.md`](../fixtures/attested/MAC_HANDOFF.md) · [`../LOCAL_FINALIZE.md`](../LOCAL_FINALIZE.md)

---

## Tableau de suivi

| ID | Item | P | Status |
|----|------|---|--------|
| M1 | Attest palette 13–16 | P0 | [ ] |
| M2 | Network pass documenté | P1 | [ ] |
| M3 | Trust sheet people-who-know-me | P1 | [ ] |
| M4 | Export-verify AppIntents `unverified` | P1 | [ ] |
| M5 | Idempotence 2× `--auto` | P2 | [ ] |
| M6 | iOS sample (optionnel) | P2 | [ ] |
| M7 | MATRIX + hashes + results bump | P0 | [ ] |

---

## M1 — Palette 13–16 **P0**

```bash
./scripts/validate.sh
./scripts/attest_local.sh --import-ui --run --timeout 20
# or full:
./scripts/attest_local.sh --auto --force --timeout 20
```

Goldens : `palette/13-notification`, `14-number`, `15-openapp`, `16-speaktext`

| Golden | Sign | Import | Run | Notes attendues |
|--------|------|--------|-----|-----------------|
| 13-notification | [ ] | [ ] | [ ] | may need notification permission |
| 14-number | [ ] | [ ] | [ ] | headless OK expected |
| 15-openapp | [ ] | [ ] | [ ] | focuses Safari — OK if Import OK |
| 16-speaktext | [ ] | [ ] | [ ] | Run=ENV/audio OK to skip with note |

**DoD :** lignes MATRIX remplies ; pass criteria palette 13–16 cochée.

---

### M1b — Community 17–18 (optional Import) **P1**

- [ ] `17-create-calendar-event-from-template` Import OK (Run may be UI/ask)
- [ ] `18-select-folder-compress-share` Import OK (Run=UI share sheet)

```bash
./scripts/attest_local.sh --import-ui --all --timeout 20
```

```bash
./scripts/run_shortcut_attest.sh --include-network
```

- [ ] `04-url-open` → NET note
- [ ] `08-downloadurl` → NET flaky OK/FAIL documenté
- [ ] `05-weather-ai` → ENV (Intelligence) vs NET classé

**DoD :** aucune case Run vide pour ces trois sans légende UI/NET/ENV.

---

## M3 — Trust sheet **P1**

- [ ] Documenter dans `ATTEST_AUTOMATION.md` un run `people-who-know-me` (manuel OK)
- [ ] Confirmer AX names FR/EN sur sheet « non fiable »

**DoD :** playbook 5 lignes reproductible.

---

## M4 — AppIntents unverified → verified **P1**

List : `data/appintents.json` → `unverified` (14 IDs).

Pour chaque ID confirmé via export Shortcuts.app :

1. Noter BundleIdentifier + Name
2. Retirer de `unverified`
3. `./scripts/validate.sh` + `render_refs.py` si docs

**DoD :** `unverified` shrink ou documenté « deferred » ; **jamais** teaching golden `appintentexecution` tant que dans `unverified`.

---

## M5 — Idempotence **P2**

```bash
./scripts/attest_local.sh --auto
./scripts/attest_local.sh --auto   # expect SKIP imports
```

- [ ] Pas de doublons library
- [ ] Cleanup manuel doc si besoin (préfixe `*_signed` only)

---

## M6 — iOS (optionnel) **P2**

- [ ] AirDrop/iCloud 1 signed `anyone`
- [ ] 1–2 cellules colonne iOS MATRIX

---

## M7 — Clôture MATRIX **P0**

- [ ] `MATRIX.md` + `hashes.sha256` + `results.json` cohérents
- [ ] `skill_version` dans results = version SKILL courante
- [ ] CHANGELOG attestation note si bump

**DoD Mac 10/10 skill :** M1 + M7 verts ; M2–M5 selon priorité.

---

## Commandes boucle

```bash
./scripts/check_shortcuts_automation.sh --json
./scripts/attest_local.sh --auto --force --timeout 20
./scripts/run_shortcut_attest.sh --include-network
cat fixtures/attested/runs/run_report.tsv
./scripts/write_attest_results.sh
```
