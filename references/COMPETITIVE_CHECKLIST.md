# Checklist — parité auteur vs peers (Viticci / lean)

Dernière màj : **2026-07-26**  
Objectif : combler le **gap d’expérience auteur** face à [viticci/shortcuts-playground](https://github.com/viticci/shortcuts-playground-plugin) **sans** absorber ~12k lignes ni casser le positionnement Hermes / MIT / attestation Mac.

**Position actuelle (rappel)**

| Axe | Nous | Viticci playground |
|-----|------|--------------------|
| Attestation Mac sign/import/run + `results.json` | **Lead** | Faible / non systématique |
| Corpus goldens | 9 teaching + 16 palette + 10 community | ~19 goldens riches |
| Remix / diff NL sur XML existant | **`remix_shortcut.py` + REMIX.md** | **Lead** (richer agents) |
| Validate-on-write (hooks) | **`validate_on_write.sh`** | PostToolUse + Craig Loop |
| ToolKit / AppIntents profondeur | 442 WF + 168 curated | ToolKit v63+ gated |
| Surface skill | Lean FR + `SKILL.en.md` | Plugin Claude/Codex lourd |
| License posture | MIT + link-not-vendor GPL | MIT plugin |

**Légende :** `[ ]` todo · `[~]` partiel · `[x]` done · **P0/P1/P2** priorité  
**Anti-goal :** ne pas submodule / copier le skill tree Viticci entier (`ECOSYSTEM.md`).

Liens : [`ECOSYSTEM.md`](ECOSYSTEM.md) · [`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md) · [`ROADMAP_10.md`](ROADMAP_10.md) · peer index `data/external/viticci-playground-goldens.index.jsonl`

---

## Principes de design (non négociables)

- [x] Rester **MIT** ; GPL = link only
- [x] Garder `SKILL.md` agent-facing **court** ; détail dans `references/`
- [x] Toute nouvelle feature d’édition doit finir par `./scripts/validate.sh` (+ attest Mac si importable)
- [x] Chaque phase livre un **DoD mesurable** (ci-dessous) avant la suivante
- [x] Préférer **wrappers locaux** (`scripts/`) aux hooks IDE propriétaires quand possible (Hermes + Cursor)

---

## Phase V0 — Cartographie peer (1–2 j)

Comprendre sans copier.

- [x] Lire / noter dans `references/ECOSYSTEM.md` (section “Parity notes”) :
  - [x] Slash commands build vs remix
  - [x] Hook PostToolUse + ce que fait le validator Craig Loop
  - [x] Structure des 19 goldens (tags / gaps vs notre palette)
  - [x] ToolKit snapshot : ce qui est *gated* vs notre `appintents.json`
- [x] Tableau gap → item checklist (mettre à jour ce fichier)
- [x] Décider le **MVP parité** : remix **puis** validate-on-write **puis** +goldens

**DoD V0 :** une page “Parity notes” + ordre d’attaque P0 choisi.

---

## Phase V1 — Remix / diff NL (P0 expérience auteur)

Le plus gros différenciateur Viticci côté *édition*.

### V1.1 Spec agent

- [x] Doc `references/REMIX.md` :
  - Entrée : XML unsigned existant + instruction NL
  - Sortie : XML modifié + résumé des actions touchées
  - Interdits : réécrire tout le fichier si un diff local suffit
  - Toujours re-valider + re-signer
- [x] Ajouter dans `SKILL.md` une étape **Remix** (3–5 lignes) pointant vers `REMIX.md`

### V1.2 Outils

- [x] `scripts/remix_shortcut.py` :
  - [x] `--replace-text` / `--set-name` / `--dry-run` / `--output`
  - [x] Appelle validate via `validate_on_write.sh` in protocol
- [x] Fixture : `fixtures/remix/README.md` (Hello → Bonjour)
- [x] Test : remix → sign → import → `shortcuts run` → `Bonjour!`

### V1.3 Qualité

- [x] Playbook `FAILURE_MODES.md` : remix / validate_on_write
- [x] Scénario remix documenté dans `REMIX.md` + `fixtures/remix/`

**DoD V1 :** un agent local peut remixer un golden teaching en ≤1 tour outillage + validate vert.

---

## Phase V2 — Validate-on-write lean (P0 DX)

Équivalent *léger* du PostToolUse Viticci, portable Hermes/Cursor.

### V2.1 Hook / script unique

- [x] `scripts/validate_on_write.sh <file.shortcut.xml>` :
  - xmllint + grammar strict + IDs ∈ SSOT
  - exit ≠ 0 avec messages actionnables
- [x] Doc agent : “après chaque Write/Edit d’un plist Shortcuts, lancer validate_on_write” (`SKILL.md` étape 9)

### V2.2 Intégrations optionnelles (sans forcer un IDE)

- [x] Hermes / Cursor : mandatory in `SKILL.md`
- [~] CI : déjà `validate.sh` — pas de duplication
- [x] Cursor `.cursor/rules` optionnel (`shortcuts-validate-on-write.mdc`)

### V2.3 Craig Loop *lite* (optionnel P2)

- [x] Boucle max N=3 : validate → fixer erreurs automatiques sûres (UUID case, mode integer) → re-validate
- [x] **Ne pas** auto-fixer la sémantique métier

**DoD V2 :** edit d’un golden volontairement cassé → script rouge ; fix → vert ; documenté pour l’agent.

---

## Phase V3 — Corpus & ToolKit (P1 couverture)

### V3.1 Goldens

- [x] Mapper les 19 Viticci index → gaps vs `templates/`
- [x] Vendor **+3 à +5** MIT goldens (attribution `THIRD_PARTY_NOTICES`) qui couvrent :
  - [x] Share Sheet / ImportQuestions (aussi B7 roadmap)
  - [x] Files / Save (`documentpicker.save` / preview folder)
  - [x] HTTP + JSON (masto-redirect + parse-json-feed)
- [x] Chaque nouveau golden : `validate.sh` + au moins **Import OK** Mac (attest)

### V3.2 AppIntents / catalogues

- [x] Audit : quels intents Viticci “gated” manquent ? → `references/APPINTENTS_GAP.md` (garder curated 168)
- [x] Étendre SSOT **par lots** (+20–40 max) avec `render_refs.py` + counts docs → **442** WF / **168** AppIntents
- [x] `PLATFORM_MATRIX.md` : marquer macOS/iOS/unknown pour les actions des goldens community

### V3.3 Icon / polish

- [~] Doc table `PLIST_FORMAT` (pas de `resolve_icon.sh` clone Viticci)
- [x] Ne pas cloner le resolve-icon Viticci verbatim

**DoD V3 :** ≥8 community **ou** teaching gap list “closed” ; AppIntents count documenté (pas forcément 728).
---

## Phase V4 — Surface agent (P1 UX)

Sans devenir un mega-plugin.

- [x] `SKILL.en.md` (B6) pour audience EN / Cursor market
- [x] `OUTPUT_NAMES.md` (B6) — liste canonique OutputName EN
- [x] Commandes “virtuelles” documentées (pas forcément slash Claude) :
  - [x] `build` → protocole SKILL étapes 1–9
  - [x] `remix` → REMIX.md
  - [x] `attest` → `attest_local.sh --auto`
- [x] Selftest : `scripts/selftest.sh` = validate + grammar + (Darwin) hash-only

**DoD V4 :** un nouvel agent Cursor/Hermes trouve build/remix/attest en ≤2 min de lecture SKILL.

---

## Phase V5 — Attestation leadership (P1 garder l’avance)

Ne pas laisser Viticci rattraper *notre* axe.

- [x] Menu / choose-from-list : skip catégorisé (UI) dans MATRIX
- [x] Network pass optionnelle (`--include-network`) + notes flaky
- [x] `results.json` schema versionné + exemple dans ATTEST_AUTOMATION
- [ ] iOS : 1 ligne MATRIX **quand** device dispo (hors Mac-max)
- [x] Comparer publiquement dans README : “attestation Mac first-class”

**DoD V5 :** README revendique clairement l’avance attestation ; `results.json` cité.

---

## Phase V6 — Packaging & distribution (P2)

- [x] Tag `v1.10.0` quand V1+V2+V3 min done
- [ ] Entrée LobeHub / Cursor skills market (si pertinent) — description différenciante
- [x] Changelog “Parity track” résumé (`CHANGELOG` 1.10.0)
- [x] PR / release notes bilingues FR-EN courte

**DoD V6 :** release publiée + lien ECOSYSTEM à jour.

---

## Ordre d’attaque recommandé

```text
V0 cartographie
 → V1 remix MVP (hello-world)
 → V2 validate_on_write
 → V3 +3 goldens gap + AppIntents batch
 → V4 SKILL.en + selftest
 → V5 garder lead attestation
 → V6 release
```

### MVP “parité ressentie” (minimum viable vs Viticci auteur)

Coche les 4 pour dire “on a comblé le ressenti auteur” sans match feature-for-feature :

- [x] V1 remix hello-world → Bonjour (validate + sign)
- [x] V2 validate_on_write obligatoire dans SKILL
- [x] V3 +3 community/gap goldens Import OK
- [x] V5 README différenciation attestation

---

## Tableau de suivi

| ID | Titre | P | Status |
|----|-------|---|--------|
| V0 | Cartographie peer | P0 | [x] |
| V1 | Remix / diff NL | P0 | [x] MVP |
| V2 | Validate-on-write | P0 | [x] |
| V3 | Corpus + ToolKit batch | P1 | [x] |
| V4 | Surface agent EN/selftest | P1 | [x] |
| V5 | Lead attestation | P1 | [x] |
| V6 | Release packaging | P2 | [x] `v1.10.0` |


---

## Anti-checklist (ne pas faire)

- [ ] Copier `shortcuts-playground` SKILL.md / agents / hooks tels quels
- [ ] Vendor GPL `shortcuts-js`
- [ ] Promettre 728 AppIntents “complets” sans SSOT/CI
- [ ] Sacrifier l’attestation Mac pour coller au marketing Viticci
- [ ] Gonfler `SKILL.md` au-delà d’un protocole agent lisible

---

## Définition de “on a rattrapé”

**Rattrapage auteur (qualité ressentie) :** MVP 4 cases ci-dessus + validate CI toujours vert.  
**Dépassement global :** lead attestation **et** remix **et** validate-on-write — alors rating peer-comparable **≥ Viticci sur Mac-first workflows**, encore derrière sur ToolKit exhaustif (acceptable).
