#!/usr/bin/env bash
# Convert a signed/unsigned .shortcut (binary plist) to XML for inspection.
# Full signing/import still requires macOS; this script helps reverse-engineer exports.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/extract_shortcut.sh <input.shortcut|plist> [output.xml]

Converts Apple binary/XML plists to pretty XML using plutil (macOS) or
Python plistlib (Linux/macOS fallback).

iCloud share reverse-engineering (manual, often from Mac):
  1. Share URL:  https://www.icloud.com/shortcuts/<ID>
  2. Record API: https://www.icloud.com/shortcuts/api/records/<ID>
  3. Download fields.shortcut.value.downloadURL (unsigned bplist)
  4. Run this script on the downloaded file
  5. Diff against templates/examples/ before inventing parameters

See also: https://gist.github.com/0xdevalias/27d9aea9529be7b6ce59055332a94477
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

input="$1"
if [[ ! -f "$input" ]]; then
  echo "Error: input not found: $input" >&2
  exit 1
fi

output="${2:-${input%.*}.extracted.xml}"

if command -v plutil >/dev/null 2>&1; then
  # plutil can convert in place to a new file with -o
  plutil -convert xml1 -o "$output" -- "$input"
  echo "Wrote XML via plutil: $output"
  exit 0
fi

python3 - "$input" "$output" <<'PY'
import plistlib, sys
from pathlib import Path
inp, outp = Path(sys.argv[1]), Path(sys.argv[2])
data = plistlib.loads(inp.read_bytes())
# Prefer XML for diffs
outp.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_XML))
print(f"Wrote XML via plistlib: {outp}")
PY
