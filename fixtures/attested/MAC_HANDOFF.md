# Mac attestation handoff

Complete remaining **Mac 10/10** items on a Mac with Shortcuts.app.
Linux CI already covers XML + grammar + SSOT + Horizon package manifests.

**Active checklist:** [`references/MAC_10_CHECKLIST.md`](../../references/MAC_10_CHECKLIST.md)  
**Start here:** [`LOCAL_FINALIZE.md`](../../LOCAL_FINALIZE.md)

Skill version expected: **≥1.12.0** (current track may be 1.13.0+).

## Quick path

```bash
git fetch origin
git checkout cursor/horizon-app-and-improvements-df7d && git pull
./scripts/validate.sh
./scripts/check_shortcuts_automation.sh --json
./scripts/attest_local.sh --auto --force --timeout 20
# palette 13–16 + network:
./scripts/run_shortcut_attest.sh --include-network
```

Fill [`MATRIX.md`](MATRIX.md) from automation + `runs/*.tsv`.  
See [`references/ATTEST_AUTOMATION.md`](../../references/ATTEST_AUTOMATION.md).

### Priority this pass

1. Palette **13–16** Sign/Import/Run (or categorized skip)
2. Refresh `results.json` (`skill_version` match)
3. Optional: shrink `data/appintents.json` → `unverified` via export-diff

## Extract / diff if something fails

```bash
./scripts/extract_shortcut.sh ~/Downloads/MyShortcut.shortcut /tmp/my.xml
diff -u templates/palette/14-number.shortcut.xml /tmp/my.xml | less
```

## When done

1. Commit `MATRIX.md` + `hashes.sha256` + `results.json` (never `*_signed.shortcut`)
2. Tick boxes in `references/MAC_10_CHECKLIST.md`
3. CHANGELOG attestation note if bumping
