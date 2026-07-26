#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <input.shortcut> <output_signed.shortcut> [mode]"
  echo "mode: anyone (default) | people-who-know-me"
  echo
  echo "Environment:"
  echo "  SKIP_XMLLINT=1   skip optional xmllint pre-check"
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

input="$1"
output="$2"
mode="${3:-anyone}"

case "$mode" in
  anyone|people-who-know-me) ;;
  *)
    echo "Error: invalid mode '$mode' (allowed: anyone, people-who-know-me)" >&2
    exit 2
    ;;
esac

if [[ ! -f "$input" ]]; then
  echo "Error: input not found: $input" >&2
  exit 1
fi

if ! command -v shortcuts >/dev/null 2>&1; then
  echo "Error: 'shortcuts' CLI not found (requires macOS Shortcuts)" >&2
  exit 1
fi

if [[ "${SKIP_XMLLINT:-0}" != "1" ]] && command -v xmllint >/dev/null 2>&1; then
  if ! xmllint --noout "$input" 2>/dev/null; then
    echo "Error: input is not well-formed XML: $input" >&2
    echo "Hint: set SKIP_XMLLINT=1 to bypass (binary plists only)" >&2
    exit 1
  fi
fi

mkdir -p "$(dirname "$output")"

shortcuts sign --mode "$mode" --input "$input" --output "$output"
echo "Signed shortcut written to: $output"
