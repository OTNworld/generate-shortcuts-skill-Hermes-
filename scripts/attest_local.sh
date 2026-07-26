#!/usr/bin/env bash
# Local Mac helper: hash goldens, optionally sign + open for attestation.
# Requires macOS + Shortcuts CLI for --sign / --open.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

HASH_ONLY=0
DO_SIGN=0
DO_OPEN=0
SCOPE="core" # core = examples 01-08 + palette; all = + community

usage() {
  cat <<'EOF'
Usage: scripts/attest_local.sh [--hash-only] [--sign] [--open] [--all]

  --hash-only   Write fixtures/attested/hashes.sha256 (unsigned XML)
  --sign        Copy to /tmp, run scripts/sign_shortcut.sh (needs macOS shortcuts)
  --open        open signed files in Shortcuts (implies --sign)
  --all         Include templates/examples/community/*

Default without flags: print this help + list goldens.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hash-only) HASH_ONLY=1 ;;
    --sign) DO_SIGN=1 ;;
    --open) DO_OPEN=1; DO_SIGN=1 ;;
    --all) SCOPE=all ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

list_goldens() {
  find templates/examples -maxdepth 1 -type f -name '0*.shortcut.xml' | sort
  find templates/palette -type f -name '*.shortcut.xml' | sort
  if [[ "$SCOPE" == all ]]; then
    find templates/examples/community -type f -name '*.shortcut.xml' | sort
  fi
}

if [[ "$HASH_ONLY" -eq 0 && "$DO_SIGN" -eq 0 ]]; then
  usage
  echo
  echo "Goldens ($SCOPE):"
  list_goldens | sed 's/^/  /'
  exit 0
fi

mkdir -p fixtures/attested
OUT_HASH="fixtures/attested/hashes.sha256"

if [[ "$HASH_ONLY" -eq 1 || "$DO_SIGN" -eq 1 ]]; then
  : >"$OUT_HASH"
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if command -v shasum >/dev/null 2>&1; then
      shasum -a 256 "$f" >>"$OUT_HASH"
    else
      sha256sum "$f" >>"$OUT_HASH"
    fi
  done < <(list_goldens)
  echo "Wrote $OUT_HASH ($(wc -l <"$OUT_HASH" | tr -d ' ') files)"
fi

if [[ "$DO_SIGN" -eq 1 ]]; then
  if ! command -v shortcuts >/dev/null 2>&1; then
    echo "Error: shortcuts CLI not found — run this on macOS." >&2
    exit 1
  fi
  mkdir -p /tmp/shortcuts-attest
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    base="$(basename "$f" .shortcut.xml)"
    src="/tmp/shortcuts-attest/${base}.shortcut"
    signed="/tmp/shortcuts-attest/${base}_signed.shortcut"
    cp "$f" "$src"
    ./scripts/sign_shortcut.sh "$src" "$signed"
    if [[ "$DO_OPEN" -eq 1 ]]; then
      open "$signed"
      sleep 1
    fi
  done < <(list_goldens)
  echo "Signed files under /tmp/shortcuts-attest/"
  echo "Record results in fixtures/attested/MATRIX.md"
fi
