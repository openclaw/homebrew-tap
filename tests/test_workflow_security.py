from __future__ import annotations

import os
import pathlib
import re
import subprocess
import tempfile
import textwrap
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
UPDATE_WORKFLOW = ROOT / ".github" / "workflows" / "update-formula.yml"
CHECKOUT_SHA = "9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0"


def run_blocks(text: str) -> list[str]:
    lines = text.splitlines()
    blocks: list[str] = []
    for index, line in enumerate(lines):
        match = re.match(r"^(\s*)run:\s*\|\s*$", line)
        if not match:
            continue
        indentation = len(match.group(1))
        body: list[str] = []
        for candidate in lines[index + 1 :]:
            if candidate and len(candidate) - len(candidate.lstrip()) <= indentation:
                break
            body.append(candidate)
        blocks.append(textwrap.dedent("\n".join(body)))
    return blocks


def named_step_run(text: str, name: str) -> str:
    marker = f"      - name: {name}\n"
    step = text.split(marker, 1)[1].split("\n      - name:", 1)[0]
    blocks = run_blocks(step)
    if len(blocks) != 1:
        raise AssertionError(f"expected one run block for {name}, found {len(blocks)}")
    return blocks[0]


class WorkflowSecurityTest(unittest.TestCase):
    def test_actions_are_pinned_to_checkout_v7(self) -> None:
        workflows = (ROOT / ".github" / "workflows").glob("*.yml")
        for workflow in workflows:
            text = workflow.read_text()
            for reference in re.findall(r"uses:\s*actions/checkout@([^\s]+)", text):
                self.assertEqual(reference, CHECKOUT_SHA, workflow)

    def test_dispatch_inputs_are_not_interpolated_in_shell_source(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        blocks = run_blocks(text)
        self.assertTrue(blocks)
        for block in blocks:
            self.assertNotIn("${{ inputs.", block)
        self.assertNotIn("GITHUB_TOKEN", text)
        self.assertNotIn("GITHUB_TOKEN", (ROOT / ".github" / "scripts" / "update_formula.py").read_text())

    def test_update_step_treats_shell_metacharacters_as_data(self) -> None:
        script = named_step_run(UPDATE_WORKFLOW.read_text(), "Update formula")
        with tempfile.TemporaryDirectory() as directory:
            temp = pathlib.Path(directory)
            capture = temp / "arguments"
            marker = temp / "injected"
            payload = f'$(touch "{marker}")'
            harness = f'''python3() {{
              printf '%s\\0' "$@" > "$CAPTURED_ARGUMENTS"
            }}
            {script}
            '''
            environment = {
                **os.environ,
                "ARTIFACT_TEMPLATE": "",
                "ARTIFACT_URL": "",
                "CAPTURED_ARGUMENTS": str(capture),
                "CASK": "",
                "CASK_ARTIFACT": "",
                "DESCRIPTION": "",
                "FORMULA": payload,
                "LINUX_URL": "",
                "MACOS_ARTIFACT": "",
                "REPOSITORY": "openclaw/example",
                "TAG": "v1.2.3",
                "TARGET_ALIASES": "",
            }
            subprocess.run(
                ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                cwd=ROOT,
                env=environment,
                check=True,
            )

            arguments = capture.read_bytes().split(b"\0")
            self.assertIn(payload.encode(), arguments)
            self.assertFalse(marker.exists())

    def test_dispatch_validates_before_push(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        validation = text.index("      - name: Validate update")
        commit = text.index("      - name: Commit and push")

        self.assertLess(validation, commit)
        step = named_step_run(text, "Validate update")
        self.assertIn("python3 -m unittest discover -s tests -v", step)
        self.assertIn('ruby -c "$formula"', step)
        self.assertIn("brew style Formula/*.rb", step)

        push_step = named_step_run(text, "Commit and push")
        self.assertIn("for attempt in 1 2 3", push_step)
        self.assertIn("git pull --rebase origin main", push_step)
        self.assertIn("python3 -m unittest discover -s tests -v", push_step)
        self.assertIn("brew style Formula/*.rb", push_step)

    def test_push_retries_after_main_advances(self) -> None:
        script = named_step_run(UPDATE_WORKFLOW.read_text(), "Commit and push")
        with tempfile.TemporaryDirectory() as directory:
            temp = pathlib.Path(directory)
            attempts = temp / "attempts"
            pulled = temp / "pulled"
            harness = f'''git() {{
              case "$1" in
                add|commit) return 0 ;;
                diff) return 1 ;;
                push)
                  count=0
                  if [ -f "$ATTEMPTS_FILE" ]; then count=$(cat "$ATTEMPTS_FILE"); fi
                  count=$((count + 1))
                  printf '%s' "$count" > "$ATTEMPTS_FILE"
                  [ "$count" -gt 1 ]
                  ;;
                pull) touch "$PULLED_FILE" ;;
              esac
            }}
            python3() {{ :; }}
            ruby() {{ :; }}
            brew() {{ :; }}
            {script}
            '''
            subprocess.run(
                ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                cwd=ROOT,
                env={
                    **os.environ,
                    "ATTEMPTS_FILE": str(attempts),
                    "CASK": "",
                    "FORMULA": "gogcli",
                    "PULLED_FILE": str(pulled),
                    "TAG": "v1.2.3",
                },
                check=True,
            )

            self.assertEqual(attempts.read_text(), "2")
            self.assertTrue(pulled.exists())


if __name__ == "__main__":
    unittest.main()
