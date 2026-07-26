#!/usr/bin/env python3
"""Craig Loop *lite*: safe structural auto-fixes for Shortcuts XML.

Only fixes mechanical issues (never business semantics):
  - UUID / OutputUUID / GroupingIdentifier: lowercase hex → UPPERCASE
  - WFControlFlowMode stored as <string>0|1|2</string> → <integer>

Usage:
  python3 scripts/craig_loop_lite.py [--max N] [--dry-run] <file.shortcut.xml>
  python3 scripts/craig_loop_lite.py --validate <file>   # validate → fix → re-validate
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

UUID_ANY = re.compile(
    r"(?P<pre><key>(?:UUID|OutputUUID|GroupingIdentifier)</key>\s*<string>)"
    r"(?P<uuid>[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})"
    r"(?P<post></string>)"
)
MODE_STRING = re.compile(
    r"(?P<pre><key>WFControlFlowMode</key>\s*)"
    r"<string>\s*(?P<mode>[012])\s*</string>"
)


def log(msg: str) -> None:
    print(msg, flush=True)


def safe_fix(text: str) -> tuple[str, list[str]]:
    notes: list[str] = []

    def up_uuid(m: re.Match[str]) -> str:
        u = m.group("uuid")
        fixed = u.upper()
        if fixed != u:
            notes.append(f"UUID case → {fixed}")
        return f"{m.group('pre')}{fixed}{m.group('post')}"

    text2 = UUID_ANY.sub(up_uuid, text)

    def int_mode(m: re.Match[str]) -> str:
        notes.append(f"WFControlFlowMode string→integer {m.group('mode')}")
        return f"{m.group('pre')}<integer>{m.group('mode')}</integer>"

    text3 = MODE_STRING.sub(int_mode, text2)
    return text3, notes


def run_validate(path: Path) -> int:
    return subprocess.call(
        ["bash", str(ROOT / "scripts" / "validate_on_write.sh"), str(path)],
        cwd=ROOT,
    )


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("file", type=Path)
    ap.add_argument("--max", type=int, default=3, help="max fix iterations (default 3)")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument(
        "--validate",
        action="store_true",
        help="validate → safe-fix loop → re-validate",
    )
    args = ap.parse_args()
    path: Path = args.file
    if not path.is_file():
        print(f"FAIL missing: {path}", file=sys.stderr)
        return 1

    if args.validate:
        rc0 = run_validate(path)
        if rc0 == 0:
            log("OK  already valid; no Craig Loop needed")
            return 0
        log("== Craig Loop lite: validate failed; applying safe fixes ==")

    original = path.read_text(encoding="utf-8")
    text = original
    all_notes: list[str] = []
    for i in range(1, args.max + 1):
        fixed, notes = safe_fix(text)
        if not notes:
            log(f"OK  no further safe fixes (iter {i})")
            break
        all_notes.extend(notes)
        log(f"== iter {i}: {len(notes)} fix(es) ==")
        for n in notes:
            log(f"  - {n}")
        text = fixed
        if not args.dry_run:
            path.write_text(text, encoding="utf-8")
            log(f"WROTE {path}")
            if args.validate:
                rc = run_validate(path)
                if rc == 0:
                    log(f"PASS after iter {i}")
                    return 0
        else:
            # dry-run: keep iterating on memory only
            continue
    else:
        log(f"WARN hit --max={args.max}")

    if args.dry_run and text != original:
        log(f"DRY-RUN would write {path} ({len(all_notes)} notes)")
        return 0

    if text == original and not args.validate:
        log(f"UNCHANGED {path}")
        return 0

    if args.validate:
        rc = run_validate(path)
        if rc != 0:
            print("FAIL still invalid after Craig Loop lite", file=sys.stderr)
        return rc
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
