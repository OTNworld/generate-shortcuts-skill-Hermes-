# URL Schemes and x-callback-url

Use Apple-documented Shortcuts URL forms. Do not invent `shortcuts://` routes
unless the user provides working evidence from their device.

Canonical guide: [Apple — Use URL schemes](https://support.apple.com/guide/shortcuts/use-url-schemes-apd621a1ad7a/ios).
Peer notes also in [sebj/iOS-Shortcuts-Reference](https://github.com/sebj/iOS-Shortcuts-Reference)
and [viticci playground URL_SCHEMES](https://github.com/viticci/shortcuts-playground-plugin) (MIT).

## Documented Shortcuts URLs

URL-encode all query values.

| Purpose | URL |
|---------|-----|
| Open Shortcuts | `shortcuts://` |
| Create shortcut | `shortcuts://create-shortcut` |
| Open by name | `shortcuts://open-shortcut?name=<encoded>` |
| Run by name | `shortcuts://run-shortcut?name=<encoded>` |
| Run with text | `shortcuts://run-shortcut?name=<encoded>&input=text&text=<encoded>` |
| Run with clipboard | `shortcuts://run-shortcut?name=<encoded>&input=clipboard` |
| Gallery | `shortcuts://gallery` |
| Gallery search | `shortcuts://gallery/search?query=<encoded>` |
| Import from URL | `shortcuts://import-shortcut?url=<encoded>&name=<encoded>` (optional `silent=true`) |

Inside Shortcuts, prefer **Run Shortcut** (`runworkflow`) over `shortcuts://run-shortcut`
when chaining. Use URL schemes for **external** callers (apps, CLI, task managers).

## x-callback-url

```text
shortcuts://x-callback-url/run-shortcut?name=<encoded>&input=text&text=<encoded>&x-success=<encoded>&x-cancel=<encoded>&x-error=<encoded>
```

| Parameter | Behavior |
|-----------|----------|
| `x-success` | After success; Shortcuts may append `result=` |
| `x-cancel` | User cancelled |
| `x-error` | Failure; may append `errorMessage=` |

Encode the callback URL itself (e.g. `myapp://done` → `myapp%3A%2F%2Fdone`).

## Building in a generated shortcut

1. `is.workflow.actions.url` to assemble the URL (encode user pieces first)
2. `is.workflow.actions.openurl` to launch
3. Or `is.workflow.actions.openxcallbackurl` when callbacks matter

## Obsidian / third-party

App-specific schemes (`obsidian://…`, etc.) are outside Apple’s Shortcuts docs.
Document them in `OBSIDIAN_BRIDGE.md` / future bridge notes; always verify on device.
