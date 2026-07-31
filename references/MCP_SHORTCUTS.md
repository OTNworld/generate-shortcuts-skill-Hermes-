# MCP Shortcuts (mackasten H1)

Expose repo utilities as MCP tools so agents call **tools** instead of inventing bash.

**Status:** FastMCP stdio server in `mcp_server/` + Cursor `mcp.json` entries.

## Tools

| Tool | Wraps | Args | Notes |
|------|-------|------|-------|
| `shortcuts_validate` | `validate_on_write.sh` | `path` (string), `fix` (bool, optional) | Always safe |
| `shortcuts_remix` | `remix_shortcut.py` | `path`, `replace_text` as `OLD=NEW`, `set_name`, `output` optional | Then validate |
| `shortcuts_attest_status` | read `fixtures/attested/results.json` | none | Safe anywhere |
| `shortcuts_attest_run` | `attest_local.sh` by `mode` | `mode`=`status`\|`hash-only`\|`auto` (default **`hash-only`**), `all` bool, `timeout_sec` optional | Default is fast; `auto` is Darwin+AX and **timeout-capped** (kills process group) |

### Contracts

- Exit / tool error if script exit ≠ 0.
- Prefer returning **stdout/stderr text** + `ok: bool`.
- Never sign/import on Linux cloud agents (`mode=auto` must error with a clear message).
- MCP tools must return promptly: default `hash-only`; `auto` uses a short timeout (default 90s) and kills the bash process group on expiry so the client does not freeze. For a full unattended Mac loop, run `./scripts/attest_local.sh --auto` in a terminal instead of MCP.

## Cursor install (done on this machine)

**User** `~/.cursor/mcp.json` and **project** `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "shortcuts-hermes": {
      "command": "/Users/ps/Developer/generate-shortcuts-skill-Hermes-/mcp_server/run.sh",
      "args": [],
      "env": {
        "SHORTCUTS_SKILL_ROOT": "/Users/ps/Developer/generate-shortcuts-skill-Hermes-"
      }
    }
  }
}
```

One-time venv (gitignored):

```bash
/opt/homebrew/bin/python3 -m venv .venv-mcp
.venv-mcp/bin/pip install -r mcp_server/requirements.txt
```

Reload MCP in Cursor (Settings → MCP → refresh / restart) if tools do not appear.

## Out of scope

- Full ToolKit allowlist validation (peer Viticci)
- iOS device control
- Auto-publishing to markets (see `MARKET_LISTING.md`)
