# Security

This repository is a **documentation / skill package**. It does not run a network
service, but generated Shortcuts can still move data off-device.

## Signing modes

| Mode | Meaning | Risk |
|------|---------|------|
| `anyone` | Importable by anyone with the file | Treat as public distribution |
| `people-who-know-me` | Restricted to contacts who know you | Still share carefully |

Default in `scripts/sign_shortcut.sh` is `anyone` — intentional for shareable
examples. Choose deliberately for personal automations.

## Secrets in plists

Do **not** embed in committed XML:
- API tokens, passwords, SSH keys
- Personal vault paths with private note titles
- Phone numbers / emails you would not publish

Prefer Ask prompts or Shortcuts’ own credential mechanisms.

**CI gate:** `python3 scripts/check_no_secrets.py` (also from `./scripts/validate.sh`)
flags high-confidence patterns (`sk-…`, `ghp_…`, PEM private keys, `api_key=` assignments, …).

## Signed artifacts

- Prefer gitignoring `*_signed.shortcut` and local `out/` directories
- Attestation logs in `fixtures/attested/` should store hashes + OS metadata, not private shortcut bodies, unless scrubbed

## Upstream lineage

This Hermes skill is an MIT-licensed fork/adaptation. Upstream
`drewocarr/generate-shortcuts-skill` is recorded in `data/sources.json` with
**license: unknown/unspecified** — we do **not** claim their license is MIT.
See `THIRD_PARTY_NOTICES.md`.

## Reporting

If you discover a security issue in scripts or docs that could cause data loss
or credential leak guidance, open a private report with the maintainers rather
than filing a public issue with exploit detail.
