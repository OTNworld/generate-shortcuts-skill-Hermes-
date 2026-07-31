#!/usr/bin/env bash
# Fast local selftest: validate + unittest + craig + remix + optional Darwin.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/validate.sh
./scripts/validate_on_write.sh templates/examples/01-hello-world.shortcut.xml

echo "== Unit tests =="
python3 -m unittest discover -s tests -v

echo "== Craig Loop fixtures =="
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp fixtures/craig/lc-uuid-hello.shortcut.xml "$TMP/lc.xml"
cp fixtures/craig/mode-str.shortcut.xml "$TMP/mode.xml"
cp fixtures/craig/savefile-hello.shortcut.xml "$TMP/sf.xml"

if ./scripts/validate_on_write.sh "$TMP/lc.xml" 2>/dev/null; then
  echo "FAIL craig lc-uuid should be invalid before --fix" >&2
  exit 1
fi
./scripts/validate_on_write.sh --fix "$TMP/lc.xml"
./scripts/validate_on_write.sh "$TMP/lc.xml"

if ./scripts/validate_on_write.sh "$TMP/mode.xml" 2>/dev/null; then
  echo "FAIL craig mode-str should be invalid before --fix" >&2
  exit 1
fi
./scripts/validate_on_write.sh --fix "$TMP/mode.xml"
./scripts/validate_on_write.sh "$TMP/mode.xml"

if ./scripts/validate_on_write.sh "$TMP/sf.xml" 2>/dev/null; then
  echo "FAIL craig savefile should be invalid before --fix" >&2
  exit 1
fi
./scripts/validate_on_write.sh --fix "$TMP/sf.xml"
./scripts/validate_on_write.sh "$TMP/sf.xml"
echo "OK  craig fixtures"

echo "== Remix structural + I/O fixture =="
python3 scripts/remix_shortcut.py fixtures/remix/hello-bonjour.input.xml \
  --replace-text "Hello World!" "Bonjour!" \
  --output "$TMP/hello-bonjour.xml"
./scripts/validate_on_write.sh "$TMP/hello-bonjour.xml"
python3 - <<PY
import plistlib
from pathlib import Path
got = plistlib.loads(Path("$TMP/hello-bonjour.xml").read_bytes())
exp = plistlib.loads(Path("fixtures/remix/hello-bonjour.expected.xml").read_bytes())
assert got == exp, "remix I/O fixture mismatch"
print("OK  remix I/O fixture")
PY

python3 scripts/remix_shortcut.py templates/examples/01-hello-world.shortcut.xml \
  --output "$TMP/hello-remix.xml" \
  --replace-text "Hello World!" "Bonjour!" \
  --insert-action 1 '{"identifier":"delay","parameters":{"WFDelayTime":1}}' \
  --set-name "Hello Remix"
./scripts/validate_on_write.sh "$TMP/hello-remix.xml"
python3 scripts/remix_shortcut.py "$TMP/hello-remix.xml" --list-actions | grep -q delay
python3 scripts/remix_shortcut.py "$TMP/hello-remix.xml" --output "$TMP/hello-moved.xml" --move-action 1 0
./scripts/validate_on_write.sh "$TMP/hello-moved.xml"
echo "OK  remix structural"

if [[ "$(uname -s)" == "Darwin" ]]; then
  ./scripts/attest_local.sh --hash-only --no-results
fi

echo "SELFTEST PASS"
