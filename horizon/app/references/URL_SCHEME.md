# URL schemes — Horizon + Shortcuts

## Horizon (app-owned)

Registered in Info.plist URL types:

| Scheme | Host | Query | Behavior |
|--------|------|-------|----------|
| `hermes-shortcuts` | `edit` | `path=<repo-relative>` | Show edit bridge sheet |

Example:

```text
hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml
```

### Path rules

- Must be relative (no leading `/`).
- Reject `..` segments and backslashes.
- Allowlist prefixes MVP: `templates/`, `horizon/`.
- Display `edit.skill_path` when present in package.

## Apple Shortcuts (external)

Documented forms (encode values):

| Purpose | URL |
|---------|-----|
| Import | `shortcuts://import-shortcut?url=<encoded>&name=<encoded>` |
| Run | `shortcuts://run-shortcut?name=<encoded>` |
| Run + text | `…&input=text&text=<encoded>` |
| Open | `shortcuts://open-shortcut?name=<encoded>` |

Canonical Apple guide: support.apple.com Shortcuts URL schemes.  
Skill mirror: `references/URL_SCHEMES.md` in the skill repo.

## x-callback (optional P2)

Use when Horizon needs success/failure return:

```text
shortcuts://x-callback-url/run-shortcut?name=…&x-success=…&x-error=…
```

Success URL should open back into Horizon (`hermes-shortcuts://` or `horizon://` if added).
