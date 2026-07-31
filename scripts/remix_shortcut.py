#!/usr/bin/env python3
"""Surgical + structural remix helpers for Shortcuts plist XML."""

from __future__ import annotations

import argparse
import copy
import json
import plistlib
import sys
import uuid
from pathlib import Path
from typing import Any


def walk_replace(obj: Any, replacements: list[tuple[str, str]], stats: dict) -> Any:
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


def actions_of(data: dict) -> list:
    acts = data.get("WFWorkflowActions")
    if not isinstance(acts, list):
        raise SystemExit("FAIL: missing WFWorkflowActions array")
    return acts


def action_id(action: dict) -> str:
    return str(action.get("WFWorkflowActionIdentifier", ""))


def list_actions(data: dict) -> None:
    for i, a in enumerate(actions_of(data)):
        params = a.get("WFWorkflowActionParameters") or {}
        uid = params.get("UUID", "")
        print(f"{i}\t{action_id(a)}\t{uid}")


def new_uuid() -> str:
    return str(uuid.uuid4()).upper()


def parse_action_json(raw: str) -> dict:
    """Accept full action dict or {identifier, parameters} shorthand."""
    obj = json.loads(raw)
    if not isinstance(obj, dict):
        raise SystemExit("FAIL: --insert-action JSON must be an object")
    if "WFWorkflowActionIdentifier" in obj:
        return obj
    ident = obj.get("identifier") or obj.get("id")
    if not ident:
        raise SystemExit(
            "FAIL: action JSON needs WFWorkflowActionIdentifier or identifier"
        )
    params = obj.get("parameters") or obj.get("WFWorkflowActionParameters") or {}
    if not isinstance(params, dict):
        raise SystemExit("FAIL: parameters must be an object")
    if obj.get("with_uuid") and "UUID" not in params:
        params = {**params, "UUID": new_uuid()}
    return {
        "WFWorkflowActionIdentifier": (
            ident
            if ident.startswith("is.workflow.actions.")
            else f"is.workflow.actions.{ident}"
        ),
        "WFWorkflowActionParameters": params,
    }


def set_param(action: dict, key: str, value_raw: str) -> None:
    params = action.setdefault("WFWorkflowActionParameters", {})
    if not isinstance(params, dict):
        raise SystemExit("FAIL: WFWorkflowActionParameters is not a dict")
    # Try JSON first for structured values; else string / bool / int heuristics
    try:
        value: Any = json.loads(value_raw)
    except json.JSONDecodeError:
        if value_raw.lower() in ("true", "false"):
            value = value_raw.lower() == "true"
        elif value_raw.isdigit() or (value_raw.startswith("-") and value_raw[1:].isdigit()):
            value = int(value_raw)
        else:
            value = value_raw
    params[key] = value


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
    ap.add_argument(
        "--list-actions",
        action="store_true",
        help="Print index, identifier, UUID; then exit (no write)",
    )
    ap.add_argument(
        "--remove-action",
        type=int,
        metavar="INDEX",
        action="append",
        default=[],
        help="Remove action at INDEX (repeatable; applied high→low)",
    )
    ap.add_argument(
        "--insert-action",
        nargs=2,
        metavar=("INDEX", "JSON"),
        action="append",
        default=[],
        help='Insert action JSON at INDEX (e.g. 1 \'{"identifier":"delay","parameters":{"WFDelayTime":1}}\')',
    )
    ap.add_argument(
        "--move-action",
        nargs=2,
        type=int,
        metavar=("FROM", "TO"),
        action="append",
        default=[],
        help="Move action FROM index to TO index (repeatable)",
    )
    ap.add_argument(
        "--set-param",
        nargs=3,
        metavar=("INDEX", "KEY", "VALUE"),
        action="append",
        default=[],
        help="Set parameter KEY on action INDEX (VALUE: JSON or string)",
    )
    ap.add_argument("--dry-run", action="store_true", help="Plan only; do not write")
    args = ap.parse_args()

    structural = bool(
        args.remove_action or args.insert_action or args.move_action or args.set_param
    )
    if (
        not args.replace_text
        and not args.set_name
        and not args.list_actions
        and not structural
    ):
        ap.error(
            "Need at least one of --replace-text / --set-name / --list-actions / "
            "--remove-action / --insert-action / --move-action / --set-param"
        )

    raw = args.input.read_bytes()
    try:
        data = plistlib.loads(raw)
    except Exception as e:
        print(f"FAIL load plist: {e}", file=sys.stderr)
        return 2

    if args.list_actions:
        list_actions(data)
        return 0

    stats: dict = {"replacements": 0, "pairs": [], "ops": []}

    if args.replace_text:
        data = walk_replace(data, [(a, b) for a, b in args.replace_text], stats)

    if args.set_name:
        old = data.get("WFWorkflowName")
        data["WFWorkflowName"] = args.set_name
        stats.setdefault("pairs", []).append(("WFWorkflowName", f"{old}→{args.set_name}", 1))
        stats["replacements"] = stats.get("replacements", 0) + 1

    acts = actions_of(data)

    for idx, key, val in args.set_param:
        i = int(idx)
        if i < 0 or i >= len(acts):
            print(f"FAIL --set-param index {i} out of range 0..{len(acts)-1}", file=sys.stderr)
            return 1
        before = copy.deepcopy(acts[i].get("WFWorkflowActionParameters"))
        set_param(acts[i], key, val)
        stats["ops"].append(f"set-param[{i}].{key}")
        stats["replacements"] += 1
        if before != acts[i].get("WFWorkflowActionParameters"):
            stats.setdefault("pairs", []).append((f"param[{i}].{key}", val[:60], 1))

    # Moves first (on current indices), then removes high→low, then inserts
    for frm, to in args.move_action:
        if frm < 0 or frm >= len(acts) or to < 0 or to >= len(acts):
            print(
                f"FAIL --move-action {frm}->{to} out of range 0..{len(acts)-1}",
                file=sys.stderr,
            )
            return 1
        item = acts.pop(frm)
        acts.insert(to, item)
        stats["ops"].append(f"move {frm}->{to}")
        stats["replacements"] += 1

    for i in sorted(args.remove_action, reverse=True):
        if i < 0 or i >= len(acts):
            print(f"FAIL --remove-action {i} out of range 0..{len(acts)-1}", file=sys.stderr)
            return 1
        removed = acts.pop(i)
        stats["ops"].append(f"remove[{i}] {action_id(removed)}")
        stats["replacements"] += 1

    # Insertions: apply in order; each INDEX is interpreted on the live list
    for idx_s, js in args.insert_action:
        i = int(idx_s)
        action = parse_action_json(js)
        if i < 0 or i > len(acts):
            print(f"FAIL --insert-action index {i} out of range 0..{len(acts)}", file=sys.stderr)
            return 1
        acts.insert(i, action)
        stats["ops"].append(f"insert[{i}] {action_id(action)}")
        stats["replacements"] += 1

    data["WFWorkflowActions"] = acts

    print(f"input: {args.input}")
    print(f"changes: {stats.get('replacements', 0)}")
    for old, new, count in stats.get("pairs", []):
        print(f"  [{count}x] {old!r} → {new!r}")
    for op in stats.get("ops", []):
        print(f"  op: {op}")

    if stats.get("replacements", 0) == 0:
        print("FAIL: nothing changed", file=sys.stderr)
        return 1

    if args.dry_run:
        print("dry-run: no write")
        if structural:
            print("dry-run action list:")
            list_actions(data)
        return 0

    out = args.output or args.input
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_XML))
    print(f"wrote: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
