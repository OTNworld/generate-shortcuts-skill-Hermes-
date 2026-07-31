#!/usr/bin/env python3
"""Shortcut grammar checks for teaching + community goldens.

Usage:
  python3 scripts/check_shortcut_grammar.py templates/
  python3 scripts/check_shortcut_grammar.py --strict templates/
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
RANGE_RE = re.compile(r"^\{(\d+),\s*(\d+)\}$")
CONTROL_FLOW_IDS = {
    "is.workflow.actions.choosefrommenu",
    "is.workflow.actions.conditional",
    "is.workflow.actions.repeat.count",
    "is.workflow.actions.repeat.each",
}
KNOWN_OUTPUT_NAMES = {
    "Text",
    "Provided Input",
    "Response",
    "List",
    "URL",
    "Dictionary",
    "Dictionary Value",
    "File",
    "Weather Conditions",
    "Repeat Index",
    "Repeat Item",
    "Repeat Results",
    "Contents of URL",
    "Updated Variables",
    "Shortcut Input",
    "Chosen Item",
    "Selected Item",
    "Date",
    "Formatted Date",
    "Count",
    "Number",
    "Note",
}


def utf16_len(s: str) -> int:
    """Approximate Shortcuts range indexing (UTF-16 code units)."""
    n = 0
    for ch in s:
        n += 2 if ord(ch) > 0xFFFF else 1
    return n


def dict_to_map(d: ET.Element) -> dict:
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
    top = root.find("dict")
    if top is None:
        return
    data = dict_to_map(top)
    actions = data.get("WFWorkflowActions") or []
    for action in actions:
        if isinstance(action, dict):
            yield action


def check_token_string(path: Path, obj: dict, trail: str, errors: list[str], strict: bool):
    text = obj.get("string")
    attachments = obj.get("attachmentsByRange")
    if not isinstance(text, str):
        return
    if FFFC in text and not isinstance(attachments, dict):
        errors.append(f"{path}: U+FFFC at {trail} without attachmentsByRange")
        return
    if not isinstance(attachments, dict):
        return

    positions = [i for i, ch in enumerate(text) if ch == FFFC]
    # Map codepoint index → UTF-16 index
    cp_to_u16 = {}
    u16 = 0
    for i, ch in enumerate(text):
        cp_to_u16[i] = u16
        u16 += 2 if ord(ch) > 0xFFFF else 1
    text_u16 = u16

    for key, ref in attachments.items():
        m = RANGE_RE.match(str(key))
        if not m:
            errors.append(f"{path}: bad attachmentsByRange key {key!r} at {trail}")
            continue
        pos, length = int(m.group(1)), int(m.group(2))
        if length < 1:
            errors.append(f"{path}: attachmentsByRange length < 1 at {trail} key {key}")
        if pos < 0 or pos + length > text_u16:
            errors.append(
                f"{path}: attachmentsByRange {key} out of bounds "
                f"(utf16_len={text_u16}) at {trail}"
            )
        if isinstance(ref, dict):
            oname = ref.get("OutputName")
            if (
                strict
                and "community" not in path.parts
                and "palette" not in path.parts
                and isinstance(oname, str)
                and oname
                and oname not in KNOWN_OUTPUT_NAMES
            ):
                errors.append(
                    f"{path}: uncommon OutputName {oname!r} at {trail} "
                    f"(ok if attested; prefer known names for teaching goldens)"
                )

    if strict and positions:
        expected = {cp_to_u16[i] for i in positions}
        declared = set()
        for key in attachments:
            m = RANGE_RE.match(str(key))
            if m:
                declared.add(int(m.group(1)))
        if expected - declared:
            errors.append(
                f"{path}: FFFC utf16 positions {sorted(expected - declared)} "
                f"lack attachmentsByRange at {trail}"
            )


def check_file(path: Path, strict: bool) -> list[str]:
    errors: list[str] = []
    try:
        tree = ET.parse(path)
    except ET.ParseError as e:
        return [f"{path}: XML parse error: {e}"]

    root = tree.getroot()
    grouping_modes: dict[str, list[int]] = {}
    menu_items: dict[str, list[str]] = {}
    menu_titles: dict[str, list[str]] = {}

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
                errors.append(
                    f"{path}: {ident} WFControlFlowMode must be int, got {mode!r}"
                )
            if isinstance(gid, str) and isinstance(mode, int):
                grouping_modes.setdefault(gid, []).append(mode)
            if ident == "is.workflow.actions.choosefrommenu" and isinstance(gid, str):
                if mode == 0 and isinstance(params.get("WFMenuItems"), list):
                    menu_items[gid] = [
                        x for x in params["WFMenuItems"] if isinstance(x, str)
                    ]
                if mode == 1 and isinstance(params.get("WFMenuItemTitle"), str):
                    menu_titles.setdefault(gid, []).append(params["WFMenuItemTitle"])

        def walk(obj, trail: str):
            if isinstance(obj, dict):
                if "attachmentsByRange" in obj or (
                    isinstance(obj.get("string"), str) and FFFC in obj.get("string", "")
                ):
                    check_token_string(path, obj, trail, errors, strict)
                for k, v in obj.items():
                    walk(v, f"{trail}.{k}")
            elif isinstance(obj, list):
                for i, v in enumerate(obj):
                    walk(v, f"{trail}[{i}]")
            elif isinstance(obj, str) and FFFC in obj and trail.endswith(
                "WFTextActionText"
            ):
                errors.append(
                    f"{path}: bare WFTextActionText contains U+FFFC at {trail}"
                )

        walk(params, ident)

    for gid, modes in grouping_modes.items():
        if 0 not in modes or 2 not in modes:
            errors.append(
                f"{path}: control-flow group {gid} missing start(0) or end(2); "
                f"modes={modes}"
            )
        if strict and modes.count(0) != 1:
            errors.append(
                f"{path}: group {gid} should have exactly one start; modes={modes}"
            )
        if strict and modes.count(2) != 1:
            errors.append(
                f"{path}: group {gid} should have exactly one end; modes={modes}"
            )

    if strict:
        for gid, items in menu_items.items():
            titles = menu_titles.get(gid, [])
            if len(titles) != len(items):
                errors.append(
                    f"{path}: menu {gid} has {len(items)} WFMenuItems but "
                    f"{len(titles)} case titles"
                )
            elif sorted(titles) != sorted(items):
                errors.append(
                    f"{path}: menu {gid} WFMenuItemTitle set != WFMenuItems "
                    f"({titles} vs {items})"
                )

    return errors


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("paths", nargs="+", type=Path)
    ap.add_argument(
        "--strict",
        action="store_true",
        help="balance + menu title + teaching OutputName checks",
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

    mode = "strict" if args.strict else "standard"
    print(f"OK  check_shortcut_grammar.py ({checked} files, {mode})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
