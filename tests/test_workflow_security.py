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

    def test_dispatch_is_bound_to_the_exact_protected_default_branch_workflow(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        self.assertIn("# verified-hashes-v1", text)
        self.assertIn("github.ref_protected == true", text)
        self.assertIn(
            "github.ref == format('refs/heads/{0}', github.event.repository.default_branch)",
            text,
        )
        self.assertIn(
            "endsWith(github.workflow_ref, format('@refs/heads/{0}', github.event.repository.default_branch))",
            text,
        )
        self.assertIn("persist-credentials: false", text)
        self.assertIn("ref: ${{ github.sha }}", text)
        setup = named_step_run(text, "Setup Git")
        self.assertIn('git checkout -B "$DEFAULT_BRANCH" "$GITHUB_SHA"', setup)

    def test_verified_handoff_has_exact_inputs_run_name_and_commit_trailers(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        for name in (
            "darwin_amd64_sha256",
            "darwin_arm64_sha256",
            "linux_amd64_sha256",
            "linux_arm64_sha256",
            "source_tag_commit",
            "source_tag_object",
            "request_id",
        ):
            self.assertRegex(text, rf"(?m)^      {name}:$")
        self.assertIn(
            "(request-id={0}; source-tag-object={1}; source-tag-commit={2})",
            text,
        )
        push = named_step_run(text, "Commit and push")
        for trailer in (
            "Source-Repository: ${REPOSITORY}",
            "Source-Tag-Object: ${SOURCE_TAG_OBJECT}",
            "Source-Tag-Commit: ${SOURCE_TAG_COMMIT}",
            "Request-ID: ${REQUEST_ID}",
        ):
            self.assertIn(trailer, push)
        self.assertIn("unset GH_TOKEN", push)
        pushed = push.index('git push origin "HEAD:refs/heads/${DEFAULT_BRANCH}"')
        remote_proof = push.index('if [ "$remote_head" != "$local_head" ]; then', pushed)
        post_push_revalidation = push.index("revalidate_verified_source_tag", remote_proof)
        self.assertLess(remote_proof, post_push_revalidation)

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
                "DARWIN_AMD64_SHA256": "",
                "DARWIN_ARM64_SHA256": "",
                "DESCRIPTION": "",
                "FORMULA": payload,
                "LINUX_AMD64_SHA256": "",
                "LINUX_ARM64_SHA256": "",
                "LINUX_URL": "",
                "MACOS_ARTIFACT": "",
                "REPOSITORY": "openclaw/example",
                "REQUEST_ID": "",
                "SOURCE_TAG_COMMIT": "",
                "SOURCE_TAG_OBJECT": "",
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
        self.assertIn('git pull --rebase origin "$DEFAULT_BRANCH"', push_step)
        self.assertIn("python3 -m unittest discover -s tests -v", push_step)
        self.assertIn("brew style Formula/*.rb", push_step)
        self.assertIn('git push origin "HEAD:refs/heads/${DEFAULT_BRANCH}"', push_step)

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
            gh() {{ :; }}
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
                    "DEFAULT_BRANCH": "main",
                    "FORMULA": "gogcli",
                    "GITHUB_SHA": "a" * 40,
                    "PULLED_FILE": str(pulled),
                    "REPOSITORY": "openclaw/gogcli",
                    "REQUEST_ID": "legacy-request",
                    "SOURCE_TAG_COMMIT": "",
                    "SOURCE_TAG_OBJECT": "",
                    "TAG": "v1.2.3",
                },
                check=True,
            )

            self.assertEqual(attempts.read_text(), "2")
            self.assertTrue(pulled.exists())

    def test_verified_noop_fails_without_commit_or_push(self) -> None:
        script = named_step_run(UPDATE_WORKFLOW.read_text(), "Commit and push")
        with tempfile.TemporaryDirectory() as directory:
            temp = pathlib.Path(directory)
            mutation = temp / "mutation"
            harness = f'''git() {{
              case "$1" in
                add) return 0 ;;
                diff) return 0 ;;
                commit|push) touch "$MUTATION_FILE" ;;
              esac
            }}
            gh() {{ touch "$MUTATION_FILE"; }}
            {script}
            '''
            completed = subprocess.run(
                ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                cwd=ROOT,
                env={
                    **os.environ,
                    "CASK": "",
                    "FORMULA": "telecrawl",
                    "MUTATION_FILE": str(mutation),
                    "SOURCE_TAG_OBJECT": "d" * 40,
                },
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertNotEqual(completed.returncode, 0)
            self.assertIn("without a direct-child provenance commit", completed.stderr)
            self.assertFalse(mutation.exists())

    def test_verified_push_fails_closed_without_rebase_when_main_advances(self) -> None:
        script = named_step_run(UPDATE_WORKFLOW.read_text(), "Commit and push")
        with tempfile.TemporaryDirectory() as directory:
            temp = pathlib.Path(directory)
            pulled = temp / "pulled"
            pushed = temp / "pushed"
            harness = f'''git() {{
              case "$1" in
                add|commit) return 0 ;;
                diff) return 1 ;;
                ls-remote) printf '%s\trefs/heads/main\n' "{'b' * 40}" ;;
                push) touch "$PUSHED_FILE" ;;
                pull) touch "$PULLED_FILE" ;;
              esac
            }}
            gh() {{ :; }}
            python3() {{ touch "$REVALIDATED_FILE"; }}
            {script}
            '''
            completed = subprocess.run(
                ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                cwd=ROOT,
                env={
                    **os.environ,
                    "CASK": "",
                    "ARTIFACT_TEMPLATE": "{formula}_{version}_{target}.tar.gz",
                    "DARWIN_AMD64_SHA256": "1" * 64,
                    "DARWIN_ARM64_SHA256": "2" * 64,
                    "DEFAULT_BRANCH": "main",
                    "FORMULA": "telecrawl",
                    "GITHUB_SHA": "a" * 40,
                    "LINUX_AMD64_SHA256": "3" * 64,
                    "LINUX_ARM64_SHA256": "4" * 64,
                    "PULLED_FILE": str(pulled),
                    "PUSHED_FILE": str(pushed),
                    "REVALIDATED_FILE": str(temp / "revalidated"),
                    "REPOSITORY": "openclaw/telecrawl",
                    "REQUEST_ID": "telecrawl-v0.3.4-123",
                    "SOURCE_TAG_COMMIT": "c" * 40,
                    "SOURCE_TAG_OBJECT": "d" * 40,
                    "TAG": "v0.3.4",
                },
                check=False,
            )

            self.assertNotEqual(completed.returncode, 0)
            self.assertTrue((temp / "revalidated").exists())
            self.assertFalse(pulled.exists())
            self.assertFalse(pushed.exists())

    def test_verified_push_revalidates_and_confirms_exact_remote_head(self) -> None:
        script = named_step_run(UPDATE_WORKFLOW.read_text(), "Commit and push")
        with tempfile.TemporaryDirectory() as directory:
            temp = pathlib.Path(directory)
            pushed = temp / "pushed"
            revalidation_count = temp / "revalidation-count"
            remote_proved = temp / "remote-proved"
            token_leak = temp / "token-leak"
            local_head = "e" * 40
            event_head = "a" * 40
            harness = f'''git() {{
              case "$1" in
                add|commit) return 0 ;;
                diff) return 1 ;;
                ls-remote)
                  if [ -f "$PUSHED_FILE" ]; then
                    touch "$REMOTE_PROVED_FILE"
                    printf '%s\trefs/heads/main\n' "$LOCAL_HEAD"
                  else
                    printf '%s\trefs/heads/main\n' "$GITHUB_SHA"
                  fi
                  ;;
                push) touch "$PUSHED_FILE" ;;
                pull) touch "$PULLED_FILE" ;;
                rev-parse) printf '%s\n' "$LOCAL_HEAD" ;;
              esac
            }}
            gh() {{ [ -n "${{GH_TOKEN:-}}" ]; }}
            python3() {{
              if [ -n "${{GH_TOKEN:-}}" ]; then
                touch "$TOKEN_LEAK_FILE"
                return 1
              fi
              count=0
              if [ -f "$REVALIDATION_COUNT_FILE" ]; then count=$(cat "$REVALIDATION_COUNT_FILE"); fi
              count=$((count + 1))
              if [ "$count" -eq 2 ] && [ ! -f "$REMOTE_PROVED_FILE" ]; then
                return 1
              fi
              printf '%s' "$count" > "$REVALIDATION_COUNT_FILE"
            }}
            {script}
            '''
            completed = subprocess.run(
                ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                cwd=ROOT,
                env={
                    **os.environ,
                    "ARTIFACT_TEMPLATE": "{formula}_{version}_{target}.tar.gz",
                    "CASK": "",
                    "DARWIN_AMD64_SHA256": "1" * 64,
                    "DARWIN_ARM64_SHA256": "2" * 64,
                    "DEFAULT_BRANCH": "main",
                    "FORMULA": "telecrawl",
                    "GH_TOKEN": "test-token",
                    "GITHUB_SHA": event_head,
                    "LINUX_AMD64_SHA256": "3" * 64,
                    "LINUX_ARM64_SHA256": "4" * 64,
                    "LOCAL_HEAD": local_head,
                    "PULLED_FILE": str(temp / "pulled"),
                    "PUSHED_FILE": str(pushed),
                    "REMOTE_PROVED_FILE": str(remote_proved),
                    "REPOSITORY": "openclaw/telecrawl",
                    "REQUEST_ID": "telecrawl-v0.3.4-123",
                    "REVALIDATION_COUNT_FILE": str(revalidation_count),
                    "SOURCE_TAG_COMMIT": "c" * 40,
                    "SOURCE_TAG_OBJECT": "d" * 40,
                    "TAG": "v0.3.4",
                    "TOKEN_LEAK_FILE": str(token_leak),
                },
                check=False,
            )

            self.assertEqual(completed.returncode, 0)
            self.assertEqual(revalidation_count.read_text(), "2")
            self.assertTrue(remote_proved.exists())
            self.assertFalse(token_leak.exists())
            self.assertTrue(pushed.exists())
            self.assertFalse((temp / "pulled").exists())


if __name__ == "__main__":
    unittest.main()
