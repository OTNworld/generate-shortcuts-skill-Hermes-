#!/usr/bin/env bash
# Run imported attestation shortcuts via `shortcuts run` and record results.
# macOS bash 3.2 compatible.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT}/fixtures/attested/runs"
mkdir -p "$OUT_DIR"
REPORT="${OUT_DIR}/run_report.tsv"
TIMEOUT_SEC="${TIMEOUT_SEC:-25}"

NONINTERACTIVE="01-hello-world_signed 06-conditional_signed 07-repeat-count_signed 08-repeat-each_signed 02-gettext-show_signed 03-setclipboard_signed 05-list_signed 06-dictionary_signed 07-variables_signed 09-comment-nothing_signed 10-count_signed 12-delay_signed"
NETWORKISH="05-weather-ai_signed 04-url-open_signed 08-downloadurl_signed"

INCLUDE_NETWORK=0
ALL_IMPORTED=0
NAMES=""

usage() {
  cat <<'EOF'
Usage: scripts/run_shortcut_attest.sh [--all-imported] [--include-network] [name ...]

Default: non-interactive core set present in `shortcuts list`.
Interactive ask/menu/list pickers are skipped unless named explicitly.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-network) INCLUDE_NETWORK=1 ;;
    --all-imported) ALL_IMPORTED=1 ;;
    -h|--help) usage; exit 0 ;;
    *) NAMES="${NAMES} $1" ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]] || ! command -v shortcuts >/dev/null; then
  echo "macOS + shortcuts CLI required" >&2
  exit 1
fi

LIST_FILE="$(mktemp)"
shortcuts list >"$LIST_FILE"

have() { grep -qx "$1" "$LIST_FILE"; }

if [[ "$ALL_IMPORTED" -eq 1 ]]; then
  NAMES="$(tr '\n' ' ' <"$LIST_FILE")"
elif [[ -z "${NAMES// /}" ]]; then
  NAMES="$NONINTERACTIVE"
  if [[ "$INCLUDE_NETWORK" -eq 1 ]]; then
    NAMES="$NAMES $NETWORKISH"
  fi
fi

printf 'name\tresult\tnotes\n' >"$REPORT"

run_one() {
  local name="$1"
  local out="${OUT_DIR}/${name}.out"
  local err="${OUT_DIR}/${name}.err"
  if ! have "$name"; then
    printf '%s\tSKIP\tnot imported\n' "$name" | tee -a "$REPORT"
    return 0
  fi
  echo "RUN $name"
  set +e
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$TIMEOUT_SEC" shortcuts run "$name" --output-path "$out" --output-type public.plain-text 2>"$err"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$TIMEOUT_SEC" shortcuts run "$name" --output-path "$out" --output-type public.plain-text 2>"$err"
  else
    shortcuts run "$name" --output-path "$out" --output-type public.plain-text 2>"$err"
  fi
  local rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    printf '%s\tOK\t\n' "$name" | tee -a "$REPORT"
  else
    local note
    note="$(tr '\n' ' ' <"$err" | cut -c1-180)"
    printf '%s\tFAIL\t%s\n' "$name" "$note" | tee -a "$REPORT"
  fi
}

for n in $NAMES; do
  [[ -z "$n" ]] && continue
  run_one "$n"
done

rm -f "$LIST_FILE"
echo "Wrote $REPORT"
