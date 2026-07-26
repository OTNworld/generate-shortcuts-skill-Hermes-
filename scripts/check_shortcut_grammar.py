#!/usr/bin/env python3
"""Deeper shortcut grammar checks (10/10 prep).

Current `scripts/validate.sh` covers XML + coarse heuristics.
This module adds per-node and balance checks intended to become CI-blocking
once goldens are macOS-attested.

Usage:
  python3 scripts/check_shortcut_grammar.py templates/examples/*.xml
  python3 scripts/check_shortcut_grammar.py --strict templates/examples/
"""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

FFFC = "\ufffc"
UUID_RE = re.compile(
    r"^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$"
)
CONTROL_FLOW_IDS = {
    "is.workflow.actions.choosefrommenu",
    "is.workflow.actions.conditional",
    "is.workflow.actions.repeat.count",
    "is.workflow.actions.repeat.each",
}


def dict_to_map(d: ET.Element) -> dict:
    """Best-effort plist dict → python dict (strings/ints/nested dicts/arrays)."""
    out = {}
    key = None
    for child in list(d):
        if child.tag == "key":
            key = child.text or ""
            continue
        if key is None:
            continue
        out[key] = parse_value(child)
        key = None
    return out


def parse_value(el: ET.Element):
    if el.tag == "string":
        return el.text or ""
    if el.tag == "integer":
        return int(el.text or "0")
    if el.tag == "real":
        return float(el.text or "0")
    if el.tag == "true":
        return True
    if el.tag == "false":
        return False
    if el.tag == "dict":
        return dict_to_map(el)
    if el.tag == "array":
        return [parse_value(c) for c in list(el)]
    return None


def iter_actions(root: ET.Element):
    # Root plist > dict > WFWorkflowActions array
    top = root.find("dict")
    if top is None:
        return
    data = dict_to_map(top)
    actions = data.get("WFWorkflowActions") or []
    for action in actions:
        if isinstance(action, dict):
            yield action


def check_file(path: Path, strict: bool) -> list[str]:
    errors: list[str] = []
    try:
        tree = ET.parse(path)
    except ET.ParseError as e:
        return [f"{path}: XML parse error: {e}"]

    root = tree.getroot()
    grouping_modes: dict[str, list[int]] = {}

    for action in iter_actions(root):
        ident = action.get("WFWorkflowActionIdentifier", "")
        params = action.get("WFWorkflowActionParameters") or {}
        if not isinstance(params, dict):
            continue

        if ident == "is.workflow.actions.savefile":
            errors.append(f"{path}: forbidden action id savefile")

        for key, val in params.items():
            if key in {"UUID", "GroupingIdentifier"} and isinstance(val, str):
                if not UUID_RE.match(val):
                    errors.append(f"{path}: non-uppercase-hex UUID in {key}: {val}")

        if ident in CONTROL_FLOW_IDS:
            gid = params.get("GroupingIdentifier")
            mode = params.get("WFControlFlowMode")
            if gid is None:
                errors.append(f"{path}: {ident} missing GroupingIdentifier")
            if mode is None:
                errors.append(f"{path}: {ident} missing WFControlFlowMode")
            elif not isinstance(mode, int):
                errors.append(f"{path}: {ident} WFControlFlowMode must be int, got {mode!r}")
            if isinstance(gid, str) and isinstance(mode, int):
                grouping_modes.setdefault(gid, []).append(mode)

        # FFFC must live inside structures that also declare attachmentsByRange
        def walk(obj, trail: str):
            if isinstance(obj, dict):
                text = obj.get("string")
                if isinstance(text, str) and FFFC in text:
                    if "attachmentsByRange" not in obj:
                        errors.append(
                            f"{path}: U+FFFC at {trail} without attachmentsByRange"
                        )
                for k, v in obj.items():
                    walk(v, f"{trail}.{k}")
            elif isinstance(obj, list):
                for i, v in enumerate(obj):
                    walk(v, f"{trail}[{i}]")
            elif isinstance(obj, str) and FFFC in obj and trail.endswith("WFTextActionText"):
                # bare string gettext with FFFC and no dict wrapper
                errors.append(f"{path}: bare WFTextActionText contains U+FFFC at {trail}")

        walk(params, ident)

    for gid, modes in grouping_modes.items():
        if 0 not in modes or 2 not in modes:
            errors.append(
                f"{path}: control-flow group {gid} missing start(0) or end(2); modes={modes}"
            )
        if strict and modes.count(0) != 1:
            errors.append(f"{path}: group {gid} should have exactly one start; modes={modes}")

    return errors


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("paths", nargs="+", type=Path)
    ap.add_argument(
        "--strict",
        action="store_true",
        help="extra balance checks (intended CI-blocking for 10/10)",
    )
    args = ap.parse_args()

    files: list[Path] = []
    for p in args.paths:
        if p.is_dir():
            files.extend(sorted(p.rglob("*.xml")))
            files.extend(sorted(p.rglob("*.plist")))
        else:
            files.append(p)

    all_errors: list[str] = []
    checked = 0
    for f in files:
        if f.name.endswith(".stub.xml"):
            continue
        checked += 1
        all_errors.extend(check_file(f, strict=args.strict))

    if all_errors:
        for e in all_errors:
            print("FAIL", e)
        print(f"grammar: {len(all_errors)} issue(s) in {checked} file(s)")
        return 1

    print(f"OK  check_shortcut_grammar.py ({checked} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
