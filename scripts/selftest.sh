#!/usr/bin/env bash
# Fast local selftest: validate + optional Darwin hash-only.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

./scripts/validate.sh
./scripts/validate_on_write.sh templates/examples/01-hello-world.shortcut.xml

if [[ "$(uname -s)" == "Darwin" ]]; then
  ./scripts/attest_local.sh --hash-only --no-results
fi

echo "SELFTEST PASS"
