# Checklist — prochains pas (attestation + skill 10/10)

Dernière màj : **2026-07-26** (Mac local, macOS 26.5.2, automation Return/AX en place).  
Branche de travail : `cursor/skill-quality-hardening-0e57`.

**Légende**

| Symbole | Sens |
|---------|------|
| `[ ]` | À faire |
| `[~]` | En cours / partiel |
| `[x]` | Fait |
| **P0** | Bloque 10/10 ou fiabilité automation |
| **P1** | Fort ROI, faire juste après P0 |
| **P2** | Nice-to-have / polish |
| **DoD** | Definition of Done (critère d’acceptation) |

Liens utiles :

- Automation : [`ATTEST_AUTOMATION.md`](ATTEST_AUTOMATION.md)
- Matrice : [`../fixtures/attested/MATRIX.md`](../fixtures/attested/MATRIX.md)
- Handoff : [`../fixtures/attested/MAC_HANDOFF.md`](../fixtures/attested/MAC_HANDOFF.md)
- Finalize : [`../LOCAL_FINALIZE.md`](../LOCAL_FINALIZE.md)
- Roadmap historique : [`ROADMAP_10.md`](ROADMAP_10.md)

---

## État actuel (baseline 2026-07-26)

| Zone | État |
|------|------|
| Sign CLI (`shortcuts sign`) | `[x]` 20/20 core OK |
| Import UI (Return + verify `shortcuts list`) | `[x]` core OK (y compris les 4 manquants) |
| Run headless non-interactif | `[~]` 10 OK / 2 FAIL |
| Interactif (ask/menu/list) | `[ ]` skip volontaire |
| Network (weather/url/download) | `[ ]` skip volontaire |
| Community import | `[ ]` pas encore |
| Rapport machine-readable | `[ ]` seulement TSV runs |
| Skill version 1.9.0 attestation | `[ ]` pas bump |

**FAIL connus (P0 qualité golden)**

1. `examples/06-conditional` — Run FAIL : *Choisissez une valeur pour chaque paramètre de cette action.*
2. `palette/06-dictionary` — Run FAIL : *action introuvable*.

---

## Phase A — Qualité goldens (P0)

Objectif : zéro FAIL non documenté sur le set auto-run ; les FAIL restants sont soit corrigés soit classés *interactive/network* avec fixture.

### A1. Fix `examples/06-conditional` **P0**

- [ ] Reproduire : `shortcuts run 06-conditional_signed` → capturer message + screenshot
- [ ] Exporter un If/Else minimal depuis Raccourcis (même logique) via UI
- [ ] `./scripts/extract_shortcut.sh` sur l’export → diff vs `templates/examples/06-conditional.shortcut.xml`
- [ ] Corriger paramètres manquants (`WFInput`, conditions, `WFControlFlowMode`, UUIDs, `attachmentsByRange`)
- [ ] `./scripts/validate.sh` + grammar strict au vert
- [ ] Re-sign + `import_shortcut_ui.sh` + `shortcuts run` → **OK**
- [ ] Mettre à jour ligne MATRIX (`FAIL` → `OK`) + note “fixed vs export”

**DoD :** `shortcuts run 06-conditional_signed` exit 0 sur macOS 26.5 ; MATRIX Run=OK.

### A2. Fix `palette/06-dictionary` **P0**

- [ ] Reproduire le “action introuvable” (quel `WFWorkflowActionIdentifier` ?)
- [ ] Vérifier `dictionary` + `getdictionaryvalue` dans `data/wf_actions.json` / macOS 26
- [ ] Rebuild golden minimal : dictionary → get value → show result (export réel si besoin)
- [ ] Re-sign / import / run → **OK**
- [ ] Mettre à jour `STARTER_PALETTE.md` si le schéma change
- [ ] MATRIX Run=OK

**DoD :** run headless OK ; aucun ID d’action inconnu sur macOS 26.

### A3. Audit rapide des autres goldens “OK import / run skip” **P1**

