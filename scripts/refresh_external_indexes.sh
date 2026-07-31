#!/usr/bin/env bash
# Refresh remote corpus indexes listed in data/sources.json (metadata only).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

curl -fsSL --max-time 30 \
  "https://raw.githubusercontent.com/viticci/shortcuts-playground-plugin/main/claude/skills/shortcuts-playground/golden-shortcuts/index.jsonl" \
  -o data/external/viticci-playground-goldens.index.jsonl

python3 - <<'PY'
import json, re
from pathlib import Path

def norm_title(t: str) -> str:
    t = t.strip().lower().replace("–", "-").replace("—", "-")
    t = re.sub(r"\s+", " ", t).replace("masto-redirect", "masto redirect")
    return t

vendored = {
    norm_title(x) for x in [
        "URL Cleaner", "Parse JSON Feed", "Invert Names", "Days In a Month",
        "Days in a Month", "Electricity Price", "Preview Folder Contents",
        "Masto Redirect", "Masto-Redirect", "Calendar Locations",
        "Create Calendar Event from Template",
        "Select Folder, Compress, and Share",
        "App Release Notes",
    ]
}
entries = [
    json.loads(l)
    for l in Path("data/external/viticci-playground-goldens.index.jsonl").read_text().splitlines()
    if l.strip()
]
gaps = [e for e in entries if norm_title(e.get("title", "")) not in vendored]
out = Path("data/external/viticci-gaps.jsonl")
out.write_text("".join(json.dumps(e, ensure_ascii=False) + "\n" for e in gaps), encoding="utf-8")
print(f"Wrote {out} ({len(gaps)} gaps / {len(entries)} indexed)")
PY

python3 scripts/check_sources.py
echo "OK  indexes refreshed"
