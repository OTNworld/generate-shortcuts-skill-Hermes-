# Bootstrap — private repo `OTNworld/mackasten-iOS`

The Cloud Agent token **cannot** create private repos under your account. Do this
once in the GitHub UI or with **your** `gh` login.

## 1. Create the repository

GitHub → New repository:

| Field | Value |
|-------|-------|
| Owner | `OTNworld` |
| Name | `mackasten-iOS` |
| Visibility | **Private** |
| README | empty OK (we push seed) |
| License | none yet (private app) |

CLI (on your machine):

```bash
gh repo create OTNworld/mackasten-iOS --private --description "Mackasten companion iOS app (Shortcuts marketplace)"
```

## 2. Seed from this skill folder

From a clone of the **skill** repo:

```bash
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git skill
git clone https://github.com/OTNworld/mackasten-iOS.git mackasten-iOS
cd mackasten-iOS

# Product + agent skill seed
cp -R ../skill/mackasten/app/. .
mkdir -p scripts
# fetch script already under ./scripts if copied from app/

git add .
git commit -m "Seed Mackasten iOS oneshot blueprint from skill mackasten/app"
git push -u origin main
```

## 3. Grant the coding agent

- Add the private repo to the Cursor Cloud / GitHub App installation for OTNworld.
- Or run the oneshot agent **locally** with access to `mackasten-iOS`.

## 4. Cross-link from the skill (already planned)

Public skill docs point to `mackasten/app/` as blueprint and name the private repo
without requiring public access to app sources.

## 5. First oneshot

Open `mackasten-iOS` with `SKILL.md` loaded and run [`ONESHOT_PLAN.md`](ONESHOT_PLAN.md).

## Checklist

- [ ] Repo private `OTNworld/mackasten-iOS` created
- [ ] Seed pushed
- [ ] Agent can clone
- [ ] `SKILL_REF` chosen (e.g. current skill semver tag)
- [ ] Xcode 26+ ready for build phases
