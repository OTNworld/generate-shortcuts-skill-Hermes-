# Horizon iOS — oneshot plan

Goal: a single agent run (on a **Mac with Xcode 26+**, repo privé déjà créé) ships a
buildable app satisfying P0 requirements. Linux Cloud Agents stop after scaffold +
CI fetch scripts + unit tests purs, and hand off Mac gates explicitly.

## Preflight (human, once)

1. Create private repo `OTNworld/horizon-iOS` — [`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md).
2. Grant the coding agent access to that private repo.
3. Confirm Xcode 26+ / Simulator on the machine that will run phases D–F.

## Phase A — Repository skeleton (P0)

**DoD:** `xcodegen` project opens ; empty tabs compile.

| Step | Action | Req |
|------|--------|-----|
| A1 | Copy seed `horizon/app/**` into app repo root (or submodule docs) | — |
| A2 | Add `project.yml` (iOS app + unit test bundle) | H-N2 |
| A3 | Bundle ID `com.otnworld.horizon`, display name Horizon | H-N11 |
| A4 | Register URL type `hermes-shortcuts` | H-F5 |
| A5 | `PrivacyInfo.xcprivacy` stubs for UserDefaults if used | H-N6 |
| A6 | `.gitignore` : `Vendor/SkillPackages/`, `*.xcodeproj` if generated, secrets | — |
| A7 | README app : how to fetch + generate + test | — |

## Phase B — Fetch CI (P0)

**DoD:** `./scripts/fetch_skill_packages.sh` materializes 4 packages ; schema check green.

| Step | Action | Req |
|------|--------|-----|
| B1 | Pin `SKILL_REPO` + `SKILL_REF` (tag/SHA) in `SkillPin.env` or CI var | H-N3 |
| B2 | Implement fetch (git sparse / release archive / raw API) | H-N3 |
| B3 | Rewrite `shortcuts[].path` → vendor-local paths + copy XML | H-F1 |
| B4 | Validate each `package.json` vs vendored copy of schema | H-N4 |
| B5 | GitHub Action `fetch-packages.yml` on PR + main | H-N9 |
| B6 | Enforce `local-*` ≠ `cloud-allowed` | H-C1 |

Script seed in this skill tree: [`scripts/fetch_skill_packages.sh`](scripts/fetch_skill_packages.sh).

## Phase C — Domain + catalog UI (P0)

**DoD:** Simulator shows 4 packages from Vendor ; detail shows policy + attestation.

| Step | Action | Req |
|------|--------|-----|
| C1 | `HorizonPackage` Codable + loader | H-F1 |
| C2 | `PackageCatalogStore` loads Vendor tree | H-F1 |
| C3 | Catalog list + detail SwiftUI (iPhone/iPad) | H-N8 |
| C4 | Attestation badge honest mapping | H-C3 |
| C5 | Empty / error states if Vendor missing | — |

## Phase D — Install / run bridge (P0)

**DoD:** Hello World installs and runs on Simulator/device via Shortcuts.

| Step | Action | Req |
|------|--------|-----|
| D1 | Build `shortcuts://` URLs (encode) | H-F3 H-F4 |
| D2 | Export/copy XML to temporary importable location | H-F3 |
| D3 | `ShortcutInstaller` + user-visible confirmation | H-F3 |
| D4 | `ShortcutRunner` by `output_name` / installed name | H-F4 |
| D5 | SwiftData `InstalledPackage` on success | H-F6 |
| D6 | Library tab lists installed | H-F6 |

## Phase E — Deep link + App Intents (P0/P1)

**DoD:** `hermes-shortcuts://edit?path=…` handled ; Install/Run intents appear in Shortcuts.

| Step | Action | Req |
|------|--------|-----|
| E1 | `onOpenURL` → `HermesShortcutsRouter` | H-F5 H-C4 |
| E2 | Path allowlist + sheet with skill-relative path | H-F5 |
| E3 | `InstallPackageIntent` / `RunPackageIntent` | H-F7 H-F8 |
| E4 | `HorizonAppShortcuts` from phrases | H-F9 |
| E5 | `BrowseCatalogIntent` | H-F11 |

## Phase F — ModelRouter (P1)

**DoD:** local-* packages show capability gate ; no cloud leak.

| Step | Action | Req |
|------|--------|-----|
| F1 | Enum `ModelPolicy` | H-F10 |
| F2 | Availability check Foundation Models / Apple Intelligence | H-F10 |
| F3 | Detail CTA disabled + explanation when unavailable | H-F10 |
| F4 | Guard `cloud-allowed` on local-* | H-C1 |

## Phase G — Tests & hardening (P0/P1)

**DoD:** [`CHECKLIST.md`](CHECKLIST.md) P0 all green ; P1 marked or done.

| Step | Action | Req |
|------|--------|-----|
| G1 | Unit : decode fixtures of 4 packages | H-N9 |
| G2 | Unit : deep link path traversal rejected | H-C4 |
| G3 | Unit : URL builder encoding | H-F3 |
| G4 | `xcodebuild test` on Mac | H-N10 |
| G5 | Manual Simulator script in TESTING.md | — |
| G6 | Device + Siri smoke (human) | H-F9 |

## Phase H — Stop conditions / handoff

Agent **stops and reports** if:

- No Xcode → deliver phases A–C + scripts ; paste Mac commands for D–G.
- Private repo inaccessible → stop after documenting bootstrap.
- Skill ref fetch 404 → fail CI loudly ; do not ship empty catalog as success.

## Suggested single-prompt for the next agent

> Load `horizon/app/SKILL.md`. Execute ONESHOT_PLAN phases A–G against private repo
> `OTNworld/horizon-iOS`. Pin skill ref to current release tag of
> `generate-shortcuts-skill-Hermes-`. Satisfy all P0 rows in CHECKLIST.md. Do not
> invent Apple App Intent IDs. If Xcode is missing, complete Linux-safe work and
> hand off Mac steps verbatim.

## Interactive questions (only if blocked)

Ask at most 1–2 at a time:

1. Bundle ID override vs `com.otnworld.horizon` ?
2. Team / signing identity for device runs ?
3. Skill pin : latest semver tag vs explicit SHA ?
4. Include Mac Catalyst target in oneshot ? (default **no**)
5. Product language UI : FR / EN / both ? (default **EN UI**, FR agent docs OK)
