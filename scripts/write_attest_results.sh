#!/usr/bin/env bash
# Aggregate attestation TSV reports into fixtures/attested/results.json
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS="${ROOT}/fixtures/attested/runs"
OUT="${ROOT}/fixtures/attested/results.json"

mkdir -p "$RUNS"

python3 - "$ROOT" "$OUT" <<'PY'
import json, os, sys, platform, datetime, pathlib

root = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
runs = root / "fixtures" / "attested" / "runs"
hashes = root / "fixtures" / "attested" / "hashes.sha256"

def read_tsv(path):
    rows = []
    if not path.exists():
        return rows
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines:
        return rows
    headers = lines[0].split("\t")
    for line in lines[1:]:
        if not line.strip():
            continue
        parts = line.split("\t")
        row = {headers[i]: (parts[i] if i < len(parts) else "") for i in range(len(headers))}
        rows.append(row)
    return rows

import_rows = read_tsv(runs / "import_report.tsv")
run_rows = read_tsv(runs / "run_report.tsv")

hash_lines = []
if hashes.exists():
    hash_lines = [ln for ln in hashes.read_text().splitlines() if ln.strip()]

def tally(rows, key="result"):
    t = {"OK": 0, "FAIL": 0, "SKIP": 0, "other": 0}
    for r in rows:
        v = (r.get(key) or "").upper()
        if v in t:
            t[v] += 1
        else:
            t["other"] += 1
    return t

payload = {
    "schema": "shortcuts-attest-results/v1",
    "generated_at_utc": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "machine": {
        "hostname": platform.node(),
        "system": platform.system(),
        "release": platform.release(),
        "macOS": None,
    },
    "skill_version": None,
    "hashes_file": "fixtures/attested/hashes.sha256",
    "hash_count": len(hash_lines),
    "import": {"rows": import_rows, "tally": tally(import_rows)},
    "run": {"rows": run_rows, "tally": tally(run_rows)},
    "pass": True,
}

# skill version
skill = root / "SKILL.md"
if skill.exists():
    for line in skill.read_text().splitlines()[:30]:
        if line.startswith("version:"):
            payload["skill_version"] = line.split(":", 1)[1].strip()
            break

# macOS version via sw_vers when present
import subprocess
try:
    ver = subprocess.check_output(["sw_vers", "-productVersion"], text=True).strip()
    payload["machine"]["macOS"] = ver
except Exception:
    pass

fail_import = payload["import"]["tally"]["FAIL"]
fail_run = payload["run"]["tally"]["FAIL"]
payload["pass"] = fail_import == 0 and fail_run == 0
payload["summary"] = (
    f"import OK={payload['import']['tally']['OK']} FAIL={fail_import} SKIP={payload['import']['tally']['SKIP']}; "
    f"run OK={payload['run']['tally']['OK']} FAIL={fail_run} SKIP={payload['run']['tally']['SKIP']}"
)

out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {out}")
print(payload["summary"])
print("PASS" if payload["pass"] else "FAIL")
sys.exit(0 if payload["pass"] else 1)
PY
