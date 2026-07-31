# AGENTS.md

## Cursor Cloud specific instructions

This repo is the **Shortcuts Generator skill for Hermes** — a shell/Python toolchain (no
app server, no frontend, no package manager). There is nothing to "run" as a long-lived
service; the product surface is a validation + remix + (Mac-only) signing/attestation
pipeline. See `README.md`, `CONTRIBUTING.md`, and `LOCAL_FINALIZE.md` for the canonical
commands.

### Toolchain / dependencies
- Only two runtime deps on Linux: `python3` (stdlib only) and `xmllint` (`libxml2-utils`).
  Both are preinstalled; the update script only ensures `xmllint` exists. No `pip`/`npm`
  install step exists because there are no lockfiles or manifests.
- `Pillow` is optional and only used by `scripts/attest_local.sh --click-green` on macOS.
  Do not install it in the cloud VM.

### Lint / test / build (all the same here)
There is no separate lint/test/build. The single source of truth is:
- `./scripts/validate.sh` — full CI-parity check (SSOT catalogs, ref drift, `xmllint`,
  `bash -n`, grammar heuristics + deep strict grammar). This is exactly what
  `.github/workflows/validate.yml` runs.
- `./scripts/selftest.sh` — quick check: `validate.sh` + `validate_on_write.sh` on golden 01.
- `./scripts/validate_on_write.sh [--fix] <file>` — validate a single plist after editing it.

### Core-functionality smoke (Linux)
Generate a new shortcut by remixing a golden, then validate it:
```bash
python3 scripts/remix_shortcut.py templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!" --output /tmp/out.shortcut.xml
./scripts/validate_on_write.sh /tmp/out.shortcut.xml
```

### macOS-only (cannot run in cloud VM)
Signing / importing / running shortcuts (`scripts/sign_shortcut.sh`,
`scripts/attest_local.sh`, `scripts/import_shortcut_ui.sh`,
`scripts/check_shortcuts_automation.sh`) require macOS + the `shortcuts` CLI +
Shortcuts.app + Accessibility permission. These are no-ops / will fail on the Linux cloud
VM by design — do the 10/10 attestation on a real Mac (see `LOCAL_FINALIZE.md`).

### Gotchas
- Never mutate committed teaching goldens under `templates/`. Remix demos must `--output`
  to a temp path (e.g. `/tmp/...`).
- `validate.sh` enforces that numeric claims in `README.md`/`SKILL.md`/`references/*` match
  the SSOT counts in `data/wf_actions.json` (**446**) and `data/appintents.json` (**168**), and
  that `render_refs.py --check` shows no drift. If you change catalogs, re-sync the docs
  or validation fails.
- Mackasten marketplace manifests live under `mackasten/packages/` (schema
  `mackasten-package/v1`); `scripts/check_mackasten_packages.py` runs in `validate.sh`.
- Optional local MCP: `mcp_server/run.sh` (needs `.venv-mcp`); not required for CI.
- `*.stub.xml` files are XML-only design snapshots and are intentionally skipped by grammar
  checks.
