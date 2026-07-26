# Third-Party Notices

This skill is MIT-licensed (see [LICENSE](LICENSE)). The following third-party
materials are referenced or selectively vendored.

## Upstream lineage

### drewocarr/generate-shortcuts-skill

- Role: historical lineage (docs layout / early action catalog inspiration)
- Upstream: https://github.com/drewocarr/generate-shortcuts-skill
- License: **unspecified / unknown** (as recorded in `data/sources.json`)
- Use: **link only** — this MIT LICENSE covers *this* repository’s original work
  and MIT-compatible vendored community goldens; it does **not** assert that the
  upstream project is MIT.

## Vendored under MIT

### viticci/shortcuts-playground-plugin

- Copyright (c) 2026 Federico Viticci / MacStories
- License: MIT
- Upstream: https://github.com/viticci/shortcuts-playground-plugin
- Vendored files:
  - `templates/examples/community/09-url-cleaner.shortcut.xml`
  - `templates/examples/community/10-parse-json-feed.shortcut.xml`
  - `templates/examples/community/11-invert-names.shortcut.xml`
  - `templates/examples/community/12-days-in-a-month.shortcut.xml`
  - `templates/examples/community/13-electricity-price.shortcut.xml`
  - `templates/examples/community/14-preview-folder-contents.shortcut.xml`
  - `templates/examples/community/15-masto-redirect.shortcut.xml`
  - `templates/examples/community/16-calendar-locations.shortcut.xml`
  - `data/external/viticci-playground-goldens.index.jsonl` (index metadata)
- Adapted documentation patterns may appear in `references/URL_SCHEMES.md`
  (cross-checked with Apple’s Shortcuts User Guide).

## Cited / adapted (not wholesale copied)

### sebj/iOS-Shortcuts-Reference

- Upstream: https://github.com/sebj/iOS-Shortcuts-Reference (archived)
- Used for: icon ARGB color table corrections, `WFWorkflowTypes` / input class names,
  classic URL scheme inventory (see `references/PLIST_FORMAT.md`, `URL_SCHEMES.md`).

## Link-only (do not vendor code)

| Project | License | Why link-only |
|---------|---------|---------------|
| [joshfarrant/shortcuts-js](https://github.com/joshfarrant/shortcuts-js) | GPL-3.0 | Copyleft incompatible with vendoring into MIT skill code |
| [drewburchfield/shortcuts-toolkit](https://github.com/drewburchfield/shortcuts-toolkit) | unspecified | Reference notes only |
| [drewocarr/generate-shortcuts-skill](https://github.com/drewocarr/generate-shortcuts-skill) | unspecified | Lineage / comparison |
| Apple Shortcuts User Guide | Apple | Official URL scheme docs |

See also [`data/sources.json`](data/sources.json) and [`references/ECOSYSTEM.md`](references/ECOSYSTEM.md).
