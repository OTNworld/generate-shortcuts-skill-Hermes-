#!/usr/bin/env python3
"""Shortcuts Hermes MCP server (FastMCP stdio).

Run via project venv:
  .venv-mcp/bin/python mcp_server/shortcuts_mcp_server.py

See references/MCP_SHORTCUTS.md.
"""

from __future__ import annotations

import json
import os
import platform
import subprocess
from pathlib import Path

from mcp.server.fastmcp import FastMCP

ROOT = Path(os.environ.get("SHORTCUTS_SKILL_ROOT", Path(__file__).resolve().parents[1]))
mcp = FastMCP("shortcuts-hermes")


def _run(args: list[str], timeout: int = 120) -> str:
    try:
        p = subprocess.run(
            args,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        payload = {
            "ok": p.returncode == 0,
            "returncode": p.returncode,
            "stdout": (p.stdout or "")[-8000:],
            "stderr": (p.stderr or "")[-4000:],
        }
    except subprocess.TimeoutExpired as e:
        payload = {
            "ok": False,
            "error": f"timeout after {timeout}s",
            "stdout": ((e.stdout or "") if isinstance(e.stdout, str) else "")[-2000:],
        }
    except Exception as e:
        payload = {"ok": False, "error": str(e)}
    return json.dumps(payload, ensure_ascii=False, indent=2)


@mcp.tool()
def shortcuts_validate(path: str, fix: bool = False) -> str:
    """Validate a Shortcuts plist/XML via validate_on_write.sh (optional Craig Loop --fix)."""
    cmd = ["bash", str(ROOT / "scripts" / "validate_on_write.sh")]
    if fix:
        cmd.append("--fix")
    cmd.append(path)
    return _run(cmd)


@mcp.tool()
def shortcuts_remix(
    path: str,
    replace_text: str | None = None,
    set_name: str | None = None,
    output: str | None = None,
) -> str:
    """Lean text remix of an existing shortcut XML, then validate_on_write."""
    cmd = ["python3", str(ROOT / "scripts" / "remix_shortcut.py"), path]
    if replace_text:
        cmd.extend(["--replace-text", replace_text])
    if set_name:
        cmd.extend(["--set-name", set_name])
    if output:
        cmd.extend(["--output", output])
    remix_out = json.loads(_run(cmd))
    if not remix_out.get("ok"):
        return json.dumps(remix_out, ensure_ascii=False, indent=2)
    target = output or path
    validate_out = json.loads(
        _run(["bash", str(ROOT / "scripts" / "validate_on_write.sh"), target])
    )
    remix_out["validate"] = validate_out
    remix_out["ok"] = bool(validate_out.get("ok"))
    return json.dumps(remix_out, ensure_ascii=False, indent=2)


@mcp.tool()
def shortcuts_attest_status() -> str:
    """Read fixtures/attested/results.json summary (safe on any OS)."""
    p = ROOT / "fixtures" / "attested" / "results.json"
    if not p.is_file():
        return json.dumps({"ok": False, "error": f"missing {p}"}, indent=2)
    data = json.loads(p.read_text(encoding="utf-8"))
    return json.dumps(
        {
            "ok": bool(data.get("pass")),
            "schema": data.get("schema"),
            "skill_version": data.get("skill_version"),
            "import_tally": (data.get("import") or {}).get("tally"),
            "run_tally": (data.get("run") or {}).get("tally"),
            "pass": data.get("pass"),
        },
        ensure_ascii=False,
        indent=2,
    )


@mcp.tool()
def shortcuts_attest_run(all: bool = False) -> str:
    """Run attest_local.sh --auto (macOS + Accessibility only)."""
    if platform.system() != "Darwin":
        return json.dumps(
            {"ok": False, "error": "shortcuts_attest_run requires macOS (Darwin)"},
            indent=2,
        )
    cmd = ["bash", str(ROOT / "scripts" / "attest_local.sh"), "--auto"]
    if all:
        cmd.append("--all")
    return _run(cmd, timeout=600)


if __name__ == "__main__":
    mcp.run(transport="stdio")
