import os
import pathlib
import subprocess
import unittest


class IntelHomebrewSetupTests(unittest.TestCase):
    def test_refuses_non_disposable_macos_environments(self):
        script = pathlib.Path(__file__).with_name("setup_intel_homebrew.sh")
        environments = [
            {},
            {"GITHUB_ACTIONS": "true", "RUNNER_ENVIRONMENT": "self-hosted", "RUNNER_OS": "macOS"},
            {"GITHUB_ACTIONS": "true", "RUNNER_ENVIRONMENT": "github-hosted", "RUNNER_OS": "Linux"},
        ]
        for environment in environments:
            with self.subTest(environment=environment):
                result = subprocess.run(
                    ["/bin/bash", str(script)],
                    env={"PATH": os.defpath, **environment},
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertEqual(result.returncode, 1)
                self.assertIn("restricted to disposable GitHub-hosted macOS runners", result.stderr)


if __name__ == "__main__":
    unittest.main()
