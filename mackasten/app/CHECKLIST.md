# Mackasten iOS — creation & test checklist

Use during oneshot. Check boxes in the **app** repo PR description.

## Creation gates

### Repo / project

- [ ] Private repo `OTNworld/mackasten-iOS` exists
- [ ] Seed docs (`VISION`…`SKILL`) present
- [ ] `project.yml` + `xcodegen generate` succeeds
- [ ] Bundle ID set ; URL scheme `hermes-shortcuts` registered
- [ ] `PrivacyInfo.xcprivacy` present
- [ ] `.gitignore` excludes `Vendor/SkillPackages/` build tree (or commits release snapshot intentionally)

### Fetch CI

- [ ] `SKILL_REF` pinned (tag or SHA)
- [ ] `scripts/fetch_skill_packages.sh` exits 0
- [ ] Four packages materialize under `Vendor/SkillPackages/`
- [ ] Schema validation passes for each `package.json`
- [ ] `local-*` packages are not `cloud-allowed`
- [ ] GitHub Action runs on PR

### Product P0

- [ ] Catalog lists hello-world, clipboard-set, local-ask-llm, local-rewrite
- [ ] Detail shows model_policy + attestation
- [ ] Install Hello World triggers Shortcuts import flow
- [ ] Run Hello World returns expected result
- [ ] Install persists in Library (SwiftData)
- [ ] `hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml` opens handler (no crash ; path shown)
- [ ] Path with `..` is rejected
- [ ] InstallPackage + RunPackage App Intents build

## Automated tests

| Layer | Where | Must pass |
|-------|-------|-----------|
| Schema + fetch | Linux CI / Mac | fetch script + JSON schema |
| Unit (Swift Testing) | Mac `xcodebuild test` | decode, URL encode, deep link sanitize, policy guards |
| UI smoke | Simulator manual or XCUITest | catalog → detail → install CTA visible |

### Unit cases (minimum)

- [ ] Decode all 4 seed `package.json`
- [ ] Reject malformed schema (`schema` ≠ `mackasten-package/v1`)
- [ ] `ModelPolicy` local-* guard
- [ ] `ShortcutsURLBuilder.run(name:)` percent-encodes spaces
- [ ] Deep link accepts `edit?path=templates/examples/01-hello-world.shortcut.xml`
- [ ] Deep link rejects `edit?path=../../etc/passwd`
- [ ] Deep link rejects missing path

## Manual Mac / device matrix

| Case | Simulator | Device | Notes |
|------|-----------|--------|-------|
| Launch cold | required | required | |
| Catalog browse | required | required | |
| Install hello-world | required | required | system Shortcuts UI |
| Run hello-world | required | required | |
| local-ask-llm gate | show unavailable on Sim | real AI device | H-F10 |
| Siri phrase | optional | required for H-F9 | |
| iPad layout | required | optional | H-N8 |
| VoiceOver pass | required | optional | H-N7 |

## Attestation honesty

- [ ] UI never labels a package `mac-run` unless manifest says so
- [ ] Unattested packages still installable with warning

## Release readiness (post-oneshot)

- [ ] Skill pin recorded in release notes
- [ ] Version marketing / build numbers set
- [ ] TestFlight smoke (human)
- [ ] No API keys in repo

## Linux Cloud Agent honesty bar

On Linux, mark Mac rows as **blocked** with exact commands:

```bash
cd /path/to/mackasten-iOS
./scripts/fetch_skill_packages.sh
xcodegen generate
xcodebuild -scheme Mackasten -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Do not claim device Siri or Apple Intelligence success from Linux.
