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
import signal
import subprocess
from pathlib import Path

from mcp.server.fastmcp import FastMCP

ROOT = Path(os.environ.get("SHORTCUTS_SKILL_ROOT", Path(__file__).resolve().parents[1]))
mcp = FastMCP("shortcuts-hermes")

# Keep MCP tool calls responsive: never block the client for many minutes.
DEFAULT_TIMEOUT_SEC = 90
ATTEST_AUTO_TIMEOUT_SEC = 90
ATTEST_HASH_TIMEOUT_SEC = 60


def _run(args: list[str], timeout: int = DEFAULT_TIMEOUT_SEC) -> str:
    """Run a subprocess; on timeout, kill the whole process group (bash children too)."""
    try:
        proc = subprocess.Popen(
            args,
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            start_new_session=True,
        )
    except Exception as e:
        return json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False, indent=2)

    try:
        stdout, stderr = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            stdout, stderr = proc.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            stdout, stderr = proc.communicate()
        return json.dumps(
            {
                "ok": False,
                "error": (
                    f"timeout after {timeout}s — process group killed. "
                    "For full Mac UI attest use scripts/attest_local.sh --auto in a terminal, "
                    "or call shortcuts_attest_run with mode='auto' and a higher timeout_sec."
                ),
                "stdout": (stdout or "")[-2000:],
                "stderr": (stderr or "")[-2000:],
            },
            ensure_ascii=False,
            indent=2,
        )
    except Exception as e:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        return json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False, indent=2)

    payload = {
        "ok": proc.returncode == 0,
        "returncode": proc.returncode,
        "stdout": (stdout or "")[-8000:],
        "stderr": (stderr or "")[-4000:],
    }
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
    """Lean text remix of an existing shortcut XML, then validate_on_write.

    replace_text: either 'OLD=NEW' or pass two segments separated by the first '='.
    """
    cmd = ["python3", str(ROOT / "scripts" / "remix_shortcut.py"), path]
    if replace_text:
        if "=" not in replace_text:
            return json.dumps(
                {
                    "ok": False,
                    "error": "replace_text must look like OLD=NEW",
                },
                indent=2,
            )
        old, new = replace_text.split("=", 1)
        cmd.extend(["--replace-text", old, new])
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
def shortcuts_attest_run(
    mode: str = "hash-only",
    all: bool = False,
    timeout_sec: int | None = None,
) -> str:
    """Attest helper. Default mode=hash-only (fast). mode=auto is Mac UI + long runs.

    Modes:
      - status: same as shortcuts_attest_status (instant)
      - hash-only: write fixtures/attested/hashes.sha256 (default, ~seconds)
      - auto: attest_local.sh --auto (Darwin + Accessibility; capped timeout)
    """
    mode_n = (mode or "hash-only").strip().lower()
    if mode_n == "status":
        return shortcuts_attest_status()

    if mode_n == "hash-only":
        cmd = [
            "bash",
            str(ROOT / "scripts" / "attest_local.sh"),
            "--hash-only",
            "--no-results",
        ]
        if all:
            cmd.append("--all")
        return _run(cmd, timeout=timeout_sec or ATTEST_HASH_TIMEOUT_SEC)

    if mode_n == "auto":
        if platform.system() != "Darwin":
            return json.dumps(
                {
                    "ok": False,
                    "error": "shortcuts_attest_run mode=auto requires macOS (Darwin)",
                },
                indent=2,
            )
        cmd = ["bash", str(ROOT / "scripts" / "attest_local.sh"), "--auto"]
        if all:
            cmd.append("--all")
        # Cap so MCP clients never hang for 10+ minutes (previous default was 600s).
        return _run(cmd, timeout=timeout_sec or ATTEST_AUTO_TIMEOUT_SEC)

    return json.dumps(
        {
            "ok": False,
            "error": f"unknown mode {mode!r}; use status | hash-only | auto",
        },
        indent=2,
    )


if __name__ == "__main__":
    mcp.run(transport="stdio")
