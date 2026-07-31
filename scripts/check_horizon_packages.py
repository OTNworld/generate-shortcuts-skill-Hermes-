#!/usr/bin/env python3
"""Validate horizon/packages/*/package.json against schema + path rules."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from check_json_schema import validate_file  # noqa: E402

SCHEMA = ROOT / "data/schemas/horizon-package.v1.json"
PACKAGES = ROOT / "horizon/packages"


def main() -> int:
    if not PACKAGES.is_dir():
        print("OK  no horizon/packages (skip)")
        return 0

    ai = json.loads((ROOT / "data/appintents.json").read_text())
    unverified = set(ai.get("unverified") or [])

    failures = 0
    manifests = sorted(PACKAGES.glob("*/package.json"))
    if not manifests:
        print("FAIL horizon/packages has no package.json", file=sys.stderr)
        return 1

    for man in manifests:
        errs = validate_file(man, SCHEMA)
        if errs:
            for e in errs:
                print(f"FAIL {man}: {e}", file=sys.stderr)
            failures += 1
            continue
        data = json.loads(man.read_text())
        pkg_id = data.get("id")
        # folder name should match id
        if man.parent.name != pkg_id:
            print(
                f"FAIL {man}: folder {man.parent.name!r} != id {pkg_id!r}",
                file=sys.stderr,
            )
            failures += 1

        model = data.get("model_policy") or "none"
        if str(pkg_id).startswith("local-") and model == "cloud-allowed":
            print(
                f"FAIL {man}: local-* package must not use cloud-allowed",
                file=sys.stderr,
            )
            failures += 1

        for sc in data.get("shortcuts") or []:
            rel = sc.get("path") or ""
            path = ROOT / rel
            if not path.is_file():
                print(f"FAIL {man}: missing shortcut path {rel}", file=sys.stderr)
                failures += 1
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            for u in unverified:
                if u in text:
                    print(
                        f"FAIL {man}: shortcut {rel} references unverified AppIntent {u}",
                        file=sys.stderr,
                    )
                    failures += 1

        att = data.get("attestation") or {}
        status = att.get("status")
        # soft rule: mac-run packages should be hello or documented; we only warn via fail if status mac-run but matrix missing
        if status in {"mac-run", "mac-import", "ios-sample"}:
            mref = att.get("matrix_ref")
            if mref and not (ROOT / mref).is_file():
                print(f"FAIL {man}: matrix_ref missing {mref}", file=sys.stderr)
                failures += 1

        print(f"OK  {man.relative_to(ROOT)} ({pkg_id})")

    if failures:
        print(f"horizon packages failures={failures}", file=sys.stderr)
        return 1
    print(f"OK  horizon packages ({len(manifests)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
