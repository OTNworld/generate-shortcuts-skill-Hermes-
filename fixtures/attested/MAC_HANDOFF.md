# Mac attestation handoff

Complete this on a Mac with Shortcuts.app to reach a credible **10/10 skill**.
Linux CI already covers XML + grammar + SSOT.

## One-shot checklist

```bash
cd ~/.hermes/skills/shortcuts-generator   # or your clone
./scripts/validate.sh

# Teachings
for f in templates/examples/0{1..8}-*.shortcut.xml templates/palette/*.shortcut.xml; do
  base=$(basename "$f" .shortcut.xml)
  cp "$f" "/tmp/${base}.shortcut"
  ./scripts/sign_shortcut.sh "/tmp/${base}.shortcut" "/tmp/${base}_signed.shortcut"
  open "/tmp/${base}_signed.shortcut"
  # Confirm import + run in Shortcuts, then record below
done
```

Optional community (larger):

```bash
for f in templates/examples/community/*.shortcut.xml; do
  ...
done
```

## Record results

Copy to [`MATRIX.md`](MATRIX.md) (create if missing):

| Golden | macOS | iOS | Shortcuts build | Date (UTC) | Sign | Import | Run | Notes |
|--------|-------|-----|-----------------|------------|------|--------|-----|-------|
| 01-hello-world | 15.x | — | | YYYY-MM-DD | OK/FAIL | OK/FAIL | OK/FAIL | |
| palette/01-ask | | | | | | | | |
| community/09-url-cleaner | | | | | | | | |

Also store SHA-256 of **unsigned XML** only:

```bash
shasum -a 256 templates/examples/01-hello-world.shortcut.xml
```

## Extract / diff workflow (Mac)

```bash
# From an export or iCloud download:
./scripts/extract_shortcut.sh ~/Downloads/MyShortcut.shortcut /tmp/my.xml
diff -u templates/examples/01-hello-world.shortcut.xml /tmp/my.xml | less
```

iCloud record API notes: see header comment in `scripts/extract_shortcut.sh`.

## When done

1. Commit `fixtures/attested/MATRIX.md` (no personal signed binaries)
2. Bump `SKILL.md` version + CHANGELOG
3. Optionally mark goldens `attested: true` in a future sidecar JSON
