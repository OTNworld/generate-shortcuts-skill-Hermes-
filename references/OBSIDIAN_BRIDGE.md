# Obsidian Bridge

Optional conventions when this Shortcuts skill is used together with an Obsidian vault
(iCloud). **Not required** for generating plain `.shortcut` files.

## When to use

- User asks to store project notes, starters, or proof captures in Obsidian
- Bridging Shortcuts ↔ vault via `obsidian://` URL schemes
- Locally / AI → note append workflows

## Vault layout

```
Projets/<Nom du projet>/
  index.md
  idée/
  plans/
  starters/          # .shortcut sources
  templates/
  assets/            # screenshots, exports — never at project root
Projets/delegation-workflow.md
```

Rules:
- Media only under `assets/`
- Link members from `index.md` and idée notes
- Update the Daily note with paths worked on

## Shortcuts ↔ Obsidian

- After saving a note to iCloud, `openurl` with `obsidian://open?...` if the app is installed
- Prefer attested exports over the design stub `templates/locally-obsidian.stub.xml`
- Stub is **non-importable**; see banner comment in that file

## Related goldens

- Importable patterns: `templates/examples/`
- Failure playbook: `FAILURE_MODES.md`
- URL details (planned for 10/10): `URL_SCHEMES.md` when added
