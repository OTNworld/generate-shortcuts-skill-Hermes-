#!/usr/bin/env python3
"""List / resolve lean Shortcuts icon glyph + tint integers (from PLIST_FORMAT.md).

Usage:
  python3 scripts/shortcut_icon.py --list
  python3 scripts/shortcut_icon.py --glyph Globe --color Red
  python3 scripts/shortcut_icon.py --glyph Star --color Blue --xml
"""

from __future__ import annotations

import argparse
import sys

# Curated from references/PLIST_FORMAT.md (sebj classic table + skill defaults).
GLYPHS: dict[str, int] = {
    "Globe": 59511,
    "Star": 59446,
    "Heart": 59448,
    "Gear": 59458,
    "Document": 59493,
    "Folder": 59495,
    "Play": 59477,
    "Message": 59412,
}

COLORS: dict[str, int] = {
    "Red": 4282601983,
    "DarkOrange": 4251333119,
    "Orange": 4271458815,
    "Yellow": 4274264319,
    "Green": 4292093695,
    "Teal": 431817727,
    "LightBlue": 1440408063,
    "Blue": 463140863,
    "DarkBlue": 946986751,
    "Violet": 2071128575,
    "Purple": 3679049983,
    "Pink": 3980825855,
    "Taupe": 3031607807,
    "Gray": 2846468607,
    "DarkGray": 255,
}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--list", action="store_true", help="List glyphs and colors")
    ap.add_argument("--glyph", default="Globe", help="Glyph name (default Globe)")
    ap.add_argument("--color", default="Red", help="Color name (default Red = skill templates)")
    ap.add_argument("--xml", action="store_true", help="Print WFWorkflowIcon XML snippet")
    args = ap.parse_args()

    if args.list:
        print("Glyphs:")
        for k, v in GLYPHS.items():
            print(f"  {k:12} {v}")
        print("Colors (RGBA-8 int):")
        for k, v in COLORS.items():
            print(f"  {k:12} {v}")
        return 0

    if args.glyph not in GLYPHS:
        print(f"FAIL unknown glyph {args.glyph!r}; use --list", file=sys.stderr)
        return 1
    if args.color not in COLORS:
        print(f"FAIL unknown color {args.color!r}; use --list", file=sys.stderr)
        return 1

    g, c = GLYPHS[args.glyph], COLORS[args.color]
    print(f"glyph={args.glyph} number={g}")
    print(f"color={args.color} start={c}")
    if args.xml:
        print(
            "<key>WFWorkflowIcon</key>\n"
            "<dict>\n"
            "    <key>WFWorkflowIconGlyphNumber</key>\n"
            f"    <integer>{g}</integer>\n"
            "    <key>WFWorkflowIconStartColor</key>\n"
            f"    <integer>{c}</integer>\n"
            "</dict>"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
