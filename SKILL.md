---
name: shortcuts-generator
description: >
  Use when the user wants to create, inspect, modify, or import a macOS/iOS
  Shortcut. Covers generating valid `.shortcut` files from plist XML,
  signing them for import, and understanding the Shortcuts action grammar:
  WF*Actions, AppIntents, variables, and control flow. Optionally bridges to
  Obsidian vault notes (optional; Locally track abandoned — see MACKASTEN.md).
version: 1.16.0
author: OTNworld fork / Hermes adaptation
license: MIT
platforms: [macos, ios]
metadata:
  hermes:
    tags: [shortcuts, automation, apple, plist, ios, macos]
    related_skills: [obsidian, apple-reminders, imessage]
---

# macOS/iOS Shortcuts Generator

Génère ou corrige des fichiers `.shortcut` exploitables par l’app **Raccourcis** sur macOS/iOS, à partir de XML plist valide. Le skill documente la grammaire des actions et des paramètres ; il ne s’agit pas d’un générateur magique, mais d’un protocole reproductible.

**Carte agent (≤2 min) :** [`references/AGENT_ENTRY.md`](references/AGENT_ENTRY.md)  
**Track Linux 10/10 :** [`references/LINUX_10_CHECKLIST.md`](references/LINUX_10_CHECKLIST.md)  
**Track Mac 10/10 :** [`references/MAC_10_CHECKLIST.md`](references/MAC_10_CHECKLIST.md)  
**Publication:** [`references/RELEASE.md`](references/RELEASE.md) · `./scripts/cut_release.sh` (dry-run)

## Quand utiliser ce skill

- L’utilisateur demande un raccourci, une automatisation Raccourcis, ou un `.shortcut`.
- Il veut créer/modifier/examiner un workflow d’actions Apple Shortcuts.
- Il parle de signature/import de `.shortcut`, variables, UUID, contrôle de flux.

## Livrables attendus

Pour chaque raccourci produit :
- un fichier `.shortcut` XML exportable
- un résumé des actions utilisées
- les UUIDs principaux pour le chaînage
- la commande de signature prête à exécuter
- `./scripts/validate.sh` au vert sur les templates/goldens du repo (et sur le fichier généré si placé sous `templates/`)

Pour les notes de projet Obsidian (optionnel) : voir `references/OBSIDIAN_BRIDGE.md`.

## Starters / templates

- `templates/hello-world.shortcut.xml` : golden minimal **importable** (Get Text → Show Result)
- `templates/examples/` : goldens 01–08 + `community/` (MIT-vendored peers)
- `templates/palette/` : 16 minimal power-action starters
- `templates/shortcut-skeleton.plist` : squelette racine pour génération
- `templates/locally-obsidian.stub.xml` : stub **abandonné** (historique, non importable)
- Mackasten (app / Siri / marketplace) : `references/MACKASTEN.md`
- Écosystème / sources externes : `references/ECOSYSTEM.md` + `data/sources.json`

## Étapes

1. **Collecte** : demander le nom du raccourci, les entrées, les actions souhaitées et l’ordre logique.
2. **Choix des actions** : préférer `references/POWER_ACTIONS.md`, puis IDs dans `data/wf_actions.json` / `references/ACTIONS.md` et `data/appintents.json`.
3. **Génération des UUIDs** : un UUID par action productrice de sortie, au format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` en majuscules hex.
4. **Construction du plist** : suivre `references/PLIST_FORMAT.md` et `references/PARAMETER_TYPES.md`.
5. **Chaînage** : câbler les sorties vers entrées via `attachmentsByRange` et U+FFFC, voir `references/VARIABLES.md`.
6. **Flux de contrôle** : Repeat/If/Choose from Menu selon `references/CONTROL_FLOW.md` + goldens 04/06/07/08.
7. **Validation rapide** : `./scripts/validate.sh` ; checklist `references/FAILURE_MODES.md`.
8. **Signature** : exécuter la commande de signature adéquate, voir section Signing.
9. **Après chaque Write/Edit** d’un plist Shortcuts : `./scripts/validate_on_write.sh <fichier>` (obligatoire).
   Si échec mécanique (UUID minuscules / `WFControlFlowMode` en string) : `./scripts/validate_on_write.sh --fix <fichier>` (Craig Loop lite).
10. **Remix** (fichier existant) : `references/REMIX.md` + `python3 scripts/remix_shortcut.py` — ne pas régénérer tout le XML.
11. **Import / attestation Mac** : sur un agent **local** macOS, préférer
   `./scripts/attest_local.sh --auto` (sign → import UI → run). Détails :
   `references/ATTEST_AUTOMATION.md`. Ne pas promettre l’import depuis un Cloud Agent Linux.

## Syntaxe courte

- Identifiant d’action : `is.workflow.actions.<name>` ou intent.
- Paramètres : `WFWorkflowActionParameters`.
- Référence de sortie : `OutputUUID` + `attachmentsByRange` + `￼`.
- Contrôle de flux : `GroupingIdentifier` + `WFControlFlowMode` `0/1/2`.
- `OutputName` : toujours les libellés **anglais** Shortcuts (`Text`, `Provided Input`, `Response`, …).

## Règles dures

- UUIDs en majuscules hex uniquement (`0-9A-F`).
- `WFControlFlowMode` est un `<integer>`, jamais un string.
- Clés de range au format `{position, length}`.
- Le caractère de marque de variable est `￼` (U+FFFC), pas un placeholder standard.
- Toute action productrice de sortie doit exposer un UUID.
- Ne jamais utiliser `is.workflow.actions.savefile` → `documentpicker.save`.

## Compatibilité macOS / iOS

Voir `references/PLATFORM_MATRIX.md` pour les ~actions prioritaires.

- Pour débloquer un import/test sur Mac sans erreur d’action inconnue :
  - éviter `shareextension`, préférer `ask` pour l’entrée texte
  - éviter `appintentexecution` si l’App Intent cible n’est pas disponible sur macOS
- Stratégie de débogage : exporter un POC minimal depuis Raccourcis, puis comparer le PLIST.

## Limites iOS autorisées

Sur iOS, les limites acceptables pour un premier jet sont :
- permissions (Photos, Localisation, Réseau)
- disponibilité Apple Intelligence pour `askllm`
- apps tierces absentes (Obsidian, Locally, …)

## Références

- `references/PLIST_FORMAT.md` : structure racine.
- `references/ACTIONS.md` : 446 WF*Actions.
- `references/POWER_ACTIONS.md` : schémas des 25 actions prioritaires.
- `references/STARTER_PALETTE.md` : index des XML palette.
- `references/APPINTENTS.md` : 168 AppIntents (curated subset).
- `references/PARAMETER_TYPES.md` : types et sérialisation.
- `references/VARIABLES.md` : système de variables.
- `references/CONTROL_FLOW.md` : Repeat / Condition / Menu.
- `references/FILTERS.md` : filtres de contenu.
- `references/EXAMPLES.md` : index des goldens.
- `references/FAILURE_MODES.md` : playbook d’échecs agent.
- `references/PLATFORM_MATRIX.md` : disponibilité iOS/macOS.
- `references/OBSIDIAN_BRIDGE.md` : conventions vault (optionnel).
- `references/URL_SCHEMES.md` : `shortcuts://` et x-callback-url.
- `references/ATTEST_AUTOMATION.md` : import UI + run automatisés (macOS local).
- `references/NEXT_CHECKLIST.md` : checklist prochains pas vers 10/10.
- `references/COMPETITIVE_CHECKLIST.md` : parité auteur vs Viticci (remix / validate-on-write / corpus), lean.
- `references/REMIX.md` : protocole remix / diff chirurgical.
- `references/OUTPUT_NAMES.md` : libellés `OutputName` anglais.
- `SKILL.en.md` : protocole agent en anglais.
- `references/ECOSYSTEM.md` : repos / corpus externes centralisés.
- `references/ROADMAP_10.md` : suite vers 10/10.
- `data/wf_actions.json` / `data/appintents.json` : SSOT catalogues.
- `data/sources.json` : registre des sources externes.

