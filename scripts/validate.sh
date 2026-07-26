#!/usr/bin/env bash
# Validate skill templates and scripts (XML, bash syntax, shortcut grammar heuristics).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0
checked_xml=0
checked_sh=0
checked_grammar=0

note() { printf '  %s\n' "$*"; }
pass() { printf 'OK  %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*"; failures=$((failures + 1)); }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

require_cmd xmllint

# --- XML well-formedness ---
echo "== XML (xmllint) =="
while IFS= read -r -d '' file; do
  checked_xml=$((checked_xml + 1))
  if xmllint --noout "$file" 2>/dev/null; then
    pass "$file"
  else
    fail "$file (xmllint)"
    xmllint --noout "$file" 2>&1 | sed 's/^/    /' || true
  fi
done < <(find templates -type f \( -name '*.plist' -o -name '*.xml' -o -name '*.shortcut' \) -print0 2>/dev/null)

# --- Shell syntax ---
echo "== Shell (bash -n) =="
while IFS= read -r -d '' file; do
  checked_sh=$((checked_sh + 1))
  if bash -n "$file"; then
    pass "$file"
  else
    fail "$file (bash -n)"
  fi
done < <(find scripts -type f -name '*.sh' -print0 2>/dev/null)

# --- Grammar heuristics on importable templates (skip *.stub.xml) ---
echo "== Grammar (importable templates) =="
FFFC=$'\xEF\xBF\xBC' # UTF-8 for U+FFFC

is_stub() {
  [[ "$1" == *.stub.xml ]]
}

has_control_flow_action() {
  local f="$1"
  grep -qE 'is\.workflow\.actions\.(choosefrommenu|conditional|repeat\.(each|count)|repeat\.each|repeat)' "$f" \
    || grep -qE 'is\.workflow\.actions\.repeat' "$f"
}

while IFS= read -r -d '' file; do
  if is_stub "$file"; then
    note "skip grammar (stub): $file"
    continue
  fi
  checked_grammar=$((checked_grammar + 1))
  file_ok=1

  # U+FFFC must be paired with attachmentsByRange in the same file
  if grep -qF "$FFFC" "$file"; then
    if ! grep -q 'attachmentsByRange' "$file"; then
      fail "$file (U+FFFC present without attachmentsByRange)"
      file_ok=0
    fi
  fi

  # Control-flow actions need GroupingIdentifier
  if has_control_flow_action "$file"; then
    if ! grep -q 'GroupingIdentifier' "$file"; then
      fail "$file (control-flow action without GroupingIdentifier)"
      file_ok=0
    fi
    if ! grep -q 'WFControlFlowMode' "$file"; then
      fail "$file (control-flow action without WFControlFlowMode)"
      file_ok=0
    fi
  fi

  # Reject known-invalid action id documented in ACTIONS.md
  if grep -q 'is\.workflow\.actions\.savefile' "$file"; then
    fail "$file (invalid action id savefile; use documentpicker.save)"
    file_ok=0
  fi

  # UUID values in <string> should be uppercase hex form when they look like UUIDs
  while IFS= read -r uuid; do
    if [[ "$uuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
      upper="$(printf '%s' "$uuid" | tr '[:lower:]' '[:upper:]')"
      if [[ "$uuid" != "$upper" ]]; then
        fail "$file (UUID not uppercase: $uuid)"
        file_ok=0
      fi
    fi
  done < <(grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' "$file" || true)

  if [[ "$file_ok" -eq 1 ]]; then
    pass "$file"
  fi
done < <(find templates -type f \( -name '*.plist' -o -name '*.xml' \) -print0 2>/dev/null)

echo
echo "Checked: xml=$checked_xml shell=$checked_sh grammar=$checked_grammar failures=$failures"
if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
echo "All checks passed."
