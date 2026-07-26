# Finaliser en local (Mac) → 10/10

Branche : `cursor/skill-quality-hardening-0e57`  
PR : https://github.com/OTNworld/generate-shortcuts-skill-Hermes-/pull/1

La CI Linux est déjà au **~9.5**. Il reste l’**attestation Shortcuts** sur ton Mac.

## 1. Récupérer la branche

```bash
git fetch origin
git checkout cursor/skill-quality-hardening-0e57
git pull origin cursor/skill-quality-hardening-0e57
./scripts/validate.sh
```

## 2. Attester (sign → import → run)

```bash
# Preflight Accessibilité (obligatoire pour l’import UI)
./scripts/check_shortcuts_automation.sh

# Boucle automatisée (core = examples 01–08 + palette)
./scripts/attest_local.sh --auto

# Optionnel : community/ + clic vert screenshot
./scripts/attest_local.sh --auto --all --click-green
```

Équivalent manuel / semi-manuel :

```bash
./scripts/attest_local.sh --hash-only
./scripts/attest_local.sh --open          # ouvre seulement
./scripts/attest_local.sh --import-ui     # import via Return/AX
./scripts/attest_local.sh --run
```

Doc : [`references/ATTEST_AUTOMATION.md`](references/ATTEST_AUTOMATION.md).

## 3. Remplir la matrice

Éditer [`fixtures/attested/MATRIX.md`](fixtures/attested/MATRIX.md)  
(détails : [`fixtures/attested/MAC_HANDOFF.md`](fixtures/attested/MAC_HANDOFF.md)).

Critères pass :
- `examples/01`–`08` : Sign + Import + Run OK
- `palette/01`–`12` : Sign + Import OK (Run optionnel si réseau/`delay`)
- ≥ 2 `community/*` : Import OK
- `fixtures/attested/hashes.sha256` présent

## 4. Clôturer le 10/10

```bash
# Ne pas committer les *_signed.shortcut
git add fixtures/attested/MATRIX.md fixtures/attested/hashes.sha256
# Bump SKILL.md version → 1.9.0 + entrée CHANGELOG "Attested on macOS …"
git commit -m "attest: macOS sign/import matrix for 10/10 skill"
git push
```

Puis merger la PR.

## Déjà fait sans Mac (ne pas refaire)

- SSOT + validate/CI + grammar strict  
- Goldens teaching + palette + community MIT  
- ECOSYSTEM / extract / render_refs  
- Stub Locally honnête  

## Si un golden échoue à l’import

1. Noter FAIL + message dans MATRIX  
2. `./scripts/extract_shortcut.sh` sur un export Shortcuts du même flow  
3. Diff vs le XML du repo → corriger le golden → re-signer  
4. Ne pas inventer de paramètres