## Signing Shortcuts

Les `.shortcut` doivent être signés pour être importés.

```bash
# Signer pour tout le monde
shortcuts sign --mode anyone --input <input>.shortcut --output <output>_signed.shortcut

# Signer pour les contacts
shortcuts sign --mode people-who-know-me --input <input>.shortcut --output <output>_signed.shortcut
```

### Signing script utilitaire

Voir aussi `scripts/sign_shortcut.sh` pour un wrapper réutilisable
(modes `anyone` | `people-who-know-me`, contrôle de présence de `shortcuts`,
`xmllint` optionnel avant signature — `SKIP_XMLLINT=1` pour les plists binaires).

Validation du repo : `./scripts/validate.sh` (également exécuté en CI).

Extraction d’exports : `./scripts/extract_shortcut.sh` (plutil/plistlib).

### Attestation automatisée (macOS local)

```bash
./scripts/check_shortcuts_automation.sh   # Accessibilité (+ screen optionnel)
./scripts/attest_local.sh --auto          # sign + import UI + run
# ./scripts/attest_local.sh --auto --all
```

- Import UI : `scripts/import_shortcut_ui.sh` (Return / AX / `--click-green` / report TSV)
- Runs : `scripts/run_shortcut_attest.sh --with-inputs` → TSV + optional FAIL PNG
- Aggregate : `scripts/write_attest_results.sh` → `fixtures/attested/results.json`
- Doc : `references/ATTEST_AUTOMATION.md`, handoff `fixtures/attested/MAC_HANDOFF.md`

### Pipeline de vérification avant publication

Avant toute release/tag/push de ce skill ou d’un projet Shortcuts :

1. Exécuter le validateur du repo : `./scripts/validate.sh`
2. Valider la syntaxe XML d’un fichier isolé si besoin : `xmllint --noout <fichier>.shortcut`
3. Valider la syntaxe des scripts : `bash -n scripts/*.sh`
4. Vérifier les tokens critiques dans le plist : `attachmentsByRange` et le caractère `￼` (`U+FFFC`) pour les sorties actions.
5. Si le repo est un skill Hermes avec remote Git, vérifier l’état avant toute opération :
   ```bash
   git status
   git remote -v
   git tag -l
   ```
6. Avant un commit/tag/push, comparer HEAD local et distant :
   ```bash
   git rev-parse HEAD
   git ls-remote origin refs/heads/main
   git ls-remote origin refs/tags/<version>
   ```
7. Une fois le tag créé localement :
   ```bash
   git tag -a <version> -m "<message>"
   git push origin <version>
   ```

## ⚠️ Avertissement : stubs non importables

- `templates/locally-obsidian.stub.xml` est un stub **abandonné** (non importable).
- Ne pas le signer ni l’importer dans Raccourcis ; ne pas rouvrir le track Locally.
- Pour un raccourci minimal valide, utiliser `templates/examples/` ou `templates/hello-world.shortcut.xml`.
- Direction produit (app / Siri / marketplace modèles locaux) : `references/MACKASTEN.md`.
- Bridge Obsidian optionnel : `references/OBSIDIAN_BRIDGE.md`.
