# Mackasten iOS — oneshot plan

Goal: a single agent run (on a **Mac with Xcode 26+**, repo privé déjà créé) ships a
buildable app satisfying P0 requirements. Linux Cloud Agents stop after scaffold +
CI fetch scripts + unit tests purs, and hand off Mac gates explicitly.

## Preflight (human, once)

1. Private repo **`OTNworld/Mackasten`** exists + Cursor GitHub App access — [`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md).
2. Grant the coding agent access to that private repo.
3. Confirm Xcode 26+ / Simulator on the machine that will run phases D–F.

## Phase A — Repository skeleton (P0)

**DoD:** `xcodegen` project opens ; empty tabs compile.

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| A1 | Copy seed `mackasten/app/**` into app repo root | — | docs + scaffold ready |
| A2 | Add `project.yml` (iOS app + unit test bundle) | H-N2 | **done in seed** |
| A3 | Bundle ID `com.otnworld.mackasten`, display name Mackasten | H-N11 | **done** |
| A4 | Register URL type `hermes-shortcuts` | H-F5 | **done** (`Info.plist`) |
| A5 | `PrivacyInfo.xcprivacy` stubs for UserDefaults if used | H-N6 | **done** |
| A6 | `.gitignore` : `Vendor/SkillPackages/`, generated xcodeproj | — | **done** |
| A7 | README app : how to fetch + generate + test | — | **done** |

## Phase B — Fetch CI (P0)

**DoD:** `./scripts/fetch_skill_packages.sh` materializes 4 packages ; schema check green.

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| B1 | Pin `SKILL_REPO` + `SKILL_REF` in `SkillPin.env` | H-N3 | example present |
| B2 | Implement fetch | H-N3 | **done** |
| B3 | Rewrite paths → vendor-local + copy XML | H-F1 | **done** |
| B4 | Validate JSON Schema after fetch | H-N4 | **done** |
| B5 | GitHub Action `fetch-packages.yml` | H-N9 | **seeded** |
| B6 | Enforce `local-*` ≠ `cloud-allowed` | H-C1 | **done** |

## Phase C — Domain + catalog UI (P0)

**DoD:** Simulator shows 4 packages from Vendor ; detail shows policy + attestation.

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| C1–C5 | Codable + store + SwiftUI list/detail + empty state | H-F1 H-N8 H-C3 | **scaffolded** (needs Mac run) |

## Phase D — Install / run bridge (P0)

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| D1–D6 | URL builder, share install, run, SwiftData library | H-F3–F6 | **scaffolded** (needs Mac/device) |

## Phase E — Deep link + App Intents (P0/P1)

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| E1–E5 | Router + Install/Run/Browse intents + AppShortcuts | H-F5–F9 H-F11 | **scaffolded** |

## Phase F — ModelRouter (P1)

| Step | Action | Req | Seed status |
|------|--------|-----|-------------|
| F1–F4 | Policy enum + Sim gate + local-* guard | H-F10 H-C1 | **scaffolded** (device AI probe TBD) |

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

> Private repo `OTNworld/Mackasten` already seeded from `mackasten/app/` (includes
> Swift scaffold). Load `SKILL.md`. Pin `SKILL_REF`, run fetch, `xcodegen generate`,
> then execute remaining Mac gates in CHECKLIST.md (Simulator install/run Hello World,
> deep link smoke, `xcodebuild test`). Do not invent Apple App Intent IDs. If Xcode is
> missing, stop after confirming fetch + Linux unittest mirrors.

## Interactive questions (only if blocked)

Ask at most 1–2 at a time:

1. Bundle ID override vs `com.otnworld.mackasten` ?
2. Team / signing identity for device runs ?
3. Skill pin : latest semver tag vs explicit SHA ?
4. Include Mac Catalyst target in oneshot ? (default **no**)
5. Product language UI : FR / EN / both ? (default **EN UI**, FR agent docs OK)
