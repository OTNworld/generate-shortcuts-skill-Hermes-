# Finaliser en local (Mac) → 10/10

Branche : `cursor/horizon-app-and-improvements-df7d`  
PR : https://github.com/OTNworld/generate-shortcuts-skill-Hermes-/pull/5  
Checklist Mac : [`references/MAC_10_CHECKLIST.md`](references/MAC_10_CHECKLIST.md)

La CI Linux est déjà au **10/10** sur le track Linux (`LINUX_10_CHECKLIST.md`) + Mackasten paper MVP.
Il reste l’**attestation Shortcuts** sur ton Mac (palette 13–16, NET, AppIntents verify).

## 1. Récupérer la branche

```bash
git fetch origin
git checkout cursor/horizon-app-and-improvements-df7d
git pull origin cursor/horizon-app-and-improvements-df7d
./scripts/validate.sh
```

## 2. Attester (sign → import → run)

```bash
# Preflight Accessibilité (obligatoire pour l’import UI)
./scripts/check_shortcuts_automation.sh --json

# Boucle automatisée (core = examples + palette 01–16)
./scripts/attest_local.sh --auto --force --timeout 20

# Optionnel : community/ + clic vert screenshot + réseau
./scripts/attest_local.sh --auto --all --click-green
./scripts/run_shortcut_attest.sh --include-network
```

Doc : [`references/ATTEST_AUTOMATION.md`](references/ATTEST_AUTOMATION.md) · handoff [`fixtures/attested/MAC_HANDOFF.md`](fixtures/attested/MAC_HANDOFF.md).

## 3. Remplir MATRIX

Mettre à jour `fixtures/attested/MATRIX.md` + `results.json` (surtout palette 13–16).
Cocher [`references/MAC_10_CHECKLIST.md`](references/MAC_10_CHECKLIST.md).

## 4. Ne pas committer

- `*_signed.shortcut`
- exports personnels / secrets
- `fixtures/attested/runs/*.png` (déjà gitignored via `runs/`)

## 5. Mackasten

Packages marketplace (paper) : [`mackasten/README.md`](mackasten/README.md) — pas besoin de Mac pour valider les manifests.