Pour chaque golden skippé, décider une case MATRIX explicite :

| Golden | Décision cible | Action |
|--------|----------------|--------|
| `02-ask-input` | headless via `--input-path` **ou** `Run=UI` | [ ] fixture texte |
| `03-ask-llm` | `Run=ENV` (Apple Intelligence) | [ ] documenter prérequis |
| `04-menu` | `Run=UI` ou input simulé | [ ] décider |
| `05-weather-ai` | `Run=NET` | [ ] `--include-network` une fois |
| `palette/01-ask` | comme ask-input | [ ] |
| `palette/04-url-open` | `Run=NET` / smoke | [ ] |
| `palette/08-downloadurl` | `Run=NET` | [ ] |
| `palette/11-choosefromlist` | input list fixture | [ ] |

**DoD :** aucune case Run vide sans légende (`—` doit renvoyer à une catégorie : UI / NET / ENV).

---

## Phase B — Durcir l’automation import/run (P0→P1)

### B1. Journal d’import structuré **P1**

- [ ] `fixtures/attested/runs/import_report.tsv` (ou `.jsonl`)
- [ ] Colonnes : `name`, `method` (`return`|`ax`|`green`|`skip`), `ms`, `result`, `error`
- [ ] Brancher depuis `import_shortcut_ui.sh`

**DoD :** un run `--import-ui` produit le rapport ; MATRIX peut être prérempli depuis le fichier.

### B2. Rapport JSON unique **P1**

- [ ] `fixtures/attested/results.json` aggregant hash / sign / import / run
- [ ] Schéma minimal documenté dans `ATTEST_AUTOMATION.md`
- [ ] `attest_local.sh --auto` écrit ce fichier en fin de boucle
- [ ] Exit code ≠ 0 si FAIL non whiteliste

**DoD :** un agent peut lire `results.json` sans parser la MATRIX markdown.

### B3. Screenshots on FAIL **P1**

- [ ] Sur FAIL import ou run : `screencapture` → `fixtures/attested/runs/<name>-fail.png`
- [ ] Documenter besoin Screen Recording
- [ ] Gitignore les PNG (comme les runs) **ou** dossier `runs/` déjà ignoré

**DoD :** chaque FAIL laisse une image + message stderr.

### B4. Améliorer `--click-green` **P2**

- [ ] Couleur réelle observée `(60, 132, 41)` + tolérance
- [ ] Restreindre au bbox des fenêtres Shortcuts `name=""`
- [ ] Gérer scale Retina (points vs pixels) de façon déterministe (`system_profiler` / `backingScaleFactor`)
- [ ] Ne l’utiliser qu’en fallback si Return n’a pas importé sous 2–3 s

**DoD :** sur une sheet fraîche, `--click-green` seul (sans Return) importe au moins 1 golden de test.

### B5. Sheets secondaires **P1**

- [ ] Détecter dialogues “non fiable” / “Add Untrusted” / permissions
- [ ] Séquence : Return → si pas listé, clics AX nommés → Escape si sheet parasite → retry open
- [ ] Timeout configurable déjà présent : exposer `--timeout` dans `attest_local.sh`

**DoD :** import d’un golden “anyone” + un “people-who-know-me” documenté.

### B6. Idempotence / cleanup **P2**

- [ ] Option `--reimport` : si déjà dans `shortcuts list`, skip **ou** supprimer puis réimporter (doc risque)
- [ ] Ne jamais supprimer de raccourcis hors préfixe `*_signed` / dossier attest
- [ ] Documenter le cleanup manuel dans Shortcuts

**DoD :** 2× `--auto` d’affilée = SKIP imports, runs stables, pas de doublons.

### B7. Preflight UX **P1**

- [ ] `check_shortcuts_automation.sh` ouvre les panes Privacy si FAIL AX/Screen
- [ ] Message FR+EN clair
- [ ] Option `--json` pour agents

**DoD :** un nouvel agent local comprend en ≤30 s quoi cocher.

---

## Phase C — Couverture attestation (P0 pour 10/10)

