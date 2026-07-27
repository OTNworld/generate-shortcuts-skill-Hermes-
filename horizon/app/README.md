# Horizon iOS — app blueprint (seed for private repo)

**Status:** oneshot-ready product + agent skill, living in the public skill until
`OTNworld/horizon-iOS` (private) exists.  
**Skill (packages):** [`../packages/`](../packages/) · schema `horizon-package/v1`  
**Vision (product):** [`VISION.md`](VISION.md) · **Oneshot:** [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md)

This directory is the **seed** of the companion app repository. It does **not**
ship an Xcode binary here. Copy / push it into the private app repo after
[`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md).

## Decisions locked (2026-07-27)

| Decision | Choice |
|----------|--------|
| Private app repo | `OTNworld/horizon-iOS` (you create it — agent GitHub token cannot) |
| Link to skill | **Fetch CI** of `horizon/packages` + shortcut XML from public skill |
| Delivery mode | Full **final vision** spec so a later agent can **oneshot** the app |
| Native stack | Swift / SwiftUI / App Intents / SwiftData · iOS 26 SDK |
| External skills | Link + index (do not vendor whole trees) — see [`sources.json`](sources.json) |

## Map (≤2 min)

| Doc | Role |
|-----|------|
| [`SKILL.md`](SKILL.md) | Agent protocol to scaffold / ship Horizon |
| [`VISION.md`](VISION.md) | Final product thesis + surfaces |
| [`REQUIREMENTS.md`](REQUIREMENTS.md) | Functional + non-functional needs |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Modules, data flow, trust boundaries |
| [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md) | Ordered build phases for a single agent run |
| [`CHECKLIST.md`](CHECKLIST.md) | Creation + complete test gates |
| [`CI_FETCH.md`](CI_FETCH.md) | How the app repo consumes skill packages |
| [`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md) | Create private repo + first push |
| [`references/`](references/) | Deep refs (URL scheme, marketplace, models, tests, design) |

## Relationship

```text
OTNworld/generate-shortcuts-skill-Hermes-   (public, MIT, lean)
  └─ author / validate / attest Shortcuts + horizon-package manifests

OTNworld/horizon-iOS                        (private, app)
  └─ UX, marketplace runtime, Siri, on-device models
  └─ CI: fetch packages + XML from skill @ pinned tag/SHA
```

## Quick start (after private repo exists)

1. Follow [`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md).
2. Install agent skill: copy `horizon/app/` → `~/.hermes/skills/horizon-ios/` (or keep in-repo).
3. Run oneshot per [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md) with [`SKILL.md`](SKILL.md) loaded.
4. Mac/iOS: Xcode 26+ required for build/run (not available on Linux Cloud Agents).
