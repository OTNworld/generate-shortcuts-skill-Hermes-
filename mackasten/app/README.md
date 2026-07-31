# Mackasten — app blueprint + Swift scaffold

**Status:** oneshot seed with **Swift/XcodeGen scaffold** (phases A–E). Runtime
targets private GitHub repo **`OTNworld/Mackasten`** (slug without `-iOS`).  
**Packages SSOT:** [`../packages/`](../packages/) · schema `mackasten-package/v1`  
**Vision:** [`VISION.md`](VISION.md) · **Oneshot:** [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md)

Copy this entire directory into `OTNworld/Mackasten` after [`REPO_BOOTSTRAP.md`](REPO_BOOTSTRAP.md).

## Decisions locked

| Decision | Choice |
|----------|--------|
| Private app repo | **`OTNworld/Mackasten`** (not `mackasten-iOS`) |
| Link to skill | **Fetch CI** of `mackasten/packages` + XML @ pinned tag/SHA |
| Stack | Swift / SwiftUI / App Intents / SwiftData · iOS 18+ / SDK 26 |
| Bundle ID | `com.otnworld.mackasten` |

## Map

| Path | Role |
|------|------|
| [`SKILL.md`](SKILL.md) | Agent protocol |
| [`project.yml`](project.yml) | XcodeGen SSOT |
| [`Mackasten/`](Mackasten/) | App sources (catalog, library, deep link, intents, Shortcuts bridge) |
| [`MackastenTests/`](MackastenTests/) | Swift Testing suite |
| [`scripts/fetch_skill_packages.sh`](scripts/fetch_skill_packages.sh) | Materialize `Vendor/SkillPackages/` |
| [`.github/workflows/fetch-packages.yml`](.github/workflows/fetch-packages.yml) | App-repo CI seed |

## Mac quick start (private repo)

```bash
cp SkillPin.env.example SkillPin.env   # pin SKILL_REF to a tag
./scripts/fetch_skill_packages.sh
brew install xcodegen                  # if needed
xcodegen generate
open Mackasten.xcodeproj
# or:
xcodebuild -scheme Mackasten -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Linux (this skill repo)

```bash
./mackasten/app/scripts/fetch_skill_packages.sh
python3 mackasten/app/scripts/check_oneshot_ready.py
python3 -m unittest tests.test_mackasten_app_logic -v
./scripts/validate.sh
```

No Xcode on Linux — do not claim Simulator/Siri success here.
