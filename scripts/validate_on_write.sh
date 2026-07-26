#!/usr/bin/env bash
# Validate a single Shortcuts plist after Write/Edit (lean validate-on-write).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/validate_on_write.sh <file.shortcut.xml|plist> [...]" >&2
  exit 2
fi

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: missing $1" >&2
    exit 1
  }
}
require xmllint
require python3

rc=0
for f in "$@"; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL missing: $f"
    rc=1
    continue
  fi
  echo "== validate_on_write: $f =="
  if ! xmllint --noout "$f" 2>/dev/null; then
    # binary plist?
    if plutil -lint "$f" >/dev/null 2>&1; then
      echo "OK  plutil lint (binary/xml)"
    else
      echo "FAIL xmllint/plutil: $f"
      rc=1
      continue
    fi
  else
    echo "OK  xmllint"
  fi

  if ! python3 scripts/check_shortcut_grammar.py --strict "$f"; then
    echo "FAIL grammar: $f"
    rc=1
    continue
  fi
  echo "OK  grammar --strict"

  # Action IDs must be in SSOT when they use is.workflow.actions.*
  if ! python3 - "$f" <<'PY'
import json, plistlib, sys
from pathlib import Path
path = Path(sys.argv[1])
wf = json.loads(Path("data/wf_actions.json").read_text())
allowed = set(wf["identifiers"])
prefix = wf.get("prefix", "is.workflow.actions.")
raw = path.read_bytes()
try:
    data = plistlib.loads(raw)
except Exception as e:
    print(f"FAIL plist load: {e}")
    sys.exit(1)
unknown = []
for action in data.get("WFWorkflowActions") or []:
    ident = action.get("WFWorkflowActionIdentifier") or ""
    if ident.startswith(prefix):
        short = ident[len(prefix):]
        if short not in allowed:
            unknown.append(ident)
if unknown:
    print("FAIL unknown action IDs:")
    for u in unknown:
        print(f"  {u}")
    sys.exit(1)
print("OK  action IDs in SSOT")
PY
  then
    rc=1
    continue
  fi
  echo "PASS $f"
done

exit "$rc"
