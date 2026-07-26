#!/usr/bin/env bash
# Preflight for Shortcuts attestation automation on macOS.
set -euo pipefail

ok=0
fail=0

pass() { echo "OK  $*"; ok=$((ok + 1)); }
fail() { echo "FAIL $*"; fail=$((fail + 1)); }

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "not macOS ($(uname -s))"
  echo "Summary: $ok ok, $fail fail"
  exit 1
fi
pass "macOS $(sw_vers -productVersion 2>/dev/null || echo '?')"

if command -v shortcuts >/dev/null 2>&1; then
  pass "shortcuts CLI: $(command -v shortcuts)"
else
  fail "shortcuts CLI missing"
fi

# Accessibility for osascript / System Events
ax_out="$(osascript -e 'tell application "System Events" to get name of first process' 2>&1 || true)"
if [[ "$ax_out" == *"n’est pas autorisé"* ]] || [[ "$ax_out" == *"not allowed"* ]] || [[ "$ax_out" == *"-25211"* ]]; then
  fail "Accessibility denied for osascript (error -25211)"
  echo
  echo "Grant access:"
  echo "  System Settings → Privacy & Security → Accessibility"
  echo "  Enable: Terminal and/or Cursor (and any host running this script)"
  echo "Then re-run: ./scripts/check_shortcuts_automation.sh"
else
  pass "Accessibility (System Events reachable)"
fi

# Optional: Screen Recording is only needed for agent screenshot triage
if command -v screencapture >/dev/null 2>&1; then
  pass "screencapture available (Screen Recording may still be required for captures)"
else
  fail "screencapture missing"
fi

echo
echo "Summary: $ok ok, $fail fail"
[[ "$fail" -eq 0 ]]
