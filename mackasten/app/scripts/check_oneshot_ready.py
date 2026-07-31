#!/usr/bin/env python3
"""Ensure mackasten/app oneshot blueprint + Swift scaffold files exist."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # mackasten/app

REQUIRED = [
    "README.md",
    "SKILL.md",
    "VISION.md",
    "REQUIREMENTS.md",
    "ARCHITECTURE.md",
    "ONESHOT_PLAN.md",
    "CHECKLIST.md",
    "CI_FETCH.md",
    "REPO_BOOTSTRAP.md",
    "sources.json",
    "project.yml",
    "SkillPin.env.example",
    ".gitignore",
    ".github/workflows/fetch-packages.yml",
    "scripts/fetch_skill_packages.sh",
    "references/MARKETPLACE.md",
    "references/URL_SCHEME.md",
    "references/LOCAL_MODELS.md",
    "references/APP_INTENTS.md",
    "references/TESTING.md",
    "references/DESIGN.md",
    "Mackasten/Info.plist",
    "Mackasten/App/MackastenApp.swift",
    "Mackasten/App/RootTabView.swift",
    "Mackasten/Models/MackastenPackage.swift",
    "Mackasten/DeepLink/HermesShortcutsRouter.swift",
    "Mackasten/ShortcutsBridge/ShortcutsURLBuilder.swift",
    "Mackasten/Catalog/PackageCatalogStore.swift",
    "Mackasten/Intents/MackastenIntents.swift",
    "Mackasten/Intents/MackastenAppShortcuts.swift",
    "Mackasten/Library/InstalledPackage.swift",
    "Resources/PrivacyInfo.xcprivacy",
    "MackastenTests/MackastenLogicTests.swift",
    "MackastenTests/Fixtures/packages/hello-world/package.json",
]


def main() -> int:
    missing = [rel for rel in REQUIRED if not (ROOT / rel).is_file()]
    if missing:
        for m in missing:
            print(f"FAIL missing {m}", file=sys.stderr)
        return 1
    print(f"OK  mackasten/app oneshot scaffold ({len(REQUIRED)} files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