### C1. Community (≥2) **P0**

- [ ] `./scripts/attest_local.sh --import-ui --all` (ou subset)
- [ ] Au moins **2** community : Import=OK dans MATRIX  
  Cibles faciles : `09-url-cleaner`, `11-invert-names` (éviter d’abord electricity/network lourd)
- [ ] Noter Run si headless possible, sinon Import-only OK selon critères pass

**DoD :** cases community remplies ; checkbox MATRIX “≥2 community” cochée.

### C2. Network pass optionnelle **P2**

- [ ] `./scripts/run_shortcut_attest.sh --include-network`
- [ ] Documenter flakiness (réseau, localisation weather)
- [ ] MATRIX notes NET=OK/FAIL

### C3. Interactif headless **P1**

- [ ] Créer `fixtures/attested/inputs/` :
  - [ ] `ask-input.txt`
  - [ ] `choosefromlist.txt` (si applicable)
- [ ] Brancher `shortcuts run NAME --input-path …`
- [ ] Étendre `run_shortcut_attest.sh --with-inputs`

**DoD :** au moins `02-ask-input` et `palette/01-ask` passent en headless **ou** sont explicitement `Run=UI-only`.

### C4. iOS attestation (optionnel 10/10+) **P2**

- [ ] AirDrop / iCloud d’un signed `anyone`
- [ ] 1–2 lignes MATRIX colonne iOS
- [ ] Pas bloquant si hors scope Mac-first

---

## Phase D — Intégration skill / docs / release (P0 clôture)

### D1. MATRIX complète **P0**

- [ ] Toutes lignes core Sign/Import remplies
- [ ] Runs : OK / FAIL documenté / catégorie skip
- [ ] Hashes collés + `hashes.sha256` présent
- [ ] Machine / macOS / date / attestor OK
- [ ] Cocher pass criteria (sauf bump version tant que FAIL P0 ouverts)

### D2. Bump 1.9.0 **P0** (après A1+A2+C1+D1)

- [ ] `SKILL.md` `version: 1.9.0`
- [ ] CHANGELOG : `Attested on macOS 26.5.2 (MacStudio-de-paul) — sign/import/run automation`
- [ ] Mention des 2 fixes conditional/dictionary
- [ ] Mettre à jour `ROADMAP_10.md` B3 → Done

**DoD :** tag/release notes alignées ; pas de mentir sur iOS si non testé.

### D3. Docs skill agent **P1**

- [ ] `SKILL.md` : section courte “Local Mac only for --auto”
- [ ] `ATTEST_AUTOMATION.md` : playbook agent (déjà amorcé) + troubleshooting table
- [ ] `LOCAL_FINALIZE.md` : remplacer tout chemin “manuel only” restant
- [ ] `FAILURE_MODES.md` : ajouter modes “import sheet”, “action introuvable”, “paramètre manquant”

### D4. Git hygiene **P0**

- [ ] Ne jamais committer `*_signed.shortcut` /tmp
- [ ] `fixtures/attested/runs/` gitignored (vérifier)
- [ ] Commit : `MATRIX.md`, `hashes.sha256`, scripts automation, docs
- [ ] Push branche + merge PR #1 quand critères pass OK

### D5. CI (ne pas casser Linux) **P1**

- [ ] CI continue de skipper sign/import (Darwin-only scripts `bash -n` ok)
- [ ] Ajouter job optionnel `bash -n scripts/*.sh` si pas déjà
- [ ] Pas d’appel `shortcuts` dans GitHub Actions

---

## Phase E — Roadmap skill élargie (hors attestation stricte) **P2**

Reporté de [`ROADMAP_10.md`](ROADMAP_10.md) — faire après 1.9.0 :

- [ ] **B6** `SKILL.en.md` + `OUTPUT_NAMES.md`
- [ ] **B7** Golden Share Sheet / ImportQuestions (`09-share-sheet-input`)
- [ ] **B8** Locally : attested golden **ou** design-only clair (stub déjà honnête)
- [ ] Palette 12 → 16–20 (actions power manquantes)
- [ ] Plus de community depuis `data/external/*.index.jsonl`

