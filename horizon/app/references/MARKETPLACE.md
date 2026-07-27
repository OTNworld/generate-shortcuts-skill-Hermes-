# Marketplace runtime

## Catalog source

Primary: `Vendor/SkillPackages/` produced by fetch CI.  
Each folder = one `horizon-package/v1` package.

Optional `catalog.json`:

```json
{
  "schema": "horizon-catalog/v1",
  "skill_ref": "v1.16.0",
  "packages": ["hello-world", "clipboard-set", "local-ask-llm", "local-rewrite"]
}
```

## Install trust UX

| attestation.status | Badge | Default CTA |
|--------------------|-------|-------------|
| unattested | Neutral | Install with warning |
| mac-import | Info | Install |
| mac-run | Strong | Install + Run |
| ios-sample | Info | Install (device noted) |

Never upgrade a badge beyond the manifest.

## Install algorithm (MVP)

1. Resolve primary shortcut file under Vendor.
2. Copy to a temporary `file://` or share via UIDocument / Shortcuts import URL.
3. Prefer `shortcuts://import-shortcut?url=…&name=…` when a reachable URL exists ;
   otherwise present Share Sheet / “Open in Shortcuts”.
4. On success heuristic (user return / intent confirmation): write SwiftData row.

Signing: production path may rely on skill-signed artifacts later ; MVP may import
unsigned XML that Shortcuts will ask the user to allow.

## Run algorithm

1. Resolve installed name (`output_name` or package `name`).
2. `shortcuts://run-shortcut?name=<encoded>`.
3. Record `lastRunAt`.

## Personalization (P2+)

- Favorites flag on `InstalledPackage`
- Override Siri phrase locally without mutating Vendor manifest
