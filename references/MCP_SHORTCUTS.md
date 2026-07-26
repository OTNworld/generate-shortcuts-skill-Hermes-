# MCP Shortcuts (horizon H1)

Expose repo utilities as MCP tools so agents call **tools** instead of inventing bash.

**Status:** spec + stdio stub (`mcp/shortcuts_mcp_server.py`). Not required for Mac attestation rating.

## Tools

| Tool | Wraps | Args | Notes |
|------|-------|------|-------|
| `shortcuts_validate` | `validate_on_write.sh` | `path` (string), `fix` (bool, optional) | Always safe |
| `shortcuts_remix` | `remix_shortcut.py` | `path`, `replace_text` or `set_name`, `output` optional | Then validate |
| `shortcuts_attest_status` | read `fixtures/attested/results.json` | none | Safe anywhere |
| `shortcuts_attest_run` | `attest_local.sh --auto` | `all` bool optional | **Darwin + Accessibility only** |

### Contracts

- Exit / tool error if script exit ≠ 0.
- Prefer returning **stdout/stderr text** + `ok: bool`.
- Never sign/import on Linux cloud agents (`shortcuts_attest_run` must no-op or error with clear message).

## Cursor MCP install (local)

Add to Cursor MCP settings (example):

```json
{
  "mcpServers": {
    "shortcuts-hermes": {
      "command": "python3",
      "args": ["/ABS/PATH/generate-shortcuts-skill-Hermes-/mcp/shortcuts_mcp_server.py"],
      "env": {
        "SHORTCUTS_SKILL_ROOT": "/ABS/PATH/generate-shortcuts-skill-Hermes-"
      }
    }
  }
}
```

Or from repo root:

```bash
SHORTCUTS_SKILL_ROOT="$PWD" python3 mcp/shortcuts_mcp_server.py
```

## Dependencies

Stub uses **stdio JSON-RPC minimal** (no extra pip package) so CI/Linux stay light.
If you later prefer the official `mcp` Python SDK, keep the same tool names.

## Out of scope

- Full ToolKit allowlist validation (peer Viticci)
- iOS device control
- Auto-publishing to markets (see `MARKET_LISTING.md`)
