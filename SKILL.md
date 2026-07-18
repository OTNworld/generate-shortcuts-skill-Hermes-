---
name: shortcuts-generator
description: >
  Use when the user wants to create, inspect, modify, or import a macOS/iOS
  Shortcut. Covers generating valid `.shortcut` files from plist XML,
  signing them for import, and understanding the Shortcuts action grammar:
  WF*Actions, AppIntents, variables, and control flow.
version: 1.2.0
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

Processus :
1. écrire le plist XML dans `<nom>.shortcut`
2. signer avec `shortcuts sign`
3. ouvrir/importer dans **Raccourcis**

## Workflow de sauvegarde

Si la modification est mineure, demander à l’utilisateur s’il veut :
- écraser la version existante
- créer une variante horodatée
- conserver les deux sans tag particulier

Préférer la simplicité sauf consigne contraire explicite.
