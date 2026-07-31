# Mackasten — vision produit finale

**Status:** target architecture (2026-07-27). Runtime app = repo privé `mackasten-iOS`.  
**Seed / skill agent :** ce dossier. **Paper packages :** [`../packages/`](../packages/).

## Thesis

Mackasten est l’**app compagnon** du skill Hermes Shortcuts : là où le skill **écrit /
valide / atteste** des raccourcis, Mackasten **découvre, installe, exécute et
personnalise** des packs — surtout des recettes **local-model** qui restent on-device
quand c’est possible — et les expose à **Siri / App Intents**.

| Couche | Propriétaire | Rôle |
|--------|--------------|------|
| Skill Hermes (public MIT) | `generate-shortcuts-skill-Hermes-` | Grammaire, goldens, validate, sign, attest, manifests `mackasten-package/v1` |
| App Mackasten (privé) | `mackasten-iOS` | UX, confiance, updates, routing modèles, Siri |
| OS Apple | Shortcuts + App Intents + Apple Intelligence | Exécution native des workflows / intents système |

## Utilisateur cible

1. **Auteur** — utilise Hermes + skill pour produire des packages attestés.
2. **Consommateur** — ouvre Mackasten, parcourt la marketplace, installe, lance par UI ou Siri.
3. **Power user** — deep link `hermes-shortcuts://edit` pour revenir éditer dans le skill / IDE.

## Surfaces produit (vision finale)

### 1. Marketplace

- Catalogue issu des manifests fetchés (CI + refresh in-app optionnel).
- Fiches : nom, description, tags, `model_policy`, attestation status, Siri phrases.
- Actions : **Installer** (import Shortcuts), **Exécuter**, **Éditer** (deep link).
- Confiance : afficher `attestation.status` ; ne jamais sur-revendiquer vs MATRIX skill.

### 2. Runtime Shortcuts

- Install via `shortcuts://import-shortcut` (fichier local / URL signée quand dispo).
- Run via `shortcuts://run-shortcut` ou App Intent Mackasten qui délègue.
- Pas de réimplémentation du moteur Shortcuts — Mackasten orchestre.

### 3. Local models / Apple Intelligence

- `ModelRouter` lit `model_policy` du package.
- `none` → pas de modèle.
- `apple-intelligence` / `on-device-preferred` → Foundation Models / Writing Tools ; degrade UI si indisponible (Simulator / device non capable).
- `cloud-allowed` → uniquement packages non `local-*`, avec consentement explicite.

### 4. Siri / App Intents

- Intents **app-owned** : BrowseCatalog, InstallPackage, RunPackage, OpenEditDeepLink.
- `AppShortcutsProvider` alimenté par `siri_phrases` des manifests installés.
- Pas d’IDs App Intent Apple inventés ; watchlist skill = export-diff only.

### 5. Deep link skill bridge

```text
hermes-shortcuts://edit?path=<repo-relative-xml>
```

Résolution : cache Vendor packages → ouvrir feuille « copy path / open in Cursor » ;
sur Mac Catalyst éventuel, handoff IDE. Convention déjà réservée dans le skill.

### 6. Bibliothèque personnelle

- Packages installés (SwiftData) : pin version, last run, favoris.
- Sync iCloud **optionnelle** (phase post-MVP si CloudKit contract respecté).

## Principes de design produit

1. Skill reste **lean MIT** — l’app porte UX + distribution.
2. **Local-first** pour tout SKU `local-*`.
3. **Attestation culture** — UI honnête sur `unattested` / `mac-import` / `mac-run` / `ios-sample`.
4. Une composition claire (pas dashboard clutter) — voir [`references/DESIGN.md`](references/DESIGN.md).
5. iPhone **et** iPad dès le scaffold.

## Hors scope (anti-goals)

- Remplacer l’app Raccourcis d’Apple.
- Marketplace qui push du cloud LLM par défaut sur notes personnelles.
- Implémenter le validateur plist dans l’app (reste dans le skill / CI fetch).
- Goldens Locally → Obsidian.

## Succès (definition of done vision)

Un utilisateur peut : ouvrir Mackasten → voir les 4 packages seed → installer Hello World →
le lancer → invoquer une phrase Siri pour un package local-model **si** le device le
supporte → taper un deep link edit et obtenir un chemin skill actionnable — avec
fetch CI vert sur chaque release app pinée à un tag skill.
