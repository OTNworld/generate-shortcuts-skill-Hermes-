#!/usr/bin/env bash
# Validate skill templates, scripts, and catalog SSOT contracts.
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
require_cmd python3

# --- SSOT catalog contracts ---
echo "== SSOT catalogs =="
python3 - <<'PY' || exit 1
import json, re, pathlib, sys
root = pathlib.Path('.')
wf = json.loads((root / 'data/wf_actions.json').read_text())
ai = json.loads((root / 'data/appintents.json').read_text())
errors = []

if wf['count'] != len(wf['identifiers']) or len(set(wf['identifiers'])) != wf['count']:
    errors.append(f"wf_actions count mismatch: claimed {wf['count']} got {len(wf['identifiers'])} unique {len(set(wf['identifiers']))}")
if ai['count'] != len(ai['identifiers']) or len(set(ai['identifiers'])) != ai['count']:
    errors.append(f"appintents count mismatch: claimed {ai['count']} got {len(ai['identifiers'])} unique {len(set(ai['identifiers']))}")

# Claims in docs must match SSOT (first match of each pattern)
for path, pattern, expected in [
    ('README.md', r'\b(\d+) WF\*Action', wf['count']),
    ('README.md', r'\b(\d+) AppIntent', ai['count']),
    ('SKILL.md', r'(\d+) WF\*Actions', wf['count']),
    ('SKILL.md', r'(\d+) AppIntents', ai['count']),
    ('references/ACTIONS.md', r'all (\d+) WF\*Action', wf['count']),
    ('references/ACTIONS.md', r'All (\d+) action identifiers', wf['count']),
    ('references/APPINTENTS.md', r'\*\*(\d+)\*\* AppIntent', ai['count']),
    ('references/APPINTENTS.md', r'\*\*(\d+) curated\*\*', ai['count']),
]:
    text = (root / path).read_text()
    m = re.search(pattern, text)
    if not m:
        errors.append(f"{path}: missing claim pattern {pattern!r}")
    elif int(m.group(1)) != expected:
        errors.append(f"{path}: claim {m.group(1)} != SSOT {expected} for {pattern!r}")

# Complete list fence in APPINTENTS must equal SSOT identifiers
app = (root / 'references/APPINTENTS.md').read_text()
part = app.split('## Complete AppIntent Identifier List')[-1]
fence_ids = []
for m in re.finditer(r'```([\s\S]*?)```', part):
    fence_ids.extend(re.findall(r'[A-Za-z][A-Za-z0-9]+', m.group(1)))
fence_clean = sorted({i for i in fence_ids if i.endswith('Intent') or i.endswith('DeepLinks')})
if fence_clean != sorted(ai['identifiers']):
    only_ssot = sorted(set(ai['identifiers']) - set(fence_clean))
    only_fence = sorted(set(fence_clean) - set(ai['identifiers']))
    errors.append(
        f"APPINTENTS complete list != SSOT "
        f"(fence={len(fence_clean)} ssot={ai['count']} "
        f"only_ssot={only_ssot[:5]} only_fence={only_fence[:5]})"
    )

# ACTIONS complete list must equal SSOT
actions = (root / 'references/ACTIONS.md').read_text()
apart = actions.split('All 427 action identifiers')[-1] if 'All 427' in actions else actions.split(f"All {wf['count']} action identifiers")[-1]
m = re.search(r'```([\s\S]*?)```', apart)
names = re.findall(r'[a-z0-9._]+', m.group(1))
if names != wf['identifiers']:
    errors.append(f"ACTIONS complete list != SSOT (list={len(names)} ssot={wf['count']})")

if errors:
    for e in errors:
        print('FAIL', e)
    sys.exit(1)
print(f"OK  data/wf_actions.json ({wf['count']})")
print(f"OK  data/appintents.json ({ai['count']})")
print('OK  doc count claims match SSOT')
print('OK  markdown complete lists match SSOT')
PY

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
  grep -qE 'is\.workflow\.actions\.(choosefrommenu|conditional|repeat\.count|repeat\.each)' "$f"
}

while IFS= read -r -d '' file; do
  if is_stub "$file"; then
    note "skip grammar (stub): $file"
    continue
  fi
  checked_grammar=$((checked_grammar + 1))
  file_ok=1

  if grep -qF "$FFFC" "$file"; then
    if ! grep -q 'attachmentsByRange' "$file"; then
      fail "$file (U+FFFC present without attachmentsByRange)"
      file_ok=0
    fi
  fi

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

  if grep -q 'is\.workflow\.actions\.savefile' "$file"; then
    fail "$file (invalid action id savefile; use documentpicker.save)"
    file_ok=0
  fi

  while IFS= read -r uuid; do
    if [[ "$uuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
      upper="$(printf '%s' "$uuid" | tr '[:lower:]' '[:upper:]')"
      if [[ "$uuid" != "$upper" ]]; then
        fail "$file (UUID not uppercase: $uuid)"
        file_ok=0
      fi
    elif [[ "$uuid" =~ ^[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}$ ]]; then
      # Looks like UUID shape but non-hex (e.g. GGGGGGGG-...)
      fail "$file (UUID not hex: $uuid)"
      file_ok=0
    fi
  done < <(grep -oE '[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}' "$file" || true)

  if [[ "$file_ok" -eq 1 ]]; then
    pass "$file"
  fi
done < <(find templates -type f \( -name '*.plist' -o -name '*.xml' \) -print0 2>/dev/null)

# --- Deeper grammar (10/10 prep; already green on goldens) ---
echo "== Grammar deep (check_shortcut_grammar.py) =="
if python3 scripts/check_shortcut_grammar.py templates/; then
  :
else
  failures=$((failures + 1))
fi

echo
echo "Checked: xml=$checked_xml shell=$checked_sh grammar=$checked_grammar failures=$failures"
if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
echo "All checks passed."
