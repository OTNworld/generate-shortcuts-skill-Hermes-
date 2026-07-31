# Bootstrap — private repo `OTNworld/Mackasten`

**Repo name:** `Mackasten` (no `-iOS` suffix). The product is still a native
iPhone/iPad companion app; only the GitHub slug is short.

This Cloud Agent **cannot** create or see the private repo until the Cursor /
GitHub App is installed on it.

## 1. Repo (already created)

If you already created it:

```text
https://github.com/OTNworld/Mackasten
```

Visibility: **Private**. Empty or with a default README is fine.

If you still need to create it (your machine):

```bash
gh repo create OTNworld/Mackasten --private --description "Mackasten companion app — Shortcuts marketplace"
```

## 2. Grant this agent access (required)

1. GitHub → **Settings → Applications → Cursor** (or the GitHub App used by Cursor Cloud)
2. **Repository access** → add **`OTNworld/Mackasten`**
3. Re-run / message the agent so it can `git clone` + `git push`

Without this step, the agent only gets 404 on the private repo.

## 3. Seed the app tree (from skill `mackasten/app/`)

On your machine **or** via the agent once access is granted:

```bash
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git skill
git clone https://github.com/OTNworld/Mackasten.git Mackasten
cd Mackasten

# Product docs + Swift/XcodeGen scaffold + fetch CI → repo root
cp -R ../skill/mackasten/app/. .

git add .
git commit -m "Seed Mackasten companion app from skill mackasten/app"
git push -u origin main
```

Helper (from skill checkout, after App access):

```bash
./mackasten/app/scripts/push_seed_to_mackasten.sh
```

## 4. First Mac build

```bash
cd Mackasten
cp SkillPin.env.example SkillPin.env
# set SKILL_REF=<skill tag or SHA>
./scripts/fetch_skill_packages.sh
xcodegen generate
xcodebuild -scheme Mackasten -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## 5. Oneshot handoff

Open `OTNworld/Mackasten` with [`SKILL.md`](SKILL.md) loaded and follow
[`ONESHOT_PLAN.md`](ONESHOT_PLAN.md) Mac gates.

## Checklist

- [x] Repo private `OTNworld/Mackasten` created *(you)*
- [ ] Cursor GitHub App can access `Mackasten`
- [ ] Seed pushed (includes `Mackasten/` sources + `project.yml`)
- [ ] `SKILL_REF` pinned
- [ ] Xcode 26+ ready for Simulator gates
