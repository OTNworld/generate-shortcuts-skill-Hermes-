#!/usr/bin/env bash
# Preflight for Shortcuts attestation automation on macOS.
# Optional: --json for agent-friendly machine output.
set -euo pipefail

JSON=0
if [[ "${1:-}" == "--json" ]]; then
  JSON=1
fi

ok=0
fail=0
declare -a CHECKS=()

pass() {
  echo "OK  $*"
  ok=$((ok + 1))
  CHECKS+=("pass|$1")
}
fail_msg() {
  echo "FAIL $*"
  fail=$((fail + 1))
  CHECKS+=("fail|$1")
}

emit_json() {
  python3 - <<'PY' "$ok" "$fail" "${CHECKS[@]}"
import json, sys
ok, fail = int(sys.argv[1]), int(sys.argv[2])
checks = []
for item in sys.argv[3:]:
    status, _, detail = item.partition("|")
    checks.append({"status": status, "detail": detail})
print(json.dumps({"ok": ok, "fail": fail, "checks": checks, "ready": fail == 0}, indent=2))
PY
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail_msg "not macOS ($(uname -s))"
  if [[ "$JSON" -eq 1 ]]; then emit_json; fi
  echo "Summary: $ok ok, $fail fail"
  exit 1
fi
pass "macOS $(sw_vers -productVersion 2>/dev/null || echo '?')"

if command -v shortcuts >/dev/null 2>&1; then
  pass "shortcuts CLI: $(command -v shortcuts)"
else
  fail_msg "shortcuts CLI missing"
fi

# Accessibility for osascript / System Events
ax_out="$(osascript -e 'tell application "System Events" to get name of first process' 2>&1 || true)"
if [[ "$ax_out" == *"n’est pas autorisé"* ]] || [[ "$ax_out" == *"not allowed"* ]] || [[ "$ax_out" == *"-25211"* ]]; then
  fail_msg "Accessibility denied for osascript (error -25211)"
  echo
  echo "Grant access:"
  echo "  System Settings → Privacy & Security → Accessibility"
  echo "  Enable: Terminal and/or Cursor (and any host running this script)"
  if [[ "$JSON" -eq 0 ]]; then
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" 2>/dev/null || true
  fi
  echo "Then re-run: ./scripts/check_shortcuts_automation.sh"
else
  pass "Accessibility (System Events reachable)"
fi

# Optional: Screen Recording is only needed for agent screenshot triage
if command -v screencapture >/dev/null 2>&1; then
  pass "screencapture available (Screen Recording may still be required for captures)"
else
  fail_msg "screencapture missing"
fi

if [[ "$JSON" -eq 1 ]]; then
  emit_json
fi

echo
echo "Summary: $ok ok, $fail fail"
[[ "$fail" -eq 0 ]]
