# Checklist — prochains pas (attestation + skill 10/10)

> **Tracks actifs (2026-07-26) :**  
> • Linux clos → [`LINUX_10_CHECKLIST.md`](LINUX_10_CHECKLIST.md)  
> • Mackasten paper MVP clos → [`MACKASTEN_CHECKLIST.md`](MACKASTEN_CHECKLIST.md)  
> • Mackasten agent track (MCP / market) → [`MACKASTEN_AGENT_CHECKLIST.md`](MACKASTEN_AGENT_CHECKLIST.md)  
> • **Mac restant → [`MAC_10_CHECKLIST.md`](MAC_10_CHECKLIST.md)** (source of truth device)  
> Ce fichier reste l’historique détaillé ; le suivi Mac court est dans `MAC_10_CHECKLIST.md`.

Dernière màj : **2026-07-26** (Linux 10/10 + Mackasten paper + Mac baseline).  
Branche de travail : `cursor/horizon-app-and-improvements-df7d`.

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

Liens : [`ATTEST_AUTOMATION.md`](ATTEST_AUTOMATION.md) · [`../fixtures/attested/MATRIX.md`](../fixtures/attested/MATRIX.md) · [`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md) · [`MACKASTEN_CHECKLIST.md`](MACKASTEN_CHECKLIST.md) · [`MACKASTEN_AGENT_CHECKLIST.md`](MACKASTEN_AGENT_CHECKLIST.md) · [`ROADMAP_10.md`](ROADMAP_10.md) · [`../LOCAL_FINALIZE.md`](../LOCAL_FINALIZE.md)


---

## État actuel (baseline 2026-07-26, post max-Mac)

| Zone | État |
|------|------|
| Sign CLI (`shortcuts sign`) | `[x]` core OK |
| Import UI (Return + verify `shortcuts list`) | `[x]` core + 2 community |
| Run headless non-interactif | `[x]` OK (aliases v2/fixed when needed) |
| Ask headless (`--with-inputs`) | `[x]` `02-ask-input`, `palette/01-ask` |
| Network (weather/url/download) | `[ ]` skip volontaire (NET) |
| Community import | `[x]` ≥2 |
| Rapport machine-readable | `[x]` `results.json` + TSV |
| Skill version attestation | `[x]` 1.10.0 |

**FAIL connus (P0 qualité golden):** aucun (corrigés).

---

## Phase A — Qualité goldens (P0)

Objectif : zéro FAIL non documenté sur le set auto-run ; les FAIL restants sont soit corrigés soit classés *interactive/network* avec fixture.

### A1. Fix `examples/06-conditional` **P0**

- [x] Reproduire / corriger golden (If + Variable wrapper)
- [x] `./scripts/validate.sh` + grammar strict au vert
- [x] Re-sign + import + `shortcuts run` → **OK** (alias `06-conditional-v2_signed`)
- [x] MATRIX Run=OK

**DoD :** `shortcuts run 06-conditional-v2_signed` exit 0 sur macOS 26.5 ; MATRIX Run=OK.

### A2. Fix `palette/06-dictionary` **P0**

- [x] Remplacer legacy `getdictionaryvalue` → `getvalueforkey` (+ SSOT)
- [x] Re-sign / import / run → **OK** (alias `06-dictionary-fixed_signed`)
- [x] MATRIX Run=OK

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

- [x] `fixtures/attested/results.json` aggregant hash / sign / import / run
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

- [x] Détecter dialogues “non fiable” / “Add Untrusted” / permissions (AX name list EN+FR)
- [x] Séquence : Return → AX → Escape si sheet parasite → retry (`import_shortcut_ui.sh`)
- [x] Timeout configurable : `--timeout` dans `attest_local.sh` + import UI
- [ ] Documenter import “people-who-know-me” sur Mac (manuel)

**DoD :** import d’un golden “anyone” + un “people-who-know-me” documenté.

### B6. Idempotence / cleanup **P2**

- [x] Option `--force` : réimporter même si déjà dans `shortcuts list`
- [~] Deux `--auto` d’affilée = SKIP imports (déjà) ; cleanup manuel documenté
- [ ] Ne jamais supprimer de raccourcis hors préfixe `*_signed` / dossier attest

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

- [x] **B6** `SKILL.en.md` + `OUTPUT_NAMES.md`
- [x] **B7** Golden Share Sheet / ImportQuestions (`09-share-sheet-input`)
- [x] **B8** Locally : **abandonné** → [`MACKASTEN.md`](MACKASTEN.md) (app / Siri / marketplace)
- [x] Palette 12 → 16 (notification, number, openapp, speaktext)
- [ ] Plus de community depuis `data/external/*.index.jsonl`
- [ ] Mackasten companion app (hors ce repo) — voir `MACKASTEN.md`

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
- [x] `results.json` ou TSV runs + MATRIX cohérents
- [x] `SKILL.md` 1.10.0 + CHANGELOG attestation / parity
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
| B1 | import_report | P1 | | [x] |
| B2 | results.json | P1 | | [x] |
| B3 | screenshot on FAIL | P1 | | [x] |
| B4 | click-green robuste | P2 | | [~] tolérance CTA resserrée |
| B5 | sheets secondaires | P1 | | [x] AX+Escape |
| B6 | idempotence | P2 | | [x] `--force` + SKIP |
| B7 | preflight UX | P1 | | [x] + `--json` |
| C1 | community ×2 | P0 | | [x] |
| C2 | network pass | P2 | | [~] notes + MATRIX |
| C3 | inputs headless | P1 | | [x] |
| C4 | iOS sample | P2 | | [ ] _(skipped for Mac-max)_ |
| D1 | MATRIX complete | P0 | | [x] |
| D2 | bump 1.9.0 | P0 | | [x] |
| D3 | docs agent | P1 | | [x] |
| D4 | git/PR | P0 | | [x] |
| D5 | CI Darwin-safe | P1 | | [x] + selftest/craig/shellcheck |
| E* | roadmap élargie | P2 | | [x] Locally→Mackasten ; palette 16 |
| F* | vision expérimentale | P2 | | [ ] |
