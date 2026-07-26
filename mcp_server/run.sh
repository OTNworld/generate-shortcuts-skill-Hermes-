#!/usr/bin/env bash
# Cursor / local launcher for shortcuts-hermes MCP (uses project .venv-mcp).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SHORTCUTS_SKILL_ROOT="${SHORTCUTS_SKILL_ROOT:-$ROOT}"
PY="${ROOT}/.venv-mcp/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "Missing $PY — run: /opt/homebrew/bin/python3 -m venv .venv-mcp && .venv-mcp/bin/pip install 'mcp>=1.28'" >&2
  exit 1
fi
exec "$PY" "${ROOT}/mcp_server/shortcuts_mcp_server.py"
