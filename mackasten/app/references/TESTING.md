# Testing strategy

## Pyramid

```text
Linux CI          fetch + schema + python/shell guards
     ↑
Swift unit        decode, policy, URL, deep link (Mac)
     ↑
Simulator smoke   catalog / install CTA / deep link sheet
     ↑
Device            Shortcuts import/run + Siri + Apple Intelligence
```

## Fixtures

Ship golden JSON copies under `Tests/Fixtures/packages/` (copied from skill seed)
so unit tests do not require network.

## Naming

Swift Testing `@Test` names mirror requirement IDs when practical:
`hF5_deepLinkRejectsTraversal`.

## What Linux must never claim

- xcodebuild success
- Simulator screenshots
- Siri / on-device model runs
- Shortcuts import attestation

## Manual script (Simulator)

1. Fetch packages → xcodegen → Run.
2. Catalog shows 4 rows.
3. Open hello-world → Install → complete system UI.
4. Run → confirm Hello World result.
5. Safari or `xcrun simctl openurl` with `hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml`.
6. Confirm sheet ; send malicious path ; confirm reject.
