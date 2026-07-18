#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input.shortcut> <output_signed.shortcut> [mode]"
  echo "mode: anyone (default) | people-who-know-me"
  exit 2
fi

input="$1"
output="$2"
mode="${3:-anyone}"

if [[ ! -f "$input" ]]; then
  echo "Error: input not found: $input"
  exit 1
fi

mkdir -p "$(dirname "$output")"

shortcuts sign --mode "$mode" --input "$input" --output "$output"
echo "Signed shortcut written to: $output"
