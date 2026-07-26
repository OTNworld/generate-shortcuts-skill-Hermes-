#!/usr/bin/env bash
# Local Mac helper: hash goldens, sign, UI-import, and optionally run.
# Requires macOS + Shortcuts CLI. UI import needs Accessibility for osascript.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

HASH_ONLY=0
DO_SIGN=0
DO_OPEN=0
DO_IMPORT_UI=0
DO_RUN=0
CLICK_GREEN=0
WITH_INPUTS=0
WRITE_RESULTS=1
SCOPE="core" # core = examples 01-08 + palette; all = + community

usage() {
  cat <<'EOF'
Usage: scripts/attest_local.sh [options]

  --hash-only     Write fixtures/attested/hashes.sha256 (unsigned XML)
  --sign          Copy to /tmp, run scripts/sign_shortcut.sh
  --open          open signed files in Shortcuts (implies --sign)
  --import-ui     Sign + UI-import via Return/AX (implies --sign; needs Accessibility)
  --click-green   With --import-ui, also click green CTA via screenshot
  --run           After import, run non-interactive goldens (shortcuts run)
  --with-inputs   With --run/--auto, also run ask goldens via fixtures/attested/inputs
  --auto          --import-ui --run --with-inputs (full local attestation loop)
  --all           Include templates/examples/community/*
  --no-results    Skip writing fixtures/attested/results.json

Default without flags: print this help + list goldens.

Examples:
  ./scripts/attest_local.sh --hash-only
  ./scripts/attest_local.sh --auto
  ./scripts/attest_local.sh --import-ui --click-green --all
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hash-only) HASH_ONLY=1 ;;
    --sign) DO_SIGN=1 ;;
    --open) DO_OPEN=1; DO_SIGN=1 ;;
    --import-ui) DO_IMPORT_UI=1; DO_SIGN=1 ;;
    --click-green) CLICK_GREEN=1 ;;
    --run) DO_RUN=1 ;;
    --with-inputs) WITH_INPUTS=1 ;;
    --auto) DO_IMPORT_UI=1; DO_SIGN=1; DO_RUN=1; WITH_INPUTS=1 ;;
    --all) SCOPE=all ;;
    --no-results) WRITE_RESULTS=0 ;;
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

if [[ "$HASH_ONLY" -eq 0 && "$DO_SIGN" -eq 0 && "$DO_RUN" -eq 0 ]]; then
  usage
  echo
  echo "Goldens ($SCOPE):"
  list_goldens | sed 's/^/  /'
  exit 0
fi

mkdir -p fixtures/attested fixtures/attested/runs fixtures/attested/inputs /tmp/shortcuts-attest
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

SIGNED_LIST=()

if [[ "$DO_SIGN" -eq 1 ]]; then
  if ! command -v shortcuts >/dev/null 2>&1; then
    echo "Error: shortcuts CLI not found — run this on macOS." >&2
    exit 1
  fi
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    base="$(basename "$f" .shortcut.xml)"
    src="/tmp/shortcuts-attest/${base}.shortcut"
    signed="/tmp/shortcuts-attest/${base}_signed.shortcut"
    cp "$f" "$src"
    ./scripts/sign_shortcut.sh "$src" "$signed"
    SIGNED_LIST+=("$signed")
    if [[ "$DO_OPEN" -eq 1 && "$DO_IMPORT_UI" -eq 0 ]]; then
      open "$signed"
      sleep 1
    fi
  done < <(list_goldens)
  echo "Signed files under /tmp/shortcuts-attest/"
fi

IMPORT_RC=0
RUN_RC=0

if [[ "$DO_IMPORT_UI" -eq 1 ]]; then
  ./scripts/check_shortcuts_automation.sh || {
    echo "Fix Accessibility, then re-run with --import-ui / --auto" >&2
    exit 1
  }
  # Fresh import report for this session
  printf 'name\tresult\tmethod\tms\tnotes\n' >fixtures/attested/runs/import_report.tsv
  import_args=(./scripts/import_shortcut_ui.sh)
  if [[ "$CLICK_GREEN" -eq 1 ]]; then
    import_args+=(--click-green)
  fi
  if [[ ${#SIGNED_LIST[@]} -eq 0 ]]; then
    while IFS= read -r s; do
      [[ -z "$s" ]] && continue
      SIGNED_LIST+=("$s")
    done < <(ls /tmp/shortcuts-attest/*_signed.shortcut 2>/dev/null | sort)
  fi
  if [[ ${#SIGNED_LIST[@]} -eq 0 ]]; then
    echo "Error: no signed files; run with --sign/--import-ui/--auto first" >&2
    exit 1
  fi
  set +e
  "${import_args[@]}" "${SIGNED_LIST[@]}"
  IMPORT_RC=$?
  set -e
fi

if [[ "$DO_RUN" -eq 1 ]]; then
  run_args=(./scripts/run_shortcut_attest.sh)
  if [[ "$WITH_INPUTS" -eq 1 ]]; then
    run_args+=(--with-inputs)
  fi
  set +e
  "${run_args[@]}"
  RUN_RC=$?
  set -e
fi

if [[ "$WRITE_RESULTS" -eq 1 && ( "$DO_IMPORT_UI" -eq 1 || "$DO_RUN" -eq 1 || "$HASH_ONLY" -eq 1 ) ]]; then
  chmod +x scripts/write_attest_results.sh
  set +e
  ./scripts/write_attest_results.sh
  set -e
fi

echo "Record / review fixtures/attested/MATRIX.md and fixtures/attested/results.json"
exit $(( IMPORT_RC || RUN_RC ))
