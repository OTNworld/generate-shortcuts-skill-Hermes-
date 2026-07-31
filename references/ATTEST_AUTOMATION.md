# Attestation automation (macOS)

Linux CI cannot sign/import/run Shortcuts. On a Mac, the skill automates the
loop as far as Apple allows.

## Pipeline

```text
XML golden → sign (CLI) → open → UI import → shortcuts run (+ ask inputs) → results.json / MATRIX.md
```

| Step | Tool | Needs |
|------|------|-------|
| Hash | `attest_local.sh --hash-only` | — |
| Sign | `shortcuts sign` via `sign_shortcut.sh` | Shortcuts CLI |
| Import | `import_shortcut_ui.sh` | **Accessibility** |
| Run | `run_shortcut_attest.sh [--with-inputs]` | Shortcut already imported |
| Aggregate | `write_attest_results.sh` | import/run TSV |
| Vision fallback | `--click-green` | Screen Recording + Pillow |

## One-shot

```bash
./scripts/check_shortcuts_automation.sh
./scripts/attest_local.sh --auto          # sign + import UI + run + ask inputs + results.json
# ./scripts/attest_local.sh --auto --all  # + community
```

Artifacts:

- `fixtures/attested/results.json`
- `fixtures/attested/import_report.tsv` / `run_report.tsv`
- `fixtures/attested/inputs/` (Ask fixtures)
- `fixtures/attested/runs/` (gitignored scratch + FAIL PNGs)

### `results.json` schema (`shortcuts-attest-results/v1`)

Produced by `scripts/write_attest_results.sh` from the import/run TSV reports.

| Field | Meaning |
|-------|---------|
| `schema` | Always `shortcuts-attest-results/v1` |
| `generated_at_utc` | Aggregation timestamp |
| `machine` | `hostname`, `system`, `release`, `macOS` |
| `skill_version` | From `SKILL.md` frontmatter |
| `hash_count` / `hashes_file` | SHA-256 inventory of goldens |
| `import.rows` / `import.tally` | Per-shortcut import OK/FAIL + counts |
| `run.rows` / `run.tally` | Per-shortcut run OK/FAIL/SKIP + counts |
| `pass` | `false` if any import/run row is `FAIL` |

Example (trimmed):

```json
{
  "schema": "shortcuts-attest-results/v1",
  "skill_version": "1.10.0",
  "import": { "tally": { "OK": 24, "FAIL": 0, "SKIP": 0, "other": 0 } },
  "run": { "tally": { "OK": 14, "FAIL": 0, "SKIP": 0, "other": 0 } },
  "pass": true
}
```

Equivalent:

```bash
./scripts/attest_local.sh --import-ui --run --with-inputs
```

## Permissions

1. **Accessibility** (required for import UI):  
   System Settings → Privacy & Security → Accessibility → enable **Cursor** and/or **Terminal**.
2. **Screen Recording** (optional, `--click-green`):  
   same pane → Screen Recording → enable Cursor.

Re-check:

```bash
./scripts/check_shortcuts_automation.sh
```

## How import UI works

Apple exposes no `shortcuts import` CLI. Signed files open an import sheet whose
primary button is often **not** in the Accessibility tree (SwiftUI).

Reliable sequence used by `import_shortcut_ui.sh`:

1. `open -a Shortcuts <signed.shortcut>`
2. Focus process `Shortcuts`
3. Try named AX click (`Ajouter ce raccourci` / `Add Shortcut` / …)
4. Press **Return** (activates the default green CTA) — proven on macOS 26 FR
5. Optional: locate green pixels `(≈60,132,41)` and `click at`
6. Secondary sheets: named AX for untrusted/Allow/Continue (EN+FR); Escape if stuck; retry Return
7. Verify with `shortcuts list | grep -x <name>`

Idempotence: without `--force`, already-listed names are **SKIP**. Use
`./scripts/attest_local.sh --auto --force --timeout 20` to re-import.

## Run policy

`run_shortcut_attest.sh` executes **non-interactive** goldens by default
(`shortcuts run`, output to `fixtures/attested/runs/`).

Skipped unless named explicitly:

- ask / menu / choose-from-list (need UI input)
- network-ish (`weather`, `url-open`, `downloadurl`) unless `--include-network`

### Network pass notes (`--include-network`) — 2026-07-26

| Golden | Observed | Classification |
|--------|----------|----------------|
| `04-url-open_signed` | **OK** (opens URL; may focus browser) | NET |
| `08-downloadurl_signed` | Structure aligned with community electricity-price (magic input + headers). Runtime often **timeout** / privacy prompts → NET flaky | NET |
| `05-weather-ai_signed` | FAIL when Ask LLM / Apple Intelligence unavailable | **ENV** (+ weather NET) — not a pure network smoke |

Flaky causes: helper IPC (`Couldn’t communicate with a helper application`), Intelligence offline, captive portal / DNS. Document FAIL in MATRIX; do not treat ENV fails as golden regressions.

Craig Loop lite (safe fixes only): `./scripts/validate_on_write.sh --fix <file>`

## Agent playbook

1. Stay on a **local** Mac agent (not Cloud Linux).
2. Run `./scripts/check_shortcuts_automation.sh` (or `--json` for agents).
3. Run `./scripts/attest_local.sh --auto`.
4. If Accessibility fails, open Privacy settings and ask the user to toggle Cursor.
5. Optional network: `./scripts/run_shortcut_attest.sh --include-network` (flaky — MATRIX notes).
6. Fill `fixtures/attested/MATRIX.md` from sign/import/`run_report.tsv`.
7. Never commit `*_signed.shortcut` binaries.

### Automations (mackasten H2)

- Always-safe: schedule or manually run `./scripts/selftest.sh` after pulls.
- Mac-only: `./scripts/attest_local.sh --hash-only` or `--auto` on a local agent.
- Fail signal: `fixtures/attested/results.json` field `"pass": false`.
- Full track: [`MACKASTEN_AGENT_CHECKLIST.md`](MACKASTEN_AGENT_CHECKLIST.md) H2 · Cursor Automations UI when wiring a real trigger.

See also: `LOCAL_FINALIZE.md`, `fixtures/attested/MAC_HANDOFF.md`.
