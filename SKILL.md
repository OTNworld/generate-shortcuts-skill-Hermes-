---
name: shortcuts-generator
description: >
  Use when the user wants to create, inspect, modify, or import a macOS/iOS
  Shortcut. Covers generating valid `.shortcut` files from plist XML,
  signing them for import, and understanding the Shortcuts action grammar:
  WF*Actions, AppIntents, variables, and control flow. Also covers bridging
  workflows to external apps like Obsidian-vault-based prompting and local
  inference apps on iOS/macOS.
version: 1.3.0
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
- pour les starters/projets : note dans le vault `Projets/<nom>/` avec idée, plan, starter, tests iOS, assets, et workflow de délégation si applicable

## Convention projet Obsidian

Lorsque le skill génère un starter/document lié à un projet, utiliser la structure suivante dans le vault iCloud/Obsidian :

- `Projets/<Nom du projet>/index.md` comme fiche projet
- `idée/` — concepts, cas d’usage, preuves
- `plans/` — plans d’implémentation
- `starters/` — starters/raccourcis `.shortcut`
- `templates/` — templates de génération/docs
- `assets/` — médias, captures, preuves iOS
- Workflow de délégation global : `Projets/delegation-workflow.md`

Règles :
- Ranger les médias dans `assets/`, jamais à la racine du projet.
- Lier les fichiers membres depuis `index.md` et fiche `idée/`.
- Mettre à jour la Daily avec les chemins et les liens travaillés.

## Starters / templates projet

- `templates/locally-obsidian.shortcut.xml` : starter **Locally → Obsidian**
- workflow cible : `Share Sheet → Ask → GetText → Demander à Locally AI → Choose menu → Show/Copy/Save/Append`
- branches recommandées : `Afficher`, `Copier`, `Nouvelle note AI`, `Append Daily`, `Append Inbox`
- point d’attention iOS : `obsidian://open` après sauvegarde iCloud si l’app est installée

## Étapes

1. **Collecte** : demander le nom du raccourci, les entrées, les actions souhaitées et l’ordre logique.
2. **Choix des actions** : sélectionner les identifiants dans `references/ACTIONS.md` et `references/APPINTENTS.md`.
3. **Génération des UUIDs** : un UUID par action productrice de sortie, au format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` en majuscules.
4. **Construction du plist** : suivre `references/PLIST_FORMAT.md` et `references/PARAMETER_TYPES.md`.
5. **Chaînage** : câbler les sorties vers entrées via `attachmentsByRange` et U+FFFC, voir `references/VARIABLES.md`.
6. **Flux de contrôle** : Repeat/If/Choose from Menu selon `references/CONTROL_FLOW.md`.
7. **Validation rapide** : cohérence des UUIDs, types `<integer>` pour `WFControlFlowMode`, placeholder `￼` bien présent.
8. **Signature** : exécuter la commande de signature adéquate, voir section Signing.
9. **Import** : expliquer la marche à suivre si besoin.

## Syntaxe courte

- Identifiant d’action : `is.workflow.actions.<name>` ou intent.
- Paramètres : `WFWorkflowActionParameters`.
- Référence de sortie : `OutputUUID` + `attachmentsByRange` + `￼`.
- Contrôle de flux : `GroupingIdentifier` + `WFControlFlowMode` `0/1/2`.

## Règles dures

- UUIDs en majuscules uniquement.
- `WFControlFlowMode` est un `<integer>`, jamais un string.
- Clés de range au format `{position, length}`.
- Le caractère de marque de variable est `￼` (U+FFFC), pas un placeholder standard.
- Toute action productrice de sortie doit exposer un UUID.

## Compatibilité macOS / iOS

- Tous les identifiants d’action ne sont pas disponibles sur macOS et iOS simultanément.
- Pour débloquer un import/test sur Mac sans erreur d’action inconnue :
  - éviter `shareextension`, préférer `ask` pour l’entrée texte
  - éviter `appintentexecution` si l’App Intent cible n’est pas disponible sur macOS
- Stratégie de débogage recommandée : exporter un POC minimal fonctionnel depuis l’app Raccourcis, puis comparer son PLIST plutôt que modifier le XML à l’aveugle.

## Limites iOS autorisées

- Pas d’action native documentée pour lire le contenu texte brut d’un `.md` iCloud.
- `documentpicker.open/save` = sélection/sauvegarde fichier.
- `gettextfrompdf` = PDF seulement.
- `shareextension` / `ExtensionInput` = entrée fiabletexte/URL/rich text.
- App Intents comme `Demander à Locally AI` exposent typiquement : `Message`, `Pièce jointe`, `Prompt système`, `Modèle` ; préférer le canal `Message` + `Pièce jointe` plutôt que le presse-papiers.

## Obsidian pont / app locale iOS

- Le vault est source de vérité, mais pas lisible automatiquement en pur iOS par le raccourci sauf App Intent/URL.
- Ordre d’appel à une app locale : App Intent > URL scheme > ouverture d’app + alerte rappel.
- `shareextension` / `ExtensionInput` est valide pour texte/URL/rich text.
- Si l’app cible expose une pièce jointe dans Shortcuts, préférer ce canal à un presse-papiers manuel.

## Modèle cross-app recommandé

Flux générique iOS/documenté :
1. entrée = `ExtensionInput` / `Ask` / presse-papiers
2. composer un prompt texte avec variables et `attachmentsByRange`
3. appeler l’app via intent/URL/`Open App`
4. choisir la branche de sortie : `Show Result` / `Set Clipboard` / sauvegarde iCloud / append fichier
5. pour écriture : utiliser `Open URL` avec `obsidian://...` quand possible

