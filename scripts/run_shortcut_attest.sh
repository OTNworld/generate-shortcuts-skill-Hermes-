#!/usr/bin/env bash
# Run imported attestation shortcuts via `shortcuts run` and record results.
# macOS bash 3.2 compatible.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT}/fixtures/attested/runs"
INPUTS="${ROOT}/fixtures/attested/inputs"
mkdir -p "$OUT_DIR"
REPORT="${OUT_DIR}/run_report.tsv"
TIMEOUT_SEC="${TIMEOUT_SEC:-25}"

# Prefer fixed/v2 names when stale library copies still exist under the canonical name.
NONINTERACTIVE="01-hello-world_signed 06-conditional-v2_signed 06-conditional_signed 07-repeat-count_signed 08-repeat-each_signed 02-gettext-show_signed 03-setclipboard_signed 05-list_signed 06-dictionary-fixed_signed 06-dictionary_signed 07-variables_signed 09-comment-nothing_signed 10-count_signed 12-delay_signed"
WITH_INPUTS="02-ask-input_signed 01-ask_signed"
NETWORKISH="05-weather-ai_signed 04-url-open_signed 08-downloadurl_signed"

INCLUDE_NETWORK=0
ALL_IMPORTED=0
DO_INPUTS=0
NAMES=""

usage() {
  cat <<'EOF'
Usage: scripts/run_shortcut_attest.sh [options] [name ...]

  --with-inputs       Also run ask goldens using fixtures/attested/inputs/*
  --include-network   Include weather/url/downloadurl
  --all-imported      Run every name from `shortcuts list`

Default: non-interactive core set (plus fixed aliases when present).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-network) INCLUDE_NETWORK=1 ;;
    --all-imported) ALL_IMPORTED=1 ;;
    --with-inputs) DO_INPUTS=1 ;;
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

input_for() {
  case "$1" in
    02-ask-input_signed) echo "${INPUTS}/02-ask-input.txt" ;;
    01-ask_signed) echo "${INPUTS}/01-ask.txt" ;;
    *) echo "" ;;
  esac
}

if [[ "$ALL_IMPORTED" -eq 1 ]]; then
  NAMES="$(tr '\n' ' ' <"$LIST_FILE")"
elif [[ -z "${NAMES// /}" ]]; then
  NAMES="$NONINTERACTIVE"
  if [[ "$DO_INPUTS" -eq 1 ]]; then
    NAMES="$NAMES $WITH_INPUTS"
  fi
  if [[ "$INCLUDE_NETWORK" -eq 1 ]]; then
    NAMES="$NAMES $NETWORKISH"
  fi
fi

printf 'name\tresult\tnotes\n' >"$REPORT"

# Deduplicate while preferring first occurrence (fixed aliases listed first).
SEEN_FILE="$(mktemp)"

run_one() {
  local name="$1"
  local out="${OUT_DIR}/${name}.out"
  local err="${OUT_DIR}/${name}.err"
  if ! have "$name"; then
    printf '%s\tSKIP\tnot imported\n' "$name" | tee -a "$REPORT"
    return 0
  fi
  # Skip canonical if a fixed/v2 twin already recorded OK this session
  case "$name" in
    06-conditional_signed)
      if grep -q $'^06-conditional-v2_signed\tOK' "$REPORT" 2>/dev/null; then
        printf '%s\tSKIP\talias 06-conditional-v2_signed OK\n' "$name" | tee -a "$REPORT"
        return 0
      fi
      ;;
    06-dictionary_signed)
      if grep -q $'^06-dictionary-fixed_signed\tOK' "$REPORT" 2>/dev/null; then
        printf '%s\tSKIP\talias 06-dictionary-fixed_signed OK\n' "$name" | tee -a "$REPORT"
        return 0
      fi
      ;;
  esac

  local inpath=""
  inpath="$(input_for "$name")"
  echo "RUN $name${inpath:+ (input $inpath)}"
  set +e
  local cmd=(shortcuts run "$name" --output-path "$out" --output-type public.plain-text)
  if [[ -n "$inpath" && -f "$inpath" ]]; then
    cmd+=(--input-path "$inpath")
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$TIMEOUT_SEC" "${cmd[@]}" 2>"$err"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$TIMEOUT_SEC" "${cmd[@]}" 2>"$err"
  else
    "${cmd[@]}" 2>"$err"
  fi
  local rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    printf '%s\tOK\t\n' "$name" | tee -a "$REPORT"
  else
    local note
    note="$(tr '\n' ' ' <"$err" | cut -c1-180)"
    screencapture -x "${OUT_DIR}/${name}-run-fail.png" 2>/dev/null || true
    printf '%s\tFAIL\t%s\n' "$name" "$note" | tee -a "$REPORT"
  fi
}

for n in $NAMES; do
  [[ -z "$n" ]] && continue
  if grep -qx "$n" "$SEEN_FILE" 2>/dev/null; then
    continue
  fi
  echo "$n" >>"$SEEN_FILE"
  run_one "$n"
done

rm -f "$LIST_FILE" "$SEEN_FILE"
echo "Wrote $REPORT"
