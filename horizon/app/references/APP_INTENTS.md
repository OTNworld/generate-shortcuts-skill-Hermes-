# App Intents — Horizon-owned

## Principle

Ship **app-owned** intents. Do **not** invent Apple system `AppIntentIdentifier`s.
Skill watchlist (`APPINTENTS_GAP.md`) is export-diff only.

## MVP intents

| Intent | Parameters | Side effect |
|--------|------------|-------------|
| `InstallPackageIntent` | `packageId: String` | Shortcuts import flow |
| `RunPackageIntent` | `packageId: String` | `run-shortcut` |
| `BrowseCatalogIntent` | none | Open catalog tab |

Use `AppEntity` for `HorizonPackageEntity` (id, name, modelPolicy) when useful for
disambiguation in Siri.

## AppShortcutsProvider

- Register phrases from installed packages’ `siri_phrases` (cap N per release).
- Include static fallbacks: “Open Horizon catalog”, “Run Hello World in Horizon”.
- Follow peer skill guidance (AppShortcutsProvider + applicationName rules) via
  linked `app-intents` skill — do not copy GPL/large dumps.

## Testing

- Intent metadata appears in Shortcuts app after install.
- Simulator: intents runnable from Shortcuts ; Siri optional.
- Device: one phrase smoke per H-F9.

## External skill pointers

See [`../sources.json`](../sources.json) entries `n0an-app-intents-agent-skill` and
`laramarcodes-ios-dev-skill`.
