# Release — publication du skill Hermes

Dernière màj : **2026-07-26** · Version courante skill : voir `SKILL.md` `version:`  
Dernière GitHub Release connue : **v1.10.0** (Mac-attested baseline)

## Modes de publication

| Mode | Quand | Claim Mac |
|------|-------|-----------|
| **A — Linux-complete** | Merge PR + CI verte ; Mac deltas 1.11–1.15 **non** re-attestés | Explicit *Mac attest pending* |
| **B — Mac-attested** | Après [`MAC_10_CHECKLIST.md`](MAC_10_CHECKLIST.md) (palette 13–16 min) | Peut citer MATRIX / `results.json` à jour |

Script : [`scripts/cut_release.sh`](../scripts/cut_release.sh) (**dry-run par défaut**).

## Automatisable

1. `./scripts/validate.sh` + `./scripts/selftest.sh`
2. Cohérence `SKILL.md` / `SKILL.en.md` version + section CHANGELOG
3. Génération notes release (FR+EN disclaimers)
4. Tag annoté + `gh release create` (**opt-in** `--apply`, branche `main` only)
5. Archive zip source (sans `.git`, sans signed binaries)

## Manuel / méfiance

- Ne pas tagger depuis une PR cloud non mergée dans `main`
- Ne pas revendiquer attestation Mac pour deltas post-`v1.10.0` sans MATRIX
- AppIntents `unverified` ≠ teaching goldens
- Horizon packages = paper MVP, pas une app store
- iOS = best-effort / non attesté
- Upstream `drewocarr` license unspecified — ne pas le dire MIT
- Markets (LobeHub / Cursor) = fiche manuelle + wording prudent
- Jamais commit/release de `*_signed.shortcut`

## Checklist pré-tag

- [ ] PR mergée dans `main` ; CI verte sur `main`
- [ ] `version:` SKILL = SKILL.en = titre CHANGELOG `## [X.Y.Z]`
- [ ] Mode **A** ou **B** choisi
- [ ] Si B : `MAC_10_CHECKLIST` M1 (+ M7) cochés ; `results.json` `skill_version` aligné
- [ ] `./scripts/cut_release.sh` dry-run OK
- [ ] Relire notes générées
- [ ] `./scripts/cut_release.sh --apply` (humain) **ou** tag manuel

## Install post-release (Hermes)

```bash
mkdir -p ~/.hermes/skills
cd ~/.hermes/skills
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git shortcuts-generator
# ou: git fetch && git checkout v1.15.0
```
