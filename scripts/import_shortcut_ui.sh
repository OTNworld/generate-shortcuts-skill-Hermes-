#!/usr/bin/env bash
# Import a signed .shortcut via Shortcuts.app UI automation (macOS).
#
# Strategy (hybrid):
# 1. open the signed file
# 2. focus Shortcuts
# 3. try named AX click, then Return (default CTA)
# 4. optionally click green CTA by screenshot (fallback)
# 5. verify via `shortcuts list`
# 6. append fixtures/attested/runs/import_report.tsv
#
# Requires: Accessibility for the host running osascript (Cursor / Terminal).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS="${ROOT}/fixtures/attested/runs"
REPORT="${RUNS}/import_report.tsv"
CLICK_GREEN=0
TIMEOUT=12
DRY=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: scripts/import_shortcut_ui.sh [options] <signed.shortcut> [...]

  --click-green  Also try pixel-locate the green CTA and click it
  --timeout N    Seconds to wait for shortcuts list (default 12)
  --force        Re-open even if already in shortcuts list
  --dry-run      Open only; do not key/click
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --click-green) CLICK_GREEN=1 ;;
    --timeout) TIMEOUT="${2:?}"; shift ;;
    --force) FORCE=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown: $1" >&2; usage; exit 2 ;;
    *) break ;;
  esac
  shift
done

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: macOS only" >&2
  exit 1
fi

if ! command -v shortcuts >/dev/null 2>&1; then
  echo "Error: shortcuts CLI missing" >&2
  exit 1
fi

if ! osascript -e 'tell application "System Events" to get name of first process' >/dev/null 2>&1; then
  echo "Error: Accessibility denied for osascript (-25211)." >&2
  echo "Grant: System Settings → Privacy & Security → Accessibility → Cursor/Terminal" >&2
  exit 1
fi

mkdir -p "$RUNS"
if [[ ! -f "$REPORT" ]]; then
  printf 'name\tresult\tmethod\tms\tnotes\n' >"$REPORT"
fi

now_ms() {
  python3 -c 'import time; print(int(time.time()*1000))'
}

press_return() {
  osascript <<'EOF' >/dev/null
tell application "System Events"
  tell process "Shortcuts" to set frontmost to true
end tell
delay 0.15
tell application "System Events" to key code 36
EOF
}

try_named_click() {
  local out
  out="$(osascript "$ROOT/scripts/lib/shortcuts_import_click.applescript" Shortcuts 2>/dev/null || true)"
  printf '%s' "$out"
}

click_green_cta() {
  python3 - <<'PY' || true
import subprocess, time
from collections import defaultdict
try:
    from PIL import Image
except ImportError:
    raise SystemExit(0)
subprocess.run(["screencapture", "-x", "/tmp/shortcuts-import-ui.png"], check=False)
im = Image.open("/tmp/shortcuts-import-ui.png").convert("RGB")
W, H = im.size
scale = 2 if W >= 2500 else 1
geo = subprocess.run(
    ["osascript", "-e",
     'tell application "System Events" to tell process "Shortcuts"\n'
     'set out to ""\n'
     'repeat with w in windows\n'
     'set n to ""\n'
     'try\nset n to name of w as text\nend try\n'
     'if n is "" then\n'
     'set p to position of w\nset s to size of w\n'
     'set out to out & (item 1 of p) & "," & (item 2 of p) & "," & (item 1 of s) & "," & (item 2 of s) & linefeed\n'
     'end if\nend repeat\nreturn out\nend tell'],
    capture_output=True, text=True)
boxes = []
for line in (geo.stdout or "").splitlines():
    parts = line.strip().split(",")
    if len(parts) == 4:
        boxes.append(tuple(map(int, parts)))
if not boxes:
    raise SystemExit(0)
greens = []
for wx, wy, ww, wh in boxes:
    x0, y0 = wx * scale, wy * scale
    x1, y1 = (wx + ww) * scale, (wy + wh) * scale
    for y in range(max(0, y0), min(H, y1), 2):
        for x in range(max(0, x0), min(W, x1), 2):
            r, g, b = im.getpixel((x, y))
            if 40 <= r <= 100 and 110 <= g <= 180 and 20 <= b <= 90 and g > r + 30:
                greens.append((x, y))
if not greens:
    raise SystemExit(0)
bands = defaultdict(list)
for x, y in greens:
    bands[y // 6 * 6].append(x)
yb, xs = max(bands.items(), key=lambda kv: max(kv[1]) - min(kv[1]))
if max(xs) - min(xs) < 80:
    raise SystemExit(0)
cx = (min(xs) + max(xs)) // 2
cy = yb + 3
px, py = int(cx / scale), int(cy / scale)
subprocess.run(["osascript", "-e",
                'tell application "System Events" to set frontmost of process "Shortcuts" to true'])
time.sleep(0.1)
subprocess.run(["osascript", "-e", f'tell application "System Events" to click at {{{px}, {py}}}'])
print(f"green@{px},{py}", flush=True)
PY
}

snap_fail() {
  local name="$1"
  local dest="${RUNS}/${name}-import-fail.png"
  screencapture -x "$dest" 2>/dev/null || true
}

log_row() {
  local name="$1" result="$2" method="$3" ms="$4" notes="$5"
  notes="${notes//$'\t'/ }"
  notes="${notes//$'\n'/ }"
  printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$result" "$method" "$ms" "$notes" >>"$REPORT"
  echo "$result $name ($method ${ms}ms) $notes"
}

import_one() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    log_row "$(basename "$path")" "FAIL" "none" "0" "missing file"
    return 1
  fi
  local name method="none"
  name="$(basename "$path" .shortcut)"
  local t0 t1 ms
  t0="$(now_ms)"

  if [[ "$FORCE" -eq 0 ]] && shortcuts list 2>/dev/null | grep -qx "$name"; then
    t1="$(now_ms)"; ms=$((t1 - t0))
    log_row "$name" "SKIP" "already" "$ms" "already in shortcuts list"
    return 0
  fi

  echo "IMPORT $name"
  open -a Shortcuts "$path"
  sleep 1.2

  if [[ "$DRY" -eq 1 ]]; then
    t1="$(now_ms)"; ms=$((t1 - t0))
    log_row "$name" "SKIP" "dry-run" "$ms" "open only"
    return 0
  fi

  local ax
  ax="$(try_named_click || true)"
  if [[ "$ax" == CLICKED:* ]]; then
    method="ax"
  fi
  press_return
  if [[ "$method" == "none" ]]; then
    method="return"
  fi
  if [[ "$CLICK_GREEN" -eq 1 ]]; then
    local g
    g="$(click_green_cta || true)"
    if [[ -n "$g" ]]; then
      method="green"
    fi
  fi

  local i
  for ((i = 1; i <= TIMEOUT; i++)); do
    if shortcuts list 2>/dev/null | grep -qx "$name"; then
      t1="$(now_ms)"; ms=$((t1 - t0))
      log_row "$name" "OK" "$method" "$ms" ""
      return 0
    fi
    sleep 1
    if (( i % 2 == 0 )); then
      press_return
      try_named_click >/dev/null || true
    fi
  done
  t1="$(now_ms)"; ms=$((t1 - t0))
  snap_fail "$name"
  log_row "$name" "FAIL" "$method" "$ms" "not listed after ${TIMEOUT}s"
  return 1
}

rc=0
for f in "$@"; do
  import_one "$f" || rc=1
done
echo "Wrote $REPORT"
exit "$rc"