## Références

- `references/PLIST_FORMAT.md` : structure racine.
- `references/ACTIONS.md` : 427 WF*Actions.
- `references/APPINTENTS.md` : 728 AppIntents.
- `references/PARAMETER_TYPES.md` : types et sérialisation.
- `references/VARIABLES.md` : système de variables.
- `references/CONTROL_FLOW.md` : Repeat / Condition / Menu.
- `references/FILTERS.md` : filtres de contenu.
- `references/EXAMPLES.md` : exemples complets.

## Signing Shortcuts

Les `.shortcut` doivent être signés pour être importés.

```bash
# Signer pour tout le monde
shortcuts sign --mode anyone --input <input>.shortcut --output <output>_signed.shortcut

# Signer pour les contacts
shortcuts sign --mode people-who-know-me --input <input>.shortcut --output <output>_signed.shortcut
```

### Signing script utilitaire

Voir aussi `scripts/sign_shortcut.sh` pour un wrapper réutilisable.

### Pipeline de vérification avant publication

Avant toute release/tag/push de ce skill ou d’un projet Shortcuts :

1. Valider la syntaxe XML : `xmllint --noout <fichier>.shortcut`
2. Valider la syntaxe du script de signature : `bash -n scripts/sign_shortcut.sh`
3. Vérifier les tokens critiques dans le plist : `attachmentsByRange` et le caractère `￼` (`U+FFFC`) pour les sorties actions.
4. Si le repo est un skill Hermes avec remote Git, vérifier l’état avant toute opération :
   ```bash
   git status
   git remote -v
   git tag -l
   ```
5. Avant un commit/tag/push, comparer HEAD local et distant :
   ```bash
   git rev-parse HEAD
   git ls-remote origin refs/heads/main
   git ls-remote origin refs/tags/<version>
   ```
6. Une fois le tag créé localement, il se crée à partir du HEAD courant :
   ```bash
   git tag -a <version> -m "<message>"
   ```
   Puis pousser :
   ```bash
   git push origin <version>
   ```

## ⚠️ Avertissement : versions gelées

Certains starters/templates de ce skill représentent des **snapshots gelés**.
- `templates/locally-obsidian.shortcut.xml` est conservé en l’état après `v1.4.0`
- Ne pas modifier ce template sans d’abord analyser le POC exporté `assets/locally-poc-reference.shortcut`
- Compatibilité connue : **iOS OK**, **macOS limité** sur `shareextension` / `appintentexecution`
- Si reprise : repartir du POC plutôt que du template gelé

Cette mention sert d’**alarme** pour éviter des modifications à l’aveugle sur une version figée.
