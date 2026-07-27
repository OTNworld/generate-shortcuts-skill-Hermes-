#!/usr/bin/env bash
# Fetch horizon-package manifests + shortcut XML from the public skill repo
# into Vendor/SkillPackages/ for the Horizon iOS app.
#
# From skill monorepo (dev):
#   ./horizon/app/scripts/fetch_skill_packages.sh
#
# From private app repo (script at ./scripts/ or ./horizon leftover):
#   SKILL_REF=v1.16.0 ./scripts/fetch_skill_packages.sh
#
# Env:
#   SKILL_REPO_URL  default GitHub skill URL
#   SKILL_REF       pin tag/SHA (warn if main)
#   OUT_DIR         output directory
#   SKILL_LOCAL     existing skill checkout (skip clone)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_REPO_URL="${SKILL_REPO_URL:-https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git}"
SKILL_REF="${SKILL_REF:-main}"

# Detect layout:
#  A) skill repo:  <skill>/horizon/app/scripts/this.sh  + <skill>/horizon/packages
#  B) app repo:    <app>/scripts/this.sh               + no local packages (clone)
SKILL_ROOT=""
APP_ROOT=""
if [[ -d "$SCRIPT_DIR/../../packages" && -f "$SCRIPT_DIR/../../packages/hello-world/package.json" ]]; then
  SKILL_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  OUT_DIR="${OUT_DIR:-$SKILL_ROOT/horizon/app/Vendor/SkillPackages}"
elif [[ -d "$SCRIPT_DIR/../horizon/packages" ]]; then
  SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  OUT_DIR="${OUT_DIR:-$SKILL_ROOT/Vendor/SkillPackages}"
else
  APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  OUT_DIR="${OUT_DIR:-$APP_ROOT/Vendor/SkillPackages}"
fi

if [[ "$SKILL_REF" == "main" ]]; then
  echo "WARN SKILL_REF=main is floating — pin a tag/SHA for release builds" >&2
fi

TMP=""
cleanup() {
  if [[ -n "${TMP}" && -d "${TMP}" ]]; then
    rm -rf "${TMP}"
  fi
}
trap cleanup EXIT

if [[ -n "${SKILL_LOCAL:-}" ]]; then
  SKILL_ROOT="$(cd "$SKILL_LOCAL" && pwd)"
elif [[ -z "$SKILL_ROOT" ]]; then
  TMP="$(mktemp -d)"
  echo "Cloning $SKILL_REPO_URL @$SKILL_REF …"
  if git clone --depth 1 --branch "$SKILL_REF" "$SKILL_REPO_URL" "$TMP/skill" 2>/dev/null; then
    :
  else
    git clone --depth 1 "$SKILL_REPO_URL" "$TMP/skill"
    git -C "$TMP/skill" fetch --depth 1 origin "$SKILL_REF"
    git -C "$TMP/skill" checkout "$SKILL_REF"
  fi
  SKILL_ROOT="$TMP/skill"
fi

PACKAGES_SRC="$SKILL_ROOT/horizon/packages"
SCHEMA_SRC="$SKILL_ROOT/data/schemas/horizon-package.v1.json"

if [[ ! -d "$PACKAGES_SRC" ]]; then
  echo "FAIL no horizon/packages in $SKILL_ROOT" >&2
  exit 1
fi
if [[ ! -f "$SCHEMA_SRC" ]]; then
  echo "FAIL missing schema $SCHEMA_SRC" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/schema"
cp "$SCHEMA_SRC" "$OUT_DIR/schema/horizon-package.v1.json"

python3 - "$PACKAGES_SRC" "$SKILL_ROOT" "$OUT_DIR" "$SKILL_REF" <<'PY'
import json, shutil, sys
from pathlib import Path

packages_src = Path(sys.argv[1])
skill_root = Path(sys.argv[2])
out_dir = Path(sys.argv[3])
skill_ref = sys.argv[4]

ids = []
failures = 0
for man in sorted(packages_src.glob("*/package.json")):
    data = json.loads(man.read_text())
    pkg_id = data.get("id") or man.parent.name
    if man.parent.name != pkg_id:
        print(f"FAIL folder {man.parent.name} != id {pkg_id}", file=sys.stderr)
        failures += 1
        continue
    model = data.get("model_policy") or "none"
    if str(pkg_id).startswith("local-") and model == "cloud-allowed":
        print(f"FAIL {pkg_id}: local-* cannot be cloud-allowed", file=sys.stderr)
        failures += 1
        continue

    dest = out_dir / pkg_id
    dest.mkdir(parents=True, exist_ok=True)
    shortcuts_out = dest / "shortcuts"
    shortcuts_out.mkdir(exist_ok=True)

    new_shortcuts = []
    for sc in data.get("shortcuts") or []:
        rel = sc.get("path") or ""
        src = skill_root / rel
        if not src.is_file():
            print(f"FAIL {pkg_id}: missing {rel}", file=sys.stderr)
            failures += 1
            continue
        target_name = src.name
        shutil.copy2(src, shortcuts_out / target_name)
        sc = dict(sc)
        sc["path"] = f"shortcuts/{target_name}"
        sc["skill_path"] = rel
        new_shortcuts.append(sc)

    data["shortcuts"] = new_shortcuts
    data["_horizon_fetch"] = {"skill_ref": skill_ref}
    (dest / "package.json").write_text(json.dumps(data, indent=2) + "\n")
    ids.append(pkg_id)
    print(f"OK  {pkg_id}")

if failures:
    sys.exit(1)
if not ids:
    print("FAIL no packages fetched", file=sys.stderr)
    sys.exit(1)

catalog = {
    "schema": "horizon-catalog/v1",
    "skill_ref": skill_ref,
    "packages": ids,
}
(out_dir / "catalog.json").write_text(json.dumps(catalog, indent=2) + "\n")
print(f"OK  catalog ({len(ids)} packages) → {out_dir}")
PY

if [[ -f "$SKILL_ROOT/scripts/check_json_schema.py" ]]; then
  echo "Validating package.json against schema…"
  python3 - "$OUT_DIR" "$OUT_DIR/schema/horizon-package.v1.json" "$SKILL_ROOT" <<'PY'
import sys
from pathlib import Path

sys.path.insert(0, str(Path(sys.argv[3]) / "scripts"))
from check_json_schema import validate_file  # type: ignore

out_dir = Path(sys.argv[1])
schema = Path(sys.argv[2])
fail = 0
for man in sorted(out_dir.glob("*/package.json")):
    errs = validate_file(man, schema)
    if errs:
        fail += 1
        for e in errs:
            print(f"FAIL {man}: {e}", file=sys.stderr)
    else:
        print(f"OK  schema {man.parent.name}")
sys.exit(fail)
PY
fi

echo "DONE $OUT_DIR"
