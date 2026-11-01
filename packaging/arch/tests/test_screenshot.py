"""Headless workflow checks: python3 -m unittest discover -s packaging/arch/tests."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest


ROOT = Path(__file__).resolve().parents[3]
MOCK = r'''
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
with open(os.environ["CALLS"], "a") as log:
    log.write(json.dumps([name, sys.argv[1:]]) + "\n")
if name == "slurp":
    print("-1920,20 640x480")
    sys.exit(int(os.environ.get("CANCEL", "0")))
elif name == "hyprctl":
    print(os.environ["WINDOW"] if "activewindow" in sys.argv else os.environ["MONITORS"])
elif name == "grim":
    pathlib.Path(sys.argv[-1]).write_bytes(b"PNG")
    sys.exit(int(os.environ.get("GRIM_FAIL", "0")))
elif name == "wl-copy":
    assert sys.stdin.buffer.read() == b"PNG"
'''


class ScreenshotTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="screenshot-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.bin = self.base / "bin"
        self.bin.mkdir()
        for name in ("bash", "mkdir", "mktemp", "date", "rm", "jq"):
            self.bin.joinpath(name).symlink_to(shutil.which(name))
        for name in ("slurp", "grim", "wl-copy", "satty", "hyprctl"):
            script = self.bin / name
            script.write_text(f"#!{sys.executable}\n" + MOCK)
            script.chmod(0o755)
        self.config = self.base / "config" / "hypr"
        self.config.mkdir(parents=True)
        shutil.copy2(ROOT / "satty.toml", self.config)
        self.env = dict(os.environ, PATH=str(self.bin), HOME=str(self.base),
                        XDG_CONFIG_HOME=str(self.base / "config"),
                        SCREENSHOT_DIR=str(self.base / "shots with spaces"),
                        CALLS=str(self.base / "calls"),
                        WINDOW='{"mapped":true,"at":[-1800,40],"size":[800,600]}',
                        MONITORS='[{"name":"DP-1","focused":true}]')

    def run_capture(self, *args, **env):
        return subprocess.run([str(self.bin / "bash"), str(ROOT / "screenshot.sh"), *args],
                              env=dict(self.env, **env), capture_output=True, text=True)

    def calls(self, name):
        log = self.base / "calls"
        return [args for cmd, args in map(json.loads, log.read_text().splitlines())
                if cmd == name] if log.exists() else []

    def shots(self):
        return list(Path(self.env["SCREENSHOT_DIR"]).glob("*.png"))

    def test_region_and_config(self):
        result = self.run_capture()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("grim")[0][:2], ["-g", "-1920,20 640x480"])
        self.assertEqual(len(self.shots()), 1)
        self.assertEqual(self.shots()[0].stat().st_mode & 0o777, 0o600)
        self.assertEqual(self.calls("wl-copy"), [["--type", "image/png"]])
        self.assertEqual(self.calls("satty")[0][:2],
                         ["--config", str(self.config / "satty.toml")])

    def test_window(self):
        result = self.run_capture("window")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("grim")[0][:2], ["-g", "-1800,40 800x600"])
        self.assertFalse(self.calls("slurp"))

    def test_monitor(self):
        result = self.run_capture("monitor")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls("grim")[0][:2], ["-o", "DP-1"])

    def test_full_without_satty(self):
        (self.bin / "satty").unlink()
        result = self.run_capture("full")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls("grim")[0]), 1)
        self.assertEqual(len(self.shots()), 1)

    def test_cancel_does_not_capture(self):
        self.assertEqual(self.run_capture(CANCEL="1").returncode, 0)
        self.assertFalse(self.calls("grim"))
        self.assertFalse(self.shots())

    def test_empty_window_does_not_capture(self):
        self.assertNotEqual(self.run_capture("window", WINDOW="{}").returncode, 0)
        self.assertFalse(self.calls("grim"))
        self.assertFalse(self.shots())

    def test_failed_capture_removes_file(self):
        self.assertNotEqual(self.run_capture("full", GRIM_FAIL="1").returncode, 0)
        self.assertFalse(self.shots())
        self.assertFalse(self.calls("wl-copy"))

    def test_missing_config_uses_fallback(self):
        (self.config / "satty.toml").unlink()
        self.assertEqual(self.run_capture("full").returncode, 0)
        self.assertIn("--save-after-copy", self.calls("satty")[0])

    def test_invalid_arguments(self):
        self.assertEqual(self.run_capture("unknown").returncode, 2)
        self.assertEqual(self.run_capture("full", "extra").returncode, 2)
        self.assertFalse(self.calls("grim"))

    def test_config_is_valid_toml(self):
        config = tomllib.loads((ROOT / "satty.toml").read_text())
        self.assertTrue(config["general"]["save-after-copy"])
        self.assertEqual(config["general"]["actions-on-enter"], ["save-to-clipboard"])


if __name__ == "__main__":
    unittest.main()
