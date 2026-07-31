#!/usr/bin/env bash
# Push mackasten/app seed into private OTNworld/Mackasten.
# Requires: git auth that can write to the private repo (your PAT or Cursor App install).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SEED_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_ROOT="$(cd "$SEED_ROOT/../.." && pwd)"
REPO_URL="${MACKASTEN_REPO_URL:-https://github.com/OTNworld/Mackasten.git}"
BRANCH="${MACKASTEN_BRANCH:-main}"
WORKDIR="${MACKASTEN_WORKDIR:-$(mktemp -d /tmp/mackasten-seed.XXXXXX)}"

echo "SEED_ROOT=$SEED_ROOT"
echo "REPO_URL=$REPO_URL"
echo "WORKDIR=$WORKDIR"

if ! git ls-remote "$REPO_URL" HEAD >/dev/null 2>&1; then
  echo "FAIL cannot access $REPO_URL" >&2
  echo "Install the Cursor/GitHub App on OTNworld/Mackasten (see REPO_BOOTSTRAP.md)." >&2
  exit 1
fi

git clone "$REPO_URL" "$WORKDIR/Mackasten"
cd "$WORKDIR/Mackasten"

# Copy seed onto repo root (do not delete unrelated user files if any)
rsync -a --exclude Vendor --exclude .git "$SEED_ROOT"/ ./

git add -A
if git diff --cached --quiet; then
  echo "OK  nothing to commit (seed already present)"
else
  git commit -m "Seed Mackasten companion app from skill mackasten/app"
fi

git push -u origin "$BRANCH"
echo "DONE pushed seed to $REPO_URL ($BRANCH)"
echo "Local checkout: $WORKDIR/Mackasten"
