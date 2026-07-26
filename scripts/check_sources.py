#!/usr/bin/env python3
"""Validate data/sources.json schema + path integrity + Viticci gap index drift."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from check_json_schema import validate_file  # noqa: E402

SOURCES = ROOT / "data/sources.json"
SCHEMA = ROOT / "data/schemas/sources.v1.json"
GAP_INDEX = ROOT / "data/external/viticci-gaps.jsonl"


def norm_title(t: str) -> str:
    t = t.strip().lower()
    t = t.replace("–", "-").replace("—", "-")
    t = re.sub(r"\s+", " ", t)
    t = t.replace("masto-redirect", "masto redirect")
    return t


def main() -> int:
    errs = validate_file(SOURCES, SCHEMA)
    if errs:
        for e in errs:
            print(f"FAIL {e}", file=sys.stderr)
        return 1

    data = json.loads(SOURCES.read_text())
    failures = 0
    ids = [s["id"] for s in data["sources"]]
    if len(ids) != len(set(ids)):
        print("FAIL duplicate source ids", file=sys.stderr)
        failures += 1

    for src in data["sources"]:
        sid = src["id"]
        idx = src.get("local_index")
        if idx:
            p = ROOT / idx
            if not p.is_file():
                print(f"FAIL {sid}: missing local_index {idx}", file=sys.stderr)
                failures += 1
        for rel in src.get("vendored_examples") or []:
            p = ROOT / rel
            if not p.is_file():
                print(f"FAIL {sid}: missing vendored_examples {rel}", file=sys.stderr)
                failures += 1
        use = src["use"]
        if use == "index+selective-vendor":
            if not src.get("vendored_examples"):
                print(f"FAIL {sid}: selective-vendor without vendored_examples", file=sys.stderr)
                failures += 1
            if not src.get("local_index"):
                print(f"FAIL {sid}: selective-vendor without local_index", file=sys.stderr)
                failures += 1
        if src["license"] in {"GPL-3.0", "GPL-2.0"} and use not in {"link"}:
            print(f"FAIL {sid}: GPL must remain use=link", file=sys.stderr)
            failures += 1

    # Viticci gap index must match index − vendored titles
    vit = next((s for s in data["sources"] if s["id"] == "viticci-shortcuts-playground"), None)
    if vit and vit.get("local_index"):
        index_path = ROOT / vit["local_index"]
        entries = [
            json.loads(line)
            for line in index_path.read_text().splitlines()
            if line.strip()
        ]
        # Titles implied by community README table / notices
        vendored_norm = {
            norm_title("URL Cleaner"),
            norm_title("Parse JSON Feed"),
            norm_title("Invert Names"),
            norm_title("Days In a Month"),
            norm_title("Days in a Month"),
            norm_title("Electricity Price"),
            norm_title("Preview Folder Contents"),
            norm_title("Masto Redirect"),
            norm_title("Masto-Redirect"),
            norm_title("Calendar Locations"),
        }
        gaps = [e for e in entries if norm_title(e.get("title", "")) not in vendored_norm]
        if not GAP_INDEX.is_file():
            print(f"FAIL missing {GAP_INDEX.relative_to(ROOT)}", file=sys.stderr)
            failures += 1
        else:
            gap_rows = [
                json.loads(line)
                for line in GAP_INDEX.read_text().splitlines()
                if line.strip()
            ]
            gap_titles = {norm_title(r["title"]) for r in gap_rows}
            expect = {norm_title(e["title"]) for e in gaps}
            if gap_titles != expect:
                only_file = sorted(gap_titles - expect)[:5]
                only_calc = sorted(expect - gap_titles)[:5]
                print(
                    f"FAIL viticci-gaps drift file_only={only_file} calc_only={only_calc}",
                    file=sys.stderr,
                )
                failures += 1
            else:
                print(f"OK  viticci gaps index ({len(gap_rows)} not vendored)")

    if failures:
        print(f"sources check failures={failures}", file=sys.stderr)
        return 1
    print(f"OK  data/sources.json ({len(data['sources'])} sources)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
