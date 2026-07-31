#!/usr/bin/env python3
"""Heuristic secret / credential leak gate for templates + fixtures XML."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# High-confidence credential shapes (not random short tokens).
PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("pem_private_key", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----")),
    ("github_pat", re.compile(r"\bghp_[A-Za-z0-9]{20,}\b")),
    ("github_oauth", re.compile(r"\bgho_[A-Za-z0-9]{20,}\b")),
    ("openai_sk", re.compile(r"\bsk-[A-Za-z0-9]{20,}\b")),
    ("aws_aki", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("slack_token", re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b")),
    ("generic_api_assignment", re.compile(r"(?i)\b(api[_-]?key|secret[_-]?key|access[_-]?token)\s*[=:]\s*['\"][^'\"]{12,}")),
]

SKIP_NAME_PARTS = (".stub.xml",)


def iter_targets(roots: list[Path]) -> list[Path]:
    out: list[Path] = []
    for root in roots:
        if not root.exists():
            continue
        for p in root.rglob("*"):
            if not p.is_file():
                continue
            if p.suffix.lower() not in {".xml", ".plist", ".shortcut", ".md", ".json", ".tsv"}:
                continue
            if any(s in p.name for s in SKIP_NAME_PARTS):
                continue
            out.append(p)
    return sorted(out)


def scan_file(path: Path) -> list[str]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        return [f"{path}: read error {e}"]
    hits = []
    for label, rx in PATTERNS:
        if rx.search(text):
            hits.append(f"{path}: matched {label}")
    return hits


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "roots",
        nargs="*",
        type=Path,
        default=[ROOT / "templates", ROOT / "fixtures"],
    )
    args = ap.parse_args()
    failures: list[str] = []
    checked = 0
    for path in iter_targets(args.roots):
        checked += 1
        failures.extend(scan_file(path))
    if failures:
        for f in failures:
            print(f"FAIL {f}", file=sys.stderr)
        print(f"checked={checked} failures={len(failures)}", file=sys.stderr)
        return 1
    print(f"OK  no secret-like patterns (checked={checked})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