---

## Phase F — Expérimental “computer use” (P2, ne pas bloquer 1.9.0)

Uniquement si Return/AX saturés :

- [ ] Driver souris CGEvent (PyObjC / Swift) avec Screen Recording
- [ ] OCR léger (Vision.framework) pour lire “Ajouter ce raccourci”
- [ ] **Pas** de stream vidéo continu
- [ ] Feature-flag `ATTEST_UI_VISION=1`

**DoD expérimental :** batche import 5 goldens sans Return, taux ≥ 80 %. Sinon abandon documenté.

---

## Ordre d’exécution recommandé (sprint)

```text
1. A1 conditional fix
2. A2 dictionary fix
3. B1 + B2 rapports (TSV/JSON)
4. C1 community ×2 import
5. C3 inputs headless (ask) si rapide
6. D1 MATRIX + D2 bump 1.9.0 + D4 commit/PR
7. B3 screenshots FAIL, B5 sheets, B7 preflight
8. E* et F* ensuite
```

### Commandes “boucle quotidienne”

```bash
./scripts/check_shortcuts_automation.sh
./scripts/validate.sh
./scripts/attest_local.sh --auto
# après fixes goldens :
./scripts/attest_local.sh --import-ui --run
./scripts/attest_local.sh --import-ui --all   # community
cat fixtures/attested/runs/run_report.tsv
```

---

## Checklist “Definition of Done — skill 10/10 Mac”

- [ ] `validate.sh` vert
- [ ] Core examples 01–08 : Sign OK, Import OK, Run OK **ou** FAIL documenté + golden corrigé (plus de FAIL silencieux)
- [ ] Palette 01–12 : Sign OK, Import OK ; Run OK ou skip catégorisé
- [ ] ≥2 community Import OK
- [ ] Automation scripts documentés + `ATTEST_AUTOMATION.md` à jour
- [ ] `results.json` ou TSV runs + MATRIX cohérents
- [ ] `SKILL.md` 1.9.0 + CHANGELOG attestation
- [ ] PR mergeable, pas de binaires signed dans git

---

## Anti-checklist (ne pas faire)

- [ ] Ne pas promettre import/run depuis un **Cloud Agent Linux**
- [ ] Ne pas automatiser des clics souris “aveugles” sans fallback Return
- [ ] Ne pas committer exports personnels / signed binaries
- [ ] Ne pas bump 1.9.0 tant que A1/A2 sont encore FAIL sans fix
- [ ] Ne pas élargir le scope iOS avant la clôture Mac

---

## Suivi rapide (cocher ici au fil de l’eau)

| ID | Titre | P | Owner | Status |
|----|-------|---|-------|--------|
| A1 | Fix 06-conditional | P0 | | [x] |
| A2 | Fix 06-dictionary | P0 | | [x] |
| A3 | Classifier skips Run | P1 | | [x] |
| B1 | import_report | P1 | | [ ] |
| B2 | results.json | P1 | | [ ] |
| B3 | screenshot on FAIL | P1 | | [ ] |
| B4 | click-green robuste | P2 | | [ ] |
| B5 | sheets secondaires | P1 | | [ ] |
| B6 | idempotence | P2 | | [ ] |
| B7 | preflight UX | P1 | | [ ] |
| C1 | community ×2 | P0 | | [x] |
| C2 | network pass | P2 | | [ ] |
| C3 | inputs headless | P1 | | [ ] |
| C4 | iOS sample | P2 | | [ ] |
| D1 | MATRIX complete | P0 | | [x] |
| D2 | bump 1.9.0 | P0 | | [x] |
| D3 | docs agent | P1 | | [~] |
| D4 | git/PR | P0 | | [ ] |
| D5 | CI Darwin-safe | P1 | | [ ] |
| E* | roadmap élargie | P2 | | [ ] |
| F* | vision expérimentale | P2 | | [ ] |
