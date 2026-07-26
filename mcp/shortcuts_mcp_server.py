#!/usr/bin/env python3
"""Minimal stdio MCP server wrapping Shortcuts skill scripts (horizon H1).

No third-party deps. Set SHORTCUTS_SKILL_ROOT to the repo root (default: parent of mcp/).
See references/MCP_SHORTCUTS.md.
"""

from __future__ import annotations

import json
import os
import platform
import subprocess
import sys
from pathlib import Path

ROOT = Path(os.environ.get("SHORTCUTS_SKILL_ROOT", Path(__file__).resolve().parents[1]))


def reply(msg_id, result=None, error=None):
    payload = {"jsonrpc": "2.0", "id": msg_id}
    if error is not None:
        payload["error"] = error
    else:
        payload["result"] = result
    sys.stdout.write(json.dumps(payload) + "\n")
    sys.stdout.flush()


def run_cmd(args: list[str], timeout: int = 120) -> dict:
    try:
        p = subprocess.run(
            args,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return {
            "ok": p.returncode == 0,
            "returncode": p.returncode,
            "stdout": p.stdout[-8000:],
            "stderr": p.stderr[-4000:],
        }
    except subprocess.TimeoutExpired as e:
        return {"ok": False, "error": f"timeout after {timeout}s", "stdout": (e.stdout or "")[-2000:]}
    except Exception as e:
        return {"ok": False, "error": str(e)}


TOOLS = [
    {
        "name": "shortcuts_validate",
        "description": "Validate a Shortcuts plist/XML via validate_on_write.sh (optional --fix Craig Loop lite).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "Path to .shortcut.xml relative to repo or absolute"},
                "fix": {"type": "boolean", "description": "Apply safe mechanical fixes", "default": False},
            },
            "required": ["path"],
        },
    },
    {
        "name": "shortcuts_remix",
        "description": "Lean text remix of an existing shortcut XML (replace-text and/or set-name).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "replace_text": {"type": "string", "description": "old=new (passed to remix_shortcut.py)"},
                "set_name": {"type": "string"},
                "output": {"type": "string"},
            },
            "required": ["path"],
        },
    },
    {
        "name": "shortcuts_attest_status",
        "description": "Read fixtures/attested/results.json summary (safe on any OS).",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "shortcuts_attest_run",
        "description": "Run attest_local.sh --auto (macOS + Accessibility only).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "all": {"type": "boolean", "default": False},
            },
        },
    },
]


def call_tool(name: str, arguments: dict | None) -> dict:
    args = arguments or {}
    if name == "shortcuts_validate":
        path = args.get("path") or ""
        cmd = ["bash", str(ROOT / "scripts" / "validate_on_write.sh")]
        if args.get("fix"):
            cmd.append("--fix")
        cmd.append(path)
        return run_cmd(cmd)
    if name == "shortcuts_remix":
        path = args.get("path") or ""
        cmd = ["python3", str(ROOT / "scripts" / "remix_shortcut.py"), path]
        if args.get("replace_text"):
            cmd.extend(["--replace-text", args["replace_text"]])
        if args.get("set_name"):
            cmd.extend(["--set-name", args["set_name"]])
        if args.get("output"):
            cmd.extend(["--output", args["output"]])
        out = run_cmd(cmd)
        if out.get("ok"):
            target = args.get("output") or path
            v = run_cmd(["bash", str(ROOT / "scripts" / "validate_on_write.sh"), target])
            out["validate"] = v
            out["ok"] = bool(v.get("ok"))
        return out
    if name == "shortcuts_attest_status":
        p = ROOT / "fixtures" / "attested" / "results.json"
        if not p.is_file():
            return {"ok": False, "error": f"missing {p}"}
        data = json.loads(p.read_text(encoding="utf-8"))
        return {
            "ok": bool(data.get("pass")),
            "schema": data.get("schema"),
            "skill_version": data.get("skill_version"),
            "import_tally": (data.get("import") or {}).get("tally"),
            "run_tally": (data.get("run") or {}).get("tally"),
            "pass": data.get("pass"),
        }
    if name == "shortcuts_attest_run":
        if platform.system() != "Darwin":
            return {"ok": False, "error": "shortcuts_attest_run requires macOS (Darwin)"}
        cmd = ["bash", str(ROOT / "scripts" / "attest_local.sh"), "--auto"]
        if args.get("all"):
            cmd.append("--all")
        return run_cmd(cmd, timeout=600)
    return {"ok": False, "error": f"unknown tool {name}"}


def handle(msg: dict) -> None:
    mid = msg.get("id")
    method = msg.get("method")
    if method == "initialize":
        reply(
            mid,
            {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "shortcuts-hermes", "version": "0.1.0"},
            },
        )
        return
    if method == "notifications/initialized":
        return
    if method == "tools/list":
        reply(mid, {"tools": TOOLS})
        return
    if method == "tools/call":
        params = msg.get("params") or {}
        name = params.get("name")
        result = call_tool(name, params.get("arguments"))
        text = json.dumps(result, ensure_ascii=False, indent=2)
        reply(
            mid,
            {
                "content": [{"type": "text", "text": text}],
                "isError": not bool(result.get("ok")),
            },
        )
        return
    if method == "ping":
        reply(mid, {})
        return
    if mid is not None:
        reply(mid, error={"code": -32601, "message": f"Method not found: {method}"})


def main() -> None:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(msg, dict) and "method" in msg:
            handle(msg)


if __name__ == "__main__":
    main()
