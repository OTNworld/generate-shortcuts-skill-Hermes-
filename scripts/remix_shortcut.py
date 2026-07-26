#!/usr/bin/env python3
"""Surgical remix helpers for Shortcuts plist XML (lean Viticci-parity MVP)."""

from __future__ import annotations

import argparse
import plistlib
import sys
from pathlib import Path


def walk_replace(obj, replacements: list[tuple[str, str]], stats: dict) -> object:
    if isinstance(obj, dict):
        return {k: walk_replace(v, replacements, stats) for k, v in obj.items()}
    if isinstance(obj, list):
        return [walk_replace(v, replacements, stats) for v in obj]
    if isinstance(obj, str):
        out = obj
        for old, new in replacements:
            if old in out:
                count = out.count(old)
                out = out.replace(old, new)
                stats["replacements"] = stats.get("replacements", 0) + count
                stats.setdefault("pairs", []).append((old, new, count))
        return out
    return obj


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input", type=Path, help="Source .shortcut.xml / plist")
    ap.add_argument("--output", type=Path, help="Destination path (default: in-place)")
    ap.add_argument(
        "--replace-text",
        nargs=2,
        metavar=("OLD", "NEW"),
        action="append",
        default=[],
        help="Replace exact substring in string values (repeatable)",
    )
    ap.add_argument("--set-name", metavar="NAME", help="Set WFWorkflowName")
    ap.add_argument("--dry-run", action="store_true", help="Plan only; do not write")
    args = ap.parse_args()

    if not args.replace_text and not args.set_name:
        ap.error("Need at least one of --replace-text / --set-name")

    raw = args.input.read_bytes()
    try:
        data = plistlib.loads(raw)
    except Exception as e:
        print(f"FAIL load plist: {e}", file=sys.stderr)
        return 2

    stats: dict = {"replacements": 0, "pairs": []}
    if args.replace_text:
        data = walk_replace(data, [(a, b) for a, b in args.replace_text], stats)

    if args.set_name:
        old = data.get("WFWorkflowName")
        data["WFWorkflowName"] = args.set_name
        stats.setdefault("pairs", []).append(("WFWorkflowName", f"{old}→{args.set_name}", 1))
        stats["replacements"] = stats.get("replacements", 0) + 1

    print(f"input: {args.input}")
    print(f"replacements: {stats.get('replacements', 0)}")
    for old, new, count in stats.get("pairs", []):
        print(f"  [{count}x] {old!r} → {new!r}")

    if stats.get("replacements", 0) == 0:
        print("FAIL: nothing changed", file=sys.stderr)
        return 1

    if args.dry_run:
        print("dry-run: no write")
        return 0

    out = args.output or args.input
    out.parent.mkdir(parents=True, exist_ok=True)
    # Prefer XML1 for teaching goldens
    out.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_XML))
    print(f"wrote: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
