from __future__ import annotations

import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile
import textwrap
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
UPDATE_WORKFLOW = ROOT / ".github" / "workflows" / "update-formula.yml"
RECONCILE_WORKFLOW = ROOT / ".github" / "workflows" / "reconcile-formulae.yml"
CHECKOUT_SHA = "3d3c42e5aac5ba805825da76410c181273ba90b1"


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

    def test_formula_profile_input_is_forwarded_and_validated_as_data(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        self.assertRegex(text, r"(?m)^      formula_profile:$")
        self.assertIn("FORMULA_PROFILE: ${{ inputs.formula_profile }}", text)
        update = named_step_run(text, "Update formula")
        self.assertIn('args+=(--formula-profile "$FORMULA_PROFILE")', update)
        validation = named_step_run(text, "Validate update")
        self.assertIn('ruby -c "$profile"', validation)
        self.assertIn("brew style Formula/*.rb", validation)

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

    def test_reconciler_is_bound_to_protected_default_branch_and_own_token(self) -> None:
        text = RECONCILE_WORKFLOW.read_text()
        self.assertIn("github.ref_protected == true", text)
        self.assertIn(
            "github.ref == format('refs/heads/{0}', github.event.repository.default_branch)",
            text,
        )
        self.assertIn(
            "endsWith(github.workflow_ref, format('@refs/heads/{0}', github.event.repository.default_branch))",
            text,
        )
        self.assertIn("permissions:\n  contents: write", text)
        self.assertIn("GH_TOKEN: ${{ github.token }}", text)
        self.assertNotIn("TAP_TOKEN", text)
        self.assertIn("persist-credentials: false", text)
        self.assertIn("ref: ${{ github.sha }}", text)
        self.assertIn('git diff --exit-code', named_step_run(text, "Publish validated update"))
        for block in run_blocks(text):
            self.assertNotIn("${{ inputs.", block)

    def test_verified_handoff_has_exact_inputs_run_name_and_commit_trailers(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        self.assertRegex(text, r"(?m)^      assets:$")
        self.assertIn('args+=(--assets-json "$ASSETS_JSON")', text)
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
        publisher = (ROOT / ".github/scripts/publish_formulae.py").read_text()
        for trailer in ("Source-Repository", "Source-Tag-Object", "Source-Tag-Commit", "Request-ID"):
            self.assertIn(trailer, publisher)
        self.assertIn("verify_tag()", publisher)
        self.assertIn("formula_blob", publisher)

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
                "ASSETS_JSON": "",
                "CAPTURED_ARGUMENTS": str(capture),
                "CASK": "",
                "CASK_ARTIFACT": "",
                "DARWIN_AMD64_SHA256": "",
                "DARWIN_ARM64_SHA256": "",
                "DESCRIPTION": "",
                "FORMULA": payload,
                "FORMULA_PROFILE": payload,
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
            self.assertEqual(arguments.count(payload.encode()), 2)
            self.assertFalse(marker.exists())

    def test_dispatch_validates_before_push(self) -> None:
        text = UPDATE_WORKFLOW.read_text()
        validation = text.index("      - name: Validate update")
        commit = text.index("      - name: Publish validated update")

        self.assertLess(validation, commit)
        step = named_step_run(text, "Validate update")
        self.assertIn("python3 -m unittest discover -s tests -v", step)
        self.assertIn('ruby -c "$formula"', step)
        self.assertIn("brew style Formula/*.rb", step)

        for workflow in (UPDATE_WORKFLOW, RECONCILE_WORKFLOW):
            source = workflow.read_text()
            self.assertNotIn("git push", source)
            self.assertNotIn("git pull", source)
            self.assertIn("publish_formulae.py publish", source)
            self.assertIn("group: tap-formula-publication", source)
            self.assertIn("queue: max", source)
            self.assertLess(source.index("Preserve pending publication"), source.index("Publish validated update"))
        gate = (ROOT / ".github/workflows/publication-source-current.yml").read_text()
        self.assertIn("pull_request_target:", gate)
        self.assertIn("ref: ${{ github.workflow_sha }}", gate)
        self.assertIn("branches: [main]", gate)
        self.assertIn("ready_for_review, edited]", gate)
        self.assertNotIn("pull_request.head", gate)
        self.assertIn("statuses: write", gate)

    def test_crabbox_workflow_assets_reach_commit_or_noop_and_fail_closed(self) -> None:
        workflow = UPDATE_WORKFLOW.read_text()
        update = named_step_run(workflow, "Update formula")
        validate = named_step_run(workflow, "Validate update")
        push = named_step_run(workflow, "Publish validated update")
        targets = ("darwin_amd64", "darwin_arm64", "linux_amd64", "linux_arm64")
        original = (ROOT / "Formula" / "crabbox.rb").read_text()
        assets = {
            target: {"name": f"crabbox_1.2.3_{target}.tar.gz", "sha256": hashlib.sha256(target.encode()).hexdigest()}
            for target in targets
        }
        expected = original
        for target, item in assets.items():
            expected = re.sub(
                rf'url "[^"]+_{target}\.tar\.gz"\n(\s+)sha256 "[^"]+"',
                f'url "https://github.com/openclaw/crabbox/releases/download/v1.2.3/{item["name"]}"\n'
                + r'\g<1>' + f'sha256 "{item["sha256"]}"',
                expected,
            )
        for mode in ("update", "noop", "wrong-hash", "missing-asset", "verified-hashes", "validation-failure"):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                scripts = root / ".github" / "scripts"
                scripts.mkdir(parents=True)
                for source in (ROOT / ".github" / "scripts").glob("*.py"):
                    (scripts / source.name).write_bytes(source.read_bytes())
                (root / "Formula").mkdir()
                formula = root / "Formula" / "crabbox.rb"
                before = expected if mode == "noop" else original
                formula.write_text(before)
                (root / "formula-before.rb").write_text(before)
                wrapper = root / "mock-updater.py"
                wrapper.write_text('''import io
import os
import pathlib
import runpy
import sys
import urllib.error
from unittest import mock
sys.argv = sys.argv[1:]
def download(request, **_kwargs):
    url = request.full_url
    targets = ("darwin_amd64", "darwin_arm64", "linux_amd64", "linux_arm64")
    urls = {f"https://github.com/openclaw/crabbox/releases/download/v1.2.3/crabbox_1.2.3_{t}.tar.gz": t for t in targets}
    target = urls[url]
    with pathlib.Path("downloads").open("a") as output:
        output.write(url + "\\n")
    if target == "linux_arm64":
        if os.environ["MODE"] == "missing-asset":
            raise urllib.error.HTTPError(url, 404, "missing asset", {}, None)
        if os.environ["MODE"] == "wrong-hash":
            return io.BytesIO(b"wrong bytes")
    return io.BytesIO(target.encode())
with mock.patch("urllib.request.OpenerDirector.open", side_effect=download), \\
     mock.patch("subprocess.run", side_effect=AssertionError("source tag lookup attempted")):
    runpy.run_path(sys.argv[0], run_name="__main__")
''')
                harness = f'''git() {{
                  printf 'git %s\\n' "$*" >> "$CALLS"
                  if [ "$1" = diff ]; then cmp -s Formula/crabbox.rb formula-before.rb; fi
                }}
                gh() {{ printf 'gh %s\\n' "$*" >> "$CALLS"; }}
                python3() {{
                  if [ "$1" = -m ]; then
                    printf 'tests\\n' >> "$CALLS"
                    [ "$MODE" != validation-failure ]
                  elif [ "$1" = .github/scripts/publish_formulae.py ]; then
                    printf 'publish %s\n' "$*" >> "$CALLS"
                  else
                    "$PYTHON" "$WRAPPER" "$@"
                  fi
                }}
                ruby() {{ printf 'ruby\\n' >> "$CALLS"; }}
                brew() {{ printf 'style\\n' >> "$CALLS"; }}
                {update}
                {validate}
                {push}
                '''
                environment = dict.fromkeys((
                    "ARTIFACT_TEMPLATE", "ARTIFACT_URL", "ASSETS_JSON", "CASK", "CASK_ARTIFACT",
                    "DARWIN_AMD64_SHA256", "DARWIN_ARM64_SHA256", "DESCRIPTION", "LINUX_AMD64_SHA256",
                    "FORMULA_PROFILE", "LINUX_ARM64_SHA256", "LINUX_URL", "MACOS_ARTIFACT", "REQUEST_ID",
                    "SOURCE_TAG_COMMIT", "SOURCE_TAG_OBJECT", "TARGET_ALIASES",
                ), "")
                environment.update({
                    "PATH": os.defpath,
                    "FORMULA": "crabbox",
                    "TAG": "v1.2.3",
                    "REPOSITORY": "openclaw/crabbox",
                    "DEFAULT_BRANCH": "main",
                    "CALLS": str(root / "calls"),
                    "PYTHON": sys.executable,
                    "WRAPPER": str(wrapper),
                    "MODE": mode,
                    "ASSETS_JSON": json.dumps(assets),
                })
                if mode == "verified-hashes":
                    environment.update({target.upper() + "_SHA256": "e" * 64 for target in targets})
                    environment.update({
                        "ASSETS_JSON": "",
                        "ARTIFACT_TEMPLATE": "{formula}_{version}_{target}.tar.gz",
                        "SOURCE_TAG_COMMIT": "a" * 40,
                        "SOURCE_TAG_OBJECT": "b" * 40,
                        "REQUEST_ID": "crabbox-contract-regression",
                    })
                completed = subprocess.run(
                    ["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", harness],
                    cwd=root, env=environment, check=False, capture_output=True, text=True,
                )
                calls = (root / "calls").read_text().splitlines() if (root / "calls").exists() else []
                downloads = (root / "downloads").read_text().splitlines() if (root / "downloads").exists() else []
                if mode == "verified-hashes":
                    self.assertNotEqual(completed.returncode, 0)
                    self.assertIn("Crabbox requires ordinary assets", completed.stderr)
                    self.assertEqual(downloads, [])
                    self.assertEqual(calls, [])
                    self.assertEqual(formula.read_text(), before)
                else:
                    self.assertCountEqual(downloads, [
                        f"https://github.com/openclaw/crabbox/releases/download/v1.2.3/{item['name']}"
                        for item in assets.values()
                    ])
                    if mode in ("wrong-hash", "missing-asset"):
                        self.assertNotEqual(completed.returncode, 0)
                        self.assertIn("SHA-256 mismatch" if mode == "wrong-hash" else "404", completed.stderr)
                        self.assertEqual(calls, [])
                        self.assertEqual(formula.read_text(), before)
                    elif mode == "validation-failure":
                        self.assertNotEqual(completed.returncode, 0)
                        self.assertEqual(calls, ["tests"])
                    else:
                        self.assertEqual(completed.returncode, 0, completed.stderr)
                        self.assertEqual(formula.read_text(), expected)
                        self.assertEqual(calls, [
                            "tests", "ruby", "ruby", "style",
                            "publish .github/scripts/publish_formulae.py publish --mode update",
                        ])


if __name__ == "__main__":
    unittest.main()
