# Mac attestation handoff

Complete this on a Mac with Shortcuts.app to reach a credible **10/10 skill**.
Linux CI already covers XML + grammar + SSOT.

**Start here:** [`LOCAL_FINALIZE.md`](../../LOCAL_FINALIZE.md) (root of repo).

## Quick path

```bash
git checkout cursor/skill-quality-hardening-0e57 && git pull
./scripts/validate.sh
./scripts/check_shortcuts_automation.sh
./scripts/attest_local.sh --auto          # sign + import UI + run
# ./scripts/attest_local.sh --auto --all
```

Fill [`MATRIX.md`](MATRIX.md) from automation + `runs/run_report.tsv`.  
See [`references/ATTEST_AUTOMATION.md`](../../references/ATTEST_AUTOMATION.md).

## Extract / diff if something fails

```bash
./scripts/extract_shortcut.sh ~/Downloads/MyShortcut.shortcut /tmp/my.xml
diff -u templates/examples/01-hello-world.shortcut.xml /tmp/my.xml | less
```

## When done

1. Commit `MATRIX.md` + `hashes.sha256` (never commit `*_signed.shortcut`)
2. Bump `SKILL.md` to `1.9.0` + CHANGELOG attestation note
3. Push and merge the PR
