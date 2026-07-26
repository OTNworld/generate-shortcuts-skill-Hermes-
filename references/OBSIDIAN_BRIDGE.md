# Obsidian Bridge

Optional conventions when this Shortcuts skill is used together with an Obsidian vault
(iCloud). **Not required** for generating plain `.shortcut` files.

## Locally track — abandoned

The **Locally → Obsidian** golden / stub path is **abandoned** (2026-07-26).

| Artifact | Status |
|----------|--------|
| `templates/locally-obsidian.stub.xml` | Kept as historical **non-importable** stub only — do not extend, sign, or attest |
| Product replacement | Companion app + Siri + local-model marketplace — see [`HORIZON.md`](HORIZON.md) |

Do not open roadmap items to “finish” Locally attestation.

## When to use this bridge

- User asks to store project notes, starters, or proof captures in Obsidian
- Bridging Shortcuts ↔ vault via `obsidian://` URL schemes ([`URL_SCHEMES.md`](URL_SCHEMES.md))

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
- Prefer attested exports from `templates/examples/` — never the abandoned Locally stub

## Related

- Horizon product direction: [`HORIZON.md`](HORIZON.md)
- Importable patterns: `templates/examples/`
- Failure playbook: `FAILURE_MODES.md`
- URL schemes: `URL_SCHEMES.md`
