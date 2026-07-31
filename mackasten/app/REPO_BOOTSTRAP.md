# Bootstrap — private repo `OTNworld/mackasten-iOS`

The Cloud Agent token **cannot** create private repos under your account. Do this
once in the GitHub UI or with **your** `gh` login.

## 1. Create the repository

```bash
gh repo create OTNworld/mackasten-iOS --private --description "Mackasten companion iOS app (Shortcuts marketplace)"
```

## 2. Seed from this skill folder

```bash
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git skill
git clone https://github.com/OTNworld/mackasten-iOS.git mackasten-iOS
cd mackasten-iOS

# Product docs + Swift/XcodeGen scaffold + fetch CI
cp -R ../skill/mackasten/app/. .

git add .
git commit -m "Seed Mackasten iOS scaffold from skill mackasten/app"
git push -u origin main
```

## 3. First Mac build

```bash
cp SkillPin.env.example SkillPin.env
# set SKILL_REF=<skill tag or SHA>
./scripts/fetch_skill_packages.sh
xcodegen generate
xcodebuild -scheme Mackasten -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## 4. Grant the coding agent

Add the private repo to the Cursor / GitHub App installation, then run the oneshot
prompt in [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md).

## Checklist

- [ ] Repo private `OTNworld/mackasten-iOS` created
- [ ] Seed pushed (includes `Mackasten/` sources + `project.yml`)
- [ ] Agent can clone
- [ ] `SKILL_REF` pinned
- [ ] Xcode 26+ ready for Simulator gates
