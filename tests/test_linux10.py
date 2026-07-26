#!/usr/bin/env python3
"""Unit tests for Linux 10/10 track (stdlib unittest; pytest-compatible)."""

from __future__ import annotations

import json
import plistlib
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(cmd: list[str], cwd: Path = ROOT) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


class TestCatalogSchemas(unittest.TestCase):
    def test_wf_actions_schema(self):
        r = run(
            [
                "python3",
                "scripts/check_json_schema.py",
                "data/wf_actions.json",
                "data/schemas/wf_actions.v1.json",
            ]
        )
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_appintents_schema(self):
        r = run(
            [
                "python3",
                "scripts/check_json_schema.py",
                "data/appintents.json",
                "data/schemas/appintents.v1.json",
            ]
        )
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_unverified_subset(self):
        ai = json.loads((ROOT / "data/appintents.json").read_text())
        ids = set(ai["identifiers"])
        for u in ai.get("unverified") or []:
            self.assertIn(u, ids)

    def test_platform_hints_keys(self):
        wf = json.loads((ROOT / "data/wf_actions.json").read_text())
        ids = set(wf["identifiers"])
        for k, v in (wf.get("platform_hints") or {}).items():
            self.assertIn(k, ids)
            self.assertIn(v, {"mac", "ios", "both", "unknown"})

    def test_results_schema(self):
        path = ROOT / "fixtures/attested/results.json"
        if not path.exists():
            self.skipTest("no results.json")
        r = run(
            [
                "python3",
                "scripts/check_json_schema.py",
                str(path),
                "data/schemas/attest-results.v1.json",
            ]
        )
        self.assertEqual(r.returncode, 0, r.stderr)


class TestRemix(unittest.TestCase):
    def test_hello_bonjour_fixture(self):
        with tempfile.TemporaryDirectory() as td:
            out = Path(td) / "out.xml"
            r = run(
                [
                    "python3",
                    "scripts/remix_shortcut.py",
                    "fixtures/remix/hello-bonjour.input.xml",
                    "--replace-text",
                    "Hello World!",
                    "Bonjour!",
                    "--output",
                    str(out),
                ]
            )
            self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
            got = plistlib.loads(out.read_bytes())
            exp = plistlib.loads(
                (ROOT / "fixtures/remix/hello-bonjour.expected.xml").read_bytes()
            )
            self.assertEqual(got, exp)

    def test_insert_remove_move(self):
        with tempfile.TemporaryDirectory() as td:
            out = Path(td) / "x.xml"
            r = run(
                [
                    "python3",
                    "scripts/remix_shortcut.py",
                    "templates/examples/01-hello-world.shortcut.xml",
                    "--insert-action",
                    "1",
                    '{"identifier":"delay","parameters":{"WFDelayTime":1}}',
                    "--output",
                    str(out),
                ]
            )
            self.assertEqual(r.returncode, 0, r.stderr)
            data = plistlib.loads(out.read_bytes())
            acts = data["WFWorkflowActions"]
            self.assertEqual(len(acts), 3)
            self.assertIn("delay", acts[1]["WFWorkflowActionIdentifier"])
            out2 = Path(td) / "y.xml"
            r2 = run(
                [
                    "python3",
                    "scripts/remix_shortcut.py",
                    str(out),
                    "--move-action",
                    "1",
                    "0",
                    "--output",
                    str(out2),
                ]
            )
            self.assertEqual(r2.returncode, 0, r2.stderr)
            acts2 = plistlib.loads(out2.read_bytes())["WFWorkflowActions"]
            self.assertIn("delay", acts2[0]["WFWorkflowActionIdentifier"])
            out3 = Path(td) / "z.xml"
            r3 = run(
                [
                    "python3",
                    "scripts/remix_shortcut.py",
                    str(out2),
                    "--remove-action",
                    "0",
                    "--output",
                    str(out3),
                ]
            )
            self.assertEqual(r3.returncode, 0, r3.stderr)
            self.assertEqual(len(plistlib.loads(out3.read_bytes())["WFWorkflowActions"]), 2)


class TestCraig(unittest.TestCase):
    def test_uuid_fix(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "lc.xml"
            p.write_text((ROOT / "fixtures/craig/lc-uuid-hello.shortcut.xml").read_text())
            bad = run(["bash", "scripts/validate_on_write.sh", str(p)])
            self.assertNotEqual(bad.returncode, 0)
            fix = run(["bash", "scripts/validate_on_write.sh", "--fix", str(p)])
            self.assertEqual(fix.returncode, 0, fix.stderr + fix.stdout)
            ok = run(["bash", "scripts/validate_on_write.sh", str(p)])
            self.assertEqual(ok.returncode, 0)

    def test_mode_fix(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "mode.xml"
            p.write_text((ROOT / "fixtures/craig/mode-str.shortcut.xml").read_text())
            self.assertNotEqual(run(["bash", "scripts/validate_on_write.sh", str(p)]).returncode, 0)
            self.assertEqual(
                run(["bash", "scripts/validate_on_write.sh", "--fix", str(p)]).returncode, 0
            )

    def test_savefile_fix(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "sf.xml"
            p.write_text((ROOT / "fixtures/craig/savefile-hello.shortcut.xml").read_text())
            self.assertNotEqual(run(["bash", "scripts/validate_on_write.sh", str(p)]).returncode, 0)
            fix = run(["bash", "scripts/validate_on_write.sh", "--fix", str(p)])
            self.assertEqual(fix.returncode, 0, fix.stderr + fix.stdout)
            text = p.read_text()
            self.assertIn("documentpicker.save", text)
            self.assertNotIn("savefile", text)


class TestSecrets(unittest.TestCase):
    def test_repo_clean(self):
        r = run(["python3", "scripts/check_no_secrets.py"])
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_detects_sk(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "x.xml"
            p.write_text("<string>sk-abcdefghijklmnopqrstuvwxyz12</string>\n")
            r = run(["python3", "scripts/check_no_secrets.py", td])
            self.assertNotEqual(r.returncode, 0)


class TestGrammarStrict(unittest.TestCase):
    def test_hello_ok(self):
        r = run(
            [
                "python3",
                "scripts/check_shortcut_grammar.py",
                "--strict",
                "templates/examples/01-hello-world.shortcut.xml",
            ]
        )
        self.assertEqual(r.returncode, 0, r.stderr + r.stdout)


if __name__ == "__main__":
    unittest.main()
