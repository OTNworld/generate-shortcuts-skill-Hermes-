#!/usr/bin/env bash
# Cut a Hermes skill GitHub release (dry-run by default).
#
# Usage:
#   ./scripts/cut_release.sh                  # dry-run, mode A (linux-complete)
#   ./scripts/cut_release.sh --mode mac       # dry-run, mode B (mac-attested claims)
#   ./scripts/cut_release.sh --apply          # create annotated tag + gh release (main only)
#   ./scripts/cut_release.sh --notes-only     # write notes file, no tag checks beyond version
#
# Never commits signed binaries. Does not push marketplace listings.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APPLY=0
NOTES_ONLY=0
MODE="linux" # linux | mac
OUT_DIR="${ROOT}/fixtures/release"
NOTES_FILE=""

usage() {
  cat <<'EOF'
Usage: scripts/cut_release.sh [options]

  --mode linux|mac   Release claim profile (default: linux)
  --apply            Create annotated tag + GitHub release (requires main + gh)
  --notes-only       Only write release notes under fixtures/release/
  -h, --help         Show help

Dry-run is the default: prints the plan and writes notes, does not tag.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --notes-only) NOTES_ONLY=1 ;;
    --mode)
      MODE="${2:?}"
      shift
      case "$MODE" in
        linux|mac|A|B) ;;
        *) echo "Unknown mode: $MODE (use linux|mac)" >&2; exit 2 ;;
      esac
      [[ "$MODE" == A ]] && MODE=linux
      [[ "$MODE" == B ]] && MODE=mac
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

fail() { echo "FAIL $*" >&2; exit 1; }
note() { echo "$*"; }

skill_version() {
  python3 - <<'PY'
from pathlib import Path
for line in Path("SKILL.md").read_text().splitlines()[:40]:
    if line.startswith("version:"):
        print(line.split(":", 1)[1].strip())
        break
else:
    raise SystemExit("no version in SKILL.md")
PY
}

en_version() {
  python3 - <<'PY'
from pathlib import Path
for line in Path("SKILL.en.md").read_text().splitlines()[:40]:
    if line.startswith("version:"):
        print(line.split(":", 1)[1].strip())
        break
else:
    raise SystemExit("no version in SKILL.en.md")
PY
}

changelog_has() {
  local ver="$1"
  grep -qE "^## \[${ver}\]" CHANGELOG.md
}

VER="$(skill_version)"
EN_VER="$(en_version)"
TAG="v${VER}"
NOTES_FILE="${OUT_DIR}/RELEASE_${TAG}_${MODE}.md"
mkdir -p "$OUT_DIR"

note "== cut_release =="
note "skill_version: $VER"
note "mode: $MODE"
note "tag: $TAG"
note "apply: $APPLY"

[[ "$VER" == "$EN_VER" ]] || fail "SKILL.md version ($VER) != SKILL.en.md ($EN_VER)"
changelog_has "$VER" || fail "CHANGELOG.md missing ## [$VER] section"

# Extract changelog section for this version
SECTION="$(
  VER="$VER" python3 - <<'PY'
from pathlib import Path
import os, re
text = Path("CHANGELOG.md").read_text()
ver = os.environ["VER"]
pat = rf"^## \[{re.escape(ver)}\].*?$(.*?)(?=^## \[|\Z)"
m = re.search(pat, text, flags=re.M | re.S)
if not m:
    raise SystemExit(f"section not found for {ver}")
print(m.group(1).strip())
PY
)"

if [[ "$MODE" == "linux" ]]; then
  MAC_CLAIM="**Mac attestation:** baseline remains **v1.10.0** MATRIX. Deltas in 1.11.0–${VER} (palette 13–16, community 17–18, AppIntents \`unverified\`, Horizon packages) are **CI/Linux-validated**; device re-attest is tracked in \`references/MAC_10_CHECKLIST.md\`."
  TITLE_SUFFIX="Linux-complete (Mac attest pending for post-1.10 deltas)"
else
  MAC_CLAIM="**Mac attestation:** intended for use after \`MAC_10_CHECKLIST\` is completed on device. Confirm \`fixtures/attested/MATRIX.md\` + \`results.json\` \`skill_version\` == **${VER}** before publishing this claim. If MATRIX is still on an older skill version, use \`--mode linux\` instead."
  TITLE_SUFFIX="Mac-attested track (verify MATRIX before publish)"
fi

cat >"$NOTES_FILE" <<EOF
# ${TAG} — Shortcuts Generator Skill (Hermes)

${TITLE_SUFFIX}

## Highlights

${SECTION}

## Support matrix (honest)

| Surface | Status |
|---------|--------|
| Linux CI (\`validate\` / \`selftest\` / schemas / sources) | Supported |
| macOS sign → import → run | See Mac claim below |
| iOS | Best-effort / **not** systematically attested |
| Horizon marketplace packages | **Paper MVP** (\`horizon/packages/\`) — not an App Store product |
| AppIntents listed in \`unverified\` | SSOT only — **no** teaching \`appintentexecution\` goldens yet |

${MAC_CLAIM}

## Security / license

- Skill license: **MIT** (this repository).
- Upstream lineage \`drewocarr/generate-shortcuts-skill\`: license **unspecified** — link only (see \`THIRD_PARTY_NOTICES.md\`).
- Community goldens from Viticci playground: **MIT**, attributed.
- Do not distribute \`*_signed.shortcut\` binaries from attestation runs.

## Install (Hermes)

\`\`\`bash
mkdir -p ~/.hermes/skills
cd ~/.hermes/skills
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git shortcuts-generator
cd shortcuts-generator && git checkout ${TAG}
\`\`\`

## Agent map

See \`references/AGENT_ENTRY.md\`, \`references/RELEASE.md\`.
EOF

note "Wrote $NOTES_FILE"

if [[ "$NOTES_ONLY" -eq 1 ]]; then
  note "notes-only: done"
  exit 0
fi

note "== preflight checks =="
./scripts/validate.sh
./scripts/selftest.sh

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
note "git branch: $BRANCH"

if [[ "$APPLY" -eq 0 ]]; then
  note
  note "DRY-RUN OK — no tag created."
  note "Next:"
  note "  1. Merge to main + CI green"
  note "  2. git checkout main && git pull"
  note "  3. ./scripts/cut_release.sh --mode $MODE --apply"
  exit 0
fi

# --- apply path ---
[[ "$BRANCH" == "main" ]] || fail "--apply requires branch main (now on $BRANCH)"

# Ensure clean tree
if [[ -n "$(git status --porcelain)" ]]; then
  fail "working tree not clean; commit or stash first"
fi

# Remote main sync hint
git fetch origin main >/dev/null 2>&1 || true
LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse origin/main 2>/dev/null || true)"
if [[ -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
  fail "HEAD ($LOCAL) != origin/main ($REMOTE); pull/rebase first"
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  fail "tag $TAG already exists locally"
fi
if git ls-remote --tags origin "refs/tags/${TAG}" | grep -q "$TAG"; then
  fail "tag $TAG already exists on origin"
fi

if ! command -v gh >/dev/null 2>&1; then
  fail "gh CLI required for --apply"
fi

note "Creating annotated tag $TAG"
git tag -a "$TAG" -m "Release ${TAG} (${MODE})"
note "Pushing tag"
git push origin "$TAG"

note "Creating GitHub release"
gh release create "$TAG" \
  --title "${TAG} — ${TITLE_SUFFIX}" \
  --notes-file "$NOTES_FILE"

note "APPLY OK — ${TAG} published"
note "Reminder: marketplace listings (LobeHub/Cursor) remain manual."
