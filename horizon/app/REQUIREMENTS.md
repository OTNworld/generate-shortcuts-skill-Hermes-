# Horizon iOS — requirements (oneshot SSOT)

Traceability IDs `H-F*` / `H-N*` / `H-C*` are referenced by [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md)
and [`CHECKLIST.md`](CHECKLIST.md).

## Functional

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| H-F1 | Afficher un catalogue de packages `horizon-package/v1` | P0 | Seed : 4 packages skill |
| H-F2 | Détail package : metadata, policy, attestation, phrases | P0 | |
| H-F3 | Installer le shortcut primary dans l’app Raccourcis | P0 | URL scheme / share sheet |
| H-F4 | Exécuter un package installé | P0 | `run-shortcut` ou intent |
| H-F5 | Enregistrer URL scheme `hermes-shortcuts` | P0 | `edit?path=` |
| H-F6 | Persister bibliothèque installée (SwiftData) | P0 | local only MVP |
| H-F7 | App Intent InstallPackage | P0 | |
| H-F8 | App Intent RunPackage | P0 | |
| H-F9 | AppShortcutsProvider depuis `siri_phrases` | P1 | device real Siri |
| H-F10 | ModelRouter + UI degrade si IA indisponible | P1 | |
| H-F11 | BrowseCatalog App Intent | P1 | |
| H-F12 | Favoris + last-run | P2 | |
| H-F13 | Refresh catalogue depuis remote pin (in-app) | P2 | CI reste source release |
| H-F14 | Import signed `.shortcut` quand attestation mac-run | P2 | Mac tooling adjacent |
| H-F15 | iCloud sync bibliothèque | P3 | post-MVP |
| H-F16 | Éditeur in-app de plist | P3 | anti-goal near-term ; deep link only |

## Non-functional

| ID | Requirement | Priority |
|----|-------------|----------|
| H-N1 | Swift 6 / SwiftUI / iOS 26 SDK ; deployment ≥ iOS 18 | P0 |
| H-N2 | XcodeGen `project.yml` (pas de `.xcodeproj` hand-edited comme SSOT) | P0 |
| H-N3 | Fetch CI pin SHA/tag skill ; artifact `Vendor/SkillPackages/` | P0 |
| H-N4 | Validate JSON Schema `horizon-package/v1` après fetch | P0 |
| H-N5 | Pas de secrets cloud dans Info.plist / packages | P0 |
| H-N6 | Privacy manifest `PrivacyInfo.xcprivacy` | P0 |
| H-N7 | Accessibilité VoiceOver sur browse/detail/CTA | P1 |
| H-N8 | iPhone + iPad layouts | P0 |
| H-N9 | Linux CI : fetch + schema + unit tests purs (pas xcodebuild) | P0 |
| H-N10 | Mac CI / local : `xcodebuild test` Simulator | P1 |
| H-N11 | Bundle ID `com.otnworld.horizon` (ajustable au bootstrap) | P0 |
| H-N12 | Repo GitHub **privé** | P0 |

## Constraints & compliance

| ID | Constraint |
|----|------------|
| H-C1 | Packages `local-*` refuse `cloud-allowed` (même règle que skill checker) |
| H-C2 | Ne pas inventer App Intent Apple identifiers |
| H-C3 | Attestation UI ⊆ {unattested, mac-import, mac-run, ios-sample} |
| H-C4 | Deep link path = repo-relative skill path ; pas d’exécution arbitraire |
| H-C5 | Skill public reste sans binaire app |
| H-C6 | Licences : code app privé ; packages MIT skill respectés + attribution |

## Seed catalog (must work day one)

| Package id | model_policy | Primary shortcut (skill-relative) |
|------------|--------------|-----------------------------------|
| `hello-world` | none | `templates/examples/01-hello-world.shortcut.xml` |
| `clipboard-set` | none | `templates/palette/03-setclipboard.shortcut.xml` |
| `local-ask-llm` | apple-intelligence | `templates/examples/03-ask-llm.shortcut.xml` |
| `local-rewrite` | apple-intelligence | `templates/examples/10-rewrite-text.shortcut.xml` |

## Explicit non-requirements (MVP oneshot)

- Backend Horizon cloud custom
- Compte utilisateur / auth
- Paiements StoreKit
- Remplacer Shortcuts.app
- Attestation device depuis Linux CI
