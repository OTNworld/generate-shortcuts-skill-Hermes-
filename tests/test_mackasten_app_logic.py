#!/usr/bin/env python3
"""Linux mirrors of Mackasten iOS pure logic (deep link, policy, URL encode, decode)."""

from __future__ import annotations

import json
import unittest
import urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # repo root
APP = ROOT / "mackasten" / "app"
FIXTURES = APP / "MackastenTests" / "Fixtures" / "packages"
PACKAGES = ROOT / "mackasten" / "packages"

ALLOWED_PREFIXES = ("templates/", "mackasten/", "horizon/")


def sanitize_path(path: str) -> str | None:
    trimmed = path.strip()
    if not trimmed or trimmed.startswith("/") or "\\" in trimmed:
        return None
    if ".." in trimmed.split("/"):
        return None
    if not any(trimmed.startswith(p) for p in ALLOWED_PREFIXES):
        return None
    return trimmed


def parse_edit_url(url: str) -> str | None:
    parts = urllib.parse.urlparse(url)
    if (parts.scheme or "").lower() != "hermes-shortcuts":
        return None
    host = (parts.hostname or "").lower()
    path_part = (parts.path or "").strip("/")
    if host != "edit" and path_part != "edit" and not path_part.startswith("edit/"):
        return None
    qs = urllib.parse.parse_qs(parts.query)
    raw = (qs.get("path") or [None])[0]
    if not raw:
        return None
    return sanitize_path(raw)


def run_shortcut_url(name: str) -> str:
    q = urllib.parse.urlencode({"name": name})
    return f"shortcuts://run-shortcut?{q}"


def violates_local_cloud(pkg: dict) -> bool:
    return str(pkg.get("id", "")).startswith("local-") and pkg.get("model_policy") == "cloud-allowed"


class MackastenAppLogicTests(unittest.TestCase):
    def test_fixtures_decode(self):
        src = FIXTURES if FIXTURES.is_dir() else PACKAGES
        ids = []
        for man in sorted(src.glob("*/package.json")):
            data = json.loads(man.read_text())
            self.assertIn(data["schema"], ("mackasten-package/v1", "horizon-package/v1"))
            self.assertTrue(data["id"])
            self.assertTrue(data["shortcuts"])
            ids.append(data["id"])
        for need in ("hello-world", "clipboard-set", "local-ask-llm", "local-rewrite"):
            self.assertIn(need, ids)

    def test_deep_link_ok(self):
        url = "hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml"
        self.assertEqual(
            parse_edit_url(url),
            "templates/examples/01-hello-world.shortcut.xml",
        )

    def test_deep_link_traversal(self):
        self.assertIsNone(parse_edit_url("hermes-shortcuts://edit?path=../../etc/passwd"))

    def test_deep_link_missing(self):
        self.assertIsNone(parse_edit_url("hermes-shortcuts://edit"))

    def test_url_builder_encodes_spaces(self):
        url = run_shortcut_url("Hello World")
        self.assertTrue(url.startswith("shortcuts://run-shortcut?"))
        self.assertIn("Hello", url)
        self.assertTrue("Hello%20World" in url or "Hello+World" in url)

    def test_local_cloud_policy(self):
        pkg = {
            "id": "local-x",
            "model_policy": "cloud-allowed",
            "schema": "mackasten-package/v1",
        }
        self.assertTrue(violates_local_cloud(pkg))
        self.assertFalse(
            violates_local_cloud({"id": "hello-world", "model_policy": "none"})
        )


if __name__ == "__main__":
    raise SystemExit(unittest.main())
