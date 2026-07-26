# Attested fixtures (10/10 track)

This folder records proof that goldens signed and imported on real Apple OS builds.
Linux CI cannot run `shortcuts sign` or Shortcuts.app — attestation stays here.

Automation (Mac local): see [`references/ATTEST_AUTOMATION.md`](../../references/ATTEST_AUTOMATION.md).

```bash
./scripts/check_shortcuts_automation.sh
./scripts/attest_local.sh --auto
```

## How to attest

On a Mac with Shortcuts:

```bash
./scripts/attest_local.sh --auto
# or manual:
cp templates/examples/01-hello-world.shortcut.xml /tmp/HelloWorld.shortcut
./scripts/sign_shortcut.sh /tmp/HelloWorld.shortcut /tmp/HelloWorld_signed.shortcut
./scripts/import_shortcut_ui.sh /tmp/HelloWorld_signed.shortcut
shortcuts run "HelloWorld_signed"
```

Then update `MATRIX.md` with Sign / Import / Run.

Optional: store SHA-256 of the **unsigned XML** only (not personal signed binaries).

## Status

Matrix: [`MATRIX.md`](MATRIX.md).  
Handoff: [`MAC_HANDOFF.md`](MAC_HANDOFF.md) / [`LOCAL_FINALIZE.md`](../../LOCAL_FINALIZE.md).
