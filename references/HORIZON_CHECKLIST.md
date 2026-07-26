# Checklist — horizon (au-delà du plafond Mac)

Dernière màj : **2026-07-26**  
Prérequis : skill **1.10.0** mergé (`main`), MVP Viticci-lean + Craig Loop lite done.  
Contexte rating : **~10 Mac-max** ; prochain gain = **ergonomie agent / visibilité**, pas plus d’attest local.

**Légende :** `[ ]` todo · `[~]` partiel · `[x]` done · **P0/P1/P2**

Liens : [`COMPETITIVE_CHECKLIST.md`](COMPETITIVE_CHECKLIST.md) · [`NEXT_CHECKLIST.md`](NEXT_CHECKLIST.md) · [`ATTEST_AUTOMATION.md`](ATTEST_AUTOMATION.md) · [`ECOSYSTEM.md`](ECOSYSTEM.md)

---

## Positionnement (rappel)

| Couche | État | Notes |
|--------|------|-------|
| Protocole skill | `[x]` | `SKILL.md` + `SKILL.en.md` |
| Utilitaires scripts | `[x]` | `scripts/` — à inventorier / exposer clairement (H0) |
| Preuves Mac | `[x]` | `attest_local.sh --auto` + `results.json` |
| MCP outils agent | `[ ]` | H1 |
| Automations Cursor | `[ ]` | H2 |
| Market listing | `[ ]` | H3 |
| CLI produit à part | `[ ]` | H4 (optionnel) |

**Anti-goal :** ne pas absorber le skill tree Viticci / ToolKit dumps ; ne pas promettre iOS sans device.

---

## H0 — Skill + utilitaires (socle) **P0**

Rendre explicite que le skill **est** protocole + utils.

- [x] Tableau “commandes virtuelles → script” dans `README.md` (build / remix / validate / attest / craig)
- [x] Section courte dans `SKILL.md` : “Utilitaires (ne pas réinventer)”
- [x] Inventaire `scripts/` à jour (1 ligne / script) dans ce fichier ou `README`
- [x] `selftest.sh` mentionné comme gate locale

**DoD H0 :** un nouvel agent trouve validate/remix/attest en ≤1 min sans lire tout COMPETITIVE.

### Inventaire scripts (baseline)

| Script | Rôle |
|--------|------|
| `validate.sh` | CI / gate complète repo |
| `validate_on_write.sh` | Post-edit single file ; `--fix` → Craig Loop lite |
| `craig_loop_lite.py` | Fix mécanique UUID case / mode integer |
| `remix_shortcut.py` | Remix textuel lean |
| `sign_shortcut.sh` | `shortcuts sign` wrapper |
| `attest_local.sh` | Hash / sign / import UI / run / results |
| `import_shortcut_ui.sh` | Import sheet (Return / AX / green) |
| `run_shortcut_attest.sh` | `shortcuts run` + TSV ; `--include-network` |
| `write_attest_results.sh` | Agrège → `results.json` |
| `check_shortcuts_automation.sh` | Préflight Accessibility |
| `check_shortcut_grammar.py` | Grammaire strict |
| `extract_shortcut.sh` | Export → XML |
| `render_refs.py` | Régénère fences ACTIONS/APPINTENTS |
| `selftest.sh` | validate + validate_on_write + hash Darwin |

---

## H1 — MCP (outils agent) **P1**

Exposer les utils comme outils MCP au lieu de “lance ce bash”.

- [x] Spec `references/MCP_SHORTCUTS.md` : outils proposés + args + stdout contract
- [x] Outils min : `shortcuts_validate`, `shortcuts_remix`, `shortcuts_attest_status` (lecture `results.json`)
- [x] Option : `shortcuts_attest_run` (Darwin only ; documenter permissions)
- [x] Impl stub : `mcp/` ou serveur minimal (Node/Python) qui wrappe `scripts/`
- [x] Doc install locale (Cursor MCP settings) — **sans** forcer cloud Linux attest

**DoD H1 :** depuis un chat Cursor avec MCP on, l’agent peut valider un XML **sans** coller la commande bash à la main.

---

## H2 — Automations Cursor **P1**

### Automations (horizon H2)

- [x] Automation : périodique ou on-push → `./scripts/selftest.sh` (toujours) — **doc** dans ATTEST_AUTOMATION (CI validate déjà)
- [~] Automation Mac-only (doc) : `./scripts/attest_local.sh --hash-only` ou `--auto` quand agent local
- [x] Alerte si `fixtures/attested/results.json` `"pass": false` — signal documenté
- [x] Lien / template dans `references/ATTEST_AUTOMATION.md`

**DoD H2 :** une automation documentée (même manuelle au début) pour ne pas laisser la MATRIX pourrir.

---

## H3 — Listing market (visibilité) **P2**

Pas du code — packaging / fiche.

- [x] Blurb différenciant FR + EN (≤280 car. + paragraphe) : **Mac attestation first-class**
- [x] Checklist assets : repo public, `SKILL.md` racine, LICENSE MIT, screenshot MATRIX optionnel
- [x] Cursor skills / marketplace : procédure + brouillon fiche (`references/MARKET_LISTING.md`)
- [ ] LobeHub (ou équivalent) : même blurb + lien GitHub *(compte / publish manuel)*
- [ ] Cocher V6 item “Entrée LobeHub / Cursor skills market” dans `COMPETITIVE_CHECKLIST.md` quand publié

**DoD H3 :** au moins **une** fiche publique ou un `MARKET_LISTING.md` prêt à coller (si compte bloqué, DoD = doc prête).

---

## H4 — CLI produit (optionnel) **P2**

Seulement si H0–H1 saturés et besoin hors-Cursor.

- [ ] Décider nom (`shortcuts-hermes` ?) et scope : thin wrapper des scripts
- [ ] Entry point unique `python -m` ou `bin/` avec sous-commandes validate|remix|attest
- [ ] Skill devient **client** de la CLI (doc), pas duplication de logique
- [ ] **Ne pas** faire d’app GUI

**DoD H4 :** `validate` et `remix` marchent hors Cursor sur le même repo ; skill pointe vers la CLI.

---

## Hors checklist (volontaire)

- [ ] iOS : 1 ligne MATRIX quand device dispo
- [ ] Pass réseau non-flaky (permissions Shortcuts + hosts stables)
- [ ] Batch AppIntents **≤20** seulement si golden réel l’exige (`APPINTENTS_GAP.md`)

---

## Ordre d’attaque

```text
H0 inventaire / README utils
 → H1 MCP spec + stub validate
 → H2 automation selftest
 → H3 market blurb (doc)
 → H4 CLI seulement si besoin
```

### MVP horizon “ressenti agent”

- [x] H0 tableau utils visible
- [x] H1 validate via MCP (ou stub + doc)
- [x] H3 blurb market prêt (même non publié)

---

## Tableau de suivi

| ID | Titre | P | Status |
|----|-------|---|--------|
| H0 | Skill + utils explicites | P0 | [x] |
| H1 | MCP wrappers | P1 | [x] stub |
| H2 | Automations Cursor | P1 | [~] doc |
| H3 | Market listing | P2 | [~] blurb prêt |
| H4 | CLI produit | P2 | [ ] |
