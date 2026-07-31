---
name: mackasten-ios
description: >
  Use when building, scaffolding, or shipping the Mackasten companion iOS app:
  marketplace for Shortcuts packages, hermes-shortcuts:// deep links, App Intents /
  Siri phrases, on-device / Apple Intelligence model routing, and CI fetch of
  mackasten-package/v1 manifests from the generate-shortcuts-skill-Hermes- skill repo.
  Prefer this skill over generic iOS scaffolding when the product is Mackasten.
version: 0.1.0
author: OTNworld / Hermes
license: MIT (skill docs); app binary repo is private
platforms: [ios, macos]
metadata:
  hermes:
    tags: [mackasten, ios, swiftui, app-intents, shortcuts, marketplace, siri]
    related_skills: [shortcuts-generator, ios-dev, app-intents]
    app_repo: OTNworld/mackasten-iOS
    skill_repo: OTNworld/generate-shortcuts-skill-Hermes-
---

# Mackasten iOS — companion app skill

Protocole agent pour **oneshot** (ou itérer) l’app native **Mackasten** : marketplace
de packages Shortcuts, runtime local-model, Siri / App Intents, deep links vers
l’espace skill.

Ce skill **ne remplace pas** un skill iOS générique : il ancre le produit Mackasten.
Pour le craft SwiftUI / Liquid Glass / Foundation Models, **lire à la demande** les
skills externes indexés dans [`sources.json`](sources.json) (ne pas vendorer les arbres).

**Carte :** [`README.md`](README.md) · Vision [`VISION.md`](VISION.md) · Plan
[`ONESHOT_PLAN.md`](ONESHOT_PLAN.md) · Tests [`CHECKLIST.md`](CHECKLIST.md)

## Quand utiliser ce skill

- Créer ou étendre l’app `mackasten-iOS`.
- Brancher le fetch CI des `mackasten/packages/*/package.json` depuis le skill public.
- Enregistrer `hermes-shortcuts://`, App Intents marketplace, Siri phrases.
- Adapter Apple Intelligence / on-device derrière une policy `model_policy`.

## Livrables attendus (oneshot)

1. Projet Xcode (XcodeGen `project.yml` préféré) — iPhone + iPad.
2. Catalog runtime consommant `Vendor/SkillPackages/` (sortie du fetch CI).
3. UI : browse → détail → install/run (Shortcuts URL / App Intents).
4. URL scheme `hermes-shortcuts://edit?path=…` + handlers App Intent.
5. Couche `ModelRouter` respectant `none | apple-intelligence | on-device-preferred | cloud-allowed`.
6. Suite Swift Testing + checklist Mac/device [`CHECKLIST.md`](CHECKLIST.md).
7. Workflow GitHub Actions : fetch packages @ SHA/tag pin + validate schema.

## Prérequis (dire tout de suite si manquants)

| Besoin | Pourquoi |
|--------|----------|
| macOS + **Xcode 26+** (SDK iOS 26) | Build / Simulator — **pas** sur Cloud Agent Linux |
| Compte Apple Developer | Device + éventuels entitlements |
| Repo privé `OTNworld/mackasten-iOS` | Code app (ce dossier est le seed) |
| Accès lecture au skill public | Fetch CI des manifests + XML |

Si pas de Xcode : scaffolder + docs OK ; **ne pas** prétendre que l’app a tourné.

## Étapes agent (ordre dur)

1. **Lire** `VISION.md` + `REQUIREMENTS.md` + `ARCHITECTURE.md` (ne pas improviser le produit).
2. **Bootstrap repo** si besoin : `REPO_BOOTSTRAP.md`.
3. **Scaffold** SwiftUI per `ONESHOT_PLAN.md` phase A (modules listés dans `ARCHITECTURE.md`).
4. **Fetch CI** : implémenter `scripts/fetch_skill_packages.sh` + pin SHA (`CI_FETCH.md`).
5. **Catalog** : parser `mackasten-package/v1` ; afficher les 4 SKUs seed.
6. **Install/Run** : `shortcuts://import-shortcut` / `run-shortcut` — voir `references/URL_SCHEME.md`.
7. **Deep link** : enregistrer `hermes-shortcuts` ; résoudre `path=` vers skill path ou cache local.
8. **App Intents + Siri** : intents app-owned (Install/Run/Browse) ; phrases depuis manifests.
9. **ModelRouter** : gate Apple Intelligence ; jamais forcer `cloud-allowed` sur `local-*`.
10. **Tests** : cocher `CHECKLIST.md` ; Linux CI = fetch + schema only ; Mac = build + UI.

## Règles dures

- **Ne pas** implémenter l’app binaire dans le repo skill public (sauf seed docs ici).
- **Ne pas** inventer d’App Intent Apple IDs — seulement intents **Mackasten** ou exports vérifiés.
- **Ne pas** revendiquer `mac-run` / attestation marketplace sans MATRIX skill.
- Packages `local-*` : `model_policy` ≠ `cloud-allowed`.
- Fetch CI pinne un **tag ou SHA** du skill — jamais `main` flottant en release.
- Skills iOS externes = **lien + index** ; pas de dump ToolKit / arbres GPL.

## Anti-goals

- Recréer Locally / bridge Obsidian comme cœur produit.
- Marketplace cloud qui exfiltre notes/vault par défaut.
- Vendorer Viticci / ios-dev-skill en entier dans le skill Shortcuts.

## Références (lire à la demande)

- `references/MARKETPLACE.md` — catalogue, install, confiance
- `references/URL_SCHEME.md` — `hermes-shortcuts://` + Shortcuts URLs
- `references/LOCAL_MODELS.md` — policies + Foundation Models
- `references/APP_INTENTS.md` — intents Mackasten + Siri
- `references/TESTING.md` — pyramides Linux / Mac / device
- `references/DESIGN.md` — direction visuelle Mackasten
- Skill packages SSOT : `../packages/` + `../../data/schemas/mackasten-package.v1.json`
- Peer skills : `sources.json`
