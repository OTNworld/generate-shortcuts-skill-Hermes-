# Local models & Apple Intelligence

## model_policy mapping

| Policy | App behavior |
|--------|----------------|
| `none` | No model UI |
| `apple-intelligence` | Prefer system AI actions inside the shortcut ; gate CTA if device lacks AI |
| `on-device-preferred` | Same + refuse silent cloud fallback in Mackasten-owned calls |
| `cloud-allowed` | Allowed only if package id does **not** start with `local-` ; require consent banner |

## Capability detection

- Check Foundation Models / Apple Intelligence availability APIs for the deployment OS.
- Simulator: treat as **unavailable** unless proven otherwise ; show explanation copy.
- Never crash if model missing — degrade to “Install shortcut only”.

## Mackasten-owned vs shortcut-owned inference

MVP: inference stays **inside Shortcuts** (Ask LLM / Rewrite goldens).  
`ModelRouter` is a **policy + UX gate**, not a second LLM stack.

Post-MVP: optional in-app Foundation Models for browse-time demos — still respect policy.

## Security

- No API keys in app for cloud LLM in MVP.
- Do not embed user vault/notes into cloud prompts by default.
