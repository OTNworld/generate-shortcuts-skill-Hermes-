# Attested fixtures (10/10 track)

This folder records **manual** proof that goldens signed and imported on real Apple OS builds.
Linux CI cannot run `shortcuts sign` or Shortcuts.app — attestation stays here.

## How to attest

On a Mac with Shortcuts:

```bash
cp templates/examples/01-hello-world.shortcut.xml /tmp/HelloWorld.shortcut
./scripts/sign_shortcut.sh /tmp/HelloWorld.shortcut /tmp/HelloWorld_signed.shortcut
open /tmp/HelloWorld_signed.shortcut   # import / confirm run
```

Then append a row to `MATRIX.md` (create if missing) with:

| Golden | macOS | iOS | Shortcuts build | Date | Result | Notes |
|--------|-------|-----|-----------------|------|--------|-------|
| 01-hello-world | 15.x | — | … | YYYY-MM-DD | import+run OK | |

Optional: store SHA-256 of the **unsigned XML** only (not personal signed binaries).

## Status

Matrix template ready: [`MATRIX.md`](MATRIX.md).  
No attestations filled yet — complete on Mac via [`MAC_HANDOFF.md`](MAC_HANDOFF.md) / [`LOCAL_FINALIZE.md`](../../LOCAL_FINALIZE.md).

```bash
./scripts/attest_local.sh --hash-only
./scripts/attest_local.sh --open
```
