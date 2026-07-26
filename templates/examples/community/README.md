# Community examples

MIT-vendored goldens from peer projects. Larger / more realistic than teaching goldens.

Attribution: see [`THIRD_PARTY_NOTICES.md`](../../../THIRD_PARTY_NOTICES.md).
Catalog: [`references/ECOSYSTEM.md`](../../../references/ECOSYSTEM.md).

| File | Title | Source |
|------|-------|--------|
| `09-url-cleaner.shortcut.xml` | URL Cleaner | viticci/shortcuts-playground-plugin |
| `10-parse-json-feed.shortcut.xml` | Parse JSON Feed | viticci/shortcuts-playground-plugin |
| `11-invert-names.shortcut.xml` | Invert Names | viticci/shortcuts-playground-plugin |
| `12-days-in-a-month.shortcut.xml` | Days In a Month | viticci/shortcuts-playground-plugin |
| `13-electricity-price.shortcut.xml` | Electricity Price | viticci/shortcuts-playground-plugin |
| `14-preview-folder-contents.shortcut.xml` | Preview Folder Contents | viticci (files / picker) |
| `15-masto-redirect.shortcut.xml` | Masto-Redirect | viticci (HTTP / detect / URL) |
| `16-calendar-locations.shortcut.xml` | Calendar Locations | viticci (calendar filter) |

More upstream titles: `data/external/viticci-playground-goldens.index.jsonl` (19).  
**Not vendored (11):** `data/external/viticci-gaps.jsonl` — refresh via `./scripts/refresh_external_indexes.sh`.

Next lean vendor candidates (offline-friendly): *Create Calendar Event from Template*, *Select Folder, Compress, and Share* — avoid Evernote/Toggl API goldens unless a user needs them.

Agents: prefer `01`–`08` + `templates/palette/` for minimal patterns; use community when the user needs realism (HTTP, calendar math, text transforms).
