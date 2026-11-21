from __future__ import annotations

import contextlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from urllib.parse import unquote

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / ".github/scripts"))
import publish_formulae as publisher


def git(*args):
    return subprocess.check_output(["git", *args], text=True, stderr=subprocess.DEVNULL).strip()


class Server:
    repository = "example/tap"

    def __init__(self, remote):
        self.remote = str(remote)
        self.pr = None
        self.strict = True
        self.no_rewind = True
        self.bypass = []
        self.redacted = False
        self.can_bypass = "never"
        self.merge_calls = 0
        self.statuses = []
        self.race = False
        self.lost_response = False
        self.null_reads = 0

    def tip(self, branch):
        return git("--git-dir", self.remote, "rev-parse", f"refs/heads/{branch}")

    def commit(self, sha):
        return {"tree": {"sha": git("rev-parse", sha + "^{tree}")},
                "parents": [{"sha": p} for p in git("show", "-s", "--format=%P", sha).split()],
                "message": git("show", "-s", "--format=%B", sha)}

    def ruleset(self, _rule):
        return ({"enforcement": "active"} if self.redacted else {"enforcement": "active", "bypass_actors": self.bypass, "current_user_can_bypass": self.can_bypass})

    def pages(self, path):
        if path.startswith("pulls?"):
            return [self.pr] if self.pr and not self.pr["merged"] else []
        if path == "pulls/1/files":
            return [{"filename": p, "status": "modified"} for p in
                    git("diff", "--name-only", self.pr["base"]["sha"], self.pr["head"]["sha"]).splitlines()]
        raise AssertionError(path)

    def api(self, path, payload=None, method="GET"):
        if path.startswith("git/matching-refs/heads/"):
            branch = unquote(path.split("heads/", 1)[1])
            result = subprocess.run(["git", "--git-dir", self.remote, "show-ref", "--verify", f"refs/heads/{branch}"], capture_output=True, text=True)
            return [] if result.returncode else [{"ref": f"refs/heads/{branch}", "object": {"sha": result.stdout.split()[0]}}]
        if path.startswith("git/commits/"):
            return self.commit(path.split("/")[-1])
        if path.startswith("rules/branches/"):
            return ([{"type": "non_fast_forward", "ruleset_id": 123}] if self.no_rewind else []) + [{"type": "required_status_checks", "ruleset_id": 123,
                     "ruleset_source_type": "Repository", "parameters": {
                         "strict_required_status_checks_policy": self.strict,
                         "required_status_checks": [{"context": publisher.CONTEXT,
                                                    "integration_id": publisher.ACTIONS_APP_ID}]}}]
        if path == "pulls" and method == "POST":
            head = self.tip(payload["head"])
            base = self.tip(payload["base"])
            self.pr = {"number": 1, "html_url": "https://github.com/example/tap/pull/1",
                       "head": {"ref": payload["head"], "sha": head, "repo": {"full_name": self.repository}},
                       "base": {"ref": payload["base"], "sha": base, "repo": {"full_name": self.repository}},
                       "state": "open",
                       "changed_files": len(git("diff", "--name-only", base, head).splitlines()),
                       "merged": False, "mergeable": True}
            return self.pr
        if path.startswith("statuses/"):
            self.statuses.append(payload)
            return {}
        if path == "pulls/1/merge":
            self.merge_calls += 1
            self.assert_head = payload["sha"]
            if self.race:
                raise RuntimeError("strict server rejected stale source")
            commit = self.commit(payload["sha"])
            command = ["git", "commit-tree", commit["tree"]["sha"], "-p", self.tip("main"), "-m", payload["commit_title"]]
            if payload["commit_message"]:
                command += ["-m", payload["commit_message"]]
            merged = subprocess.check_output(command, text=True).strip()
            git("push", "origin", f"{merged}:refs/heads/main")
            self.pr.update(merged=True, merge_commit_sha=merged)
            if self.lost_response:
                raise RuntimeError("connection lost after successful merge")
            return {"merged": True, "sha": merged}
        if path == "pulls/1":
            if self.null_reads:
                self.null_reads -= 1
                return {**self.pr, "mergeable": None}
            return self.pr
        raise AssertionError((path, method, payload))


class PublicationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tap-publish-test-")
        self.root = Path(self.temp.name)
        self.cwd = Path.cwd()
        os.chdir(self.root)
        self.env = patch.dict(os.environ, {"GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_AUTHOR_NAME": "Fixture", "GIT_AUTHOR_EMAIL": "fixture@example.com",
            "GIT_COMMITTER_NAME": "Fixture", "GIT_COMMITTER_EMAIL": "fixture@example.com",
            "FORMULA": "example", "TAG": "v1.2.3", "REPOSITORY": "example/tool", "CASK": "",
            "SOURCE_TAG_OBJECT": "", "SOURCE_TAG_COMMIT": "", "REQUEST_ID": "fixture-request",
            "GITHUB_RUN_ID": "123", "GITHUB_RUN_ATTEMPT": "1"})
        self.env.start()
        git("init", "-q", "-b", "main")
        Path("Formula").mkdir()
        Path("Formula/example.rb").write_text("original\n")
        git("add", "Formula")
        git("commit", "-qm", "base")
        self.base = git("rev-parse", "HEAD")
        self.remote = self.root / "remote.git"
        git("init", "--bare", "-q", str(self.remote))
        git("remote", "add", "origin", str(self.remote))
        git("push", "-q", "origin", "main")
        self.server = Server(self.remote)
        original_run = publisher.run

        def command(*args, **kwargs):
            if args[:3] == ("gh", "auth", "setup-git"):
                return ""
            return original_run(*args, **kwargs)
        self.command = patch.object(publisher, "run", side_effect=command)
        self.command.start()
        self.output = contextlib.redirect_stdout(io.StringIO())
        self.output.start = self.output.__enter__
        self.output.start()

    def tearDown(self):
        self.output.__exit__(None, None, None)
        self.command.stop()
        self.env.stop()
        os.chdir(self.cwd)
        self.temp.cleanup()

    def publish(self, mode="update"):
        publisher.publish(self.server, "main", self.base, mode)

    def test_normal_exact_head_squash_and_payload_receipt(self):
        Path("Formula/example.rb").write_text("updated\n")
        self.publish()
        self.assertEqual(self.server.merge_calls, 1)
        self.assertEqual(self.server.assert_head, git("rev-parse", "HEAD"))
        self.assertEqual(self.server.commit(self.server.tip("main"))["tree"], self.server.commit(git("rev-parse", "HEAD"))["tree"])

    def test_ordinary_noop_creates_no_branch_or_pr(self):
        self.publish()
        self.assertIsNone(self.server.pr)
        self.assertEqual(self.server.tip("main"), self.base)

    def test_verified_noop_has_bounded_marker_and_provenance(self):
        with patch.dict(os.environ, {"SOURCE_TAG_OBJECT": "b" * 40, "SOURCE_TAG_COMMIT": "a" * 40}), patch.object(publisher, "verify_tag") as tag:
            self.publish("verified")
        marker = json.loads(Path(".github/formula-handoffs/example.json").read_text())
        self.assertEqual(marker["base"], self.base)
        self.assertEqual(marker["formula_blob"], git("hash-object", "Formula/example.rb"))
        merged = self.server.commit(self.server.tip("main"))
        self.assertIn("Request-ID: fixture-request", merged["message"])
        self.assertEqual([x["sha"] for x in merged["parents"]], [self.base])
        self.assertEqual(tag.call_count, 4)

    def test_missing_strict_rule_retains_pr_without_merge(self):
        self.server.strict = False
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "missing active strict"):
            self.publish()
        self.assertIsNotNone(self.server.pr)
        self.assertEqual(self.server.merge_calls, 0)
        self.assertEqual(self.server.tip("main"), self.base)

    def test_bypass_rule_is_not_accepted(self):
        self.server.bypass = [{"actor_id": 1, "bypass_mode": "always"}]
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "Publication held"):
            self.publish()
        self.assertEqual(self.server.merge_calls, 0)

    def test_strict_server_refusal_never_retries_merge(self):
        self.server.race = True
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "normal merge did not complete"):
            self.publish()
        self.assertEqual(self.server.merge_calls, 1)
        self.assertEqual(self.server.tip("main"), self.base)

    def test_lost_success_response_reconciles_authoritative_merge(self):
        self.server.lost_response = True
        Path("Formula/example.rb").write_text("updated\n")
        self.publish()
        self.assertTrue(self.server.pr["merged"])
        self.assertEqual(self.server.merge_calls, 1)

    def test_null_mergeability_is_bounded_observation(self):
        self.server.null_reads = 3
        Path("Formula/example.rb").write_text("updated\n")
        with patch.object(publisher.time, "sleep"):
            self.publish()
        self.assertEqual(self.server.merge_calls, 1)

    def test_stale_local_source_stops_before_branch(self):
        with self.assertRaisesRegex(RuntimeError, "source base is no longer current"):
            publisher.publish(self.server, "main", "a" * 40, "update")
        self.assertIsNone(self.server.pr)

    def test_pending_payload_stops_before_staging(self):
        self.server.pr = {"head": {"ref": publisher.PREFIX + "update/existing", "repo": {"full_name": self.server.repository}}, "html_url": "https://github.com/example/tap/pull/1", "merged": False}
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "pending tap payload"):
            self.publish()
        self.assertEqual(git("diff", "--cached", "--name-only"), "")

    def test_fork_cannot_reserve_publisher_namespace(self):
        self.server.pr = {"head": {"ref": publisher.PREFIX + "update/existing", "repo": {"full_name": "someone/tap"}}, "html_url": "https://github.com/example/tap/pull/1", "merged": False}
        publisher.pending(self.server)

    def test_existing_identical_tree_branch_is_reused_without_force(self):
        Path("Formula/example.rb").write_text("updated\n")
        self.server.strict = False
        with self.assertRaises(RuntimeError):
            self.publish()
        expected = self.server.pr["head"]["sha"]
        self.server.pr = None
        self.server.strict = True
        git("reset", "--mixed", self.base)
        with patch.dict(os.environ, {"GIT_AUTHOR_DATE": "2001-01-01T00:00:00Z", "GIT_COMMITTER_DATE": "2001-01-01T00:00:00Z"}):
            self.publish()
        self.assertEqual(self.server.assert_head, expected)
        self.assertNotEqual(git("rev-parse", "HEAD"), expected)

    def test_ordinary_gate_posts_neutral_admission(self):
        self.server.pr = {"number": 1, "state": "open", "head": {"ref": "fix/example", "sha": self.base}, "base": {"ref": "main", "repo": {"full_name": self.server.repository}}}
        publisher.gate(self.server, {"repository": {"default_branch": "main"}, "pull_request": {"number": 1, "head": {"sha": self.base}}})
        self.assertEqual(self.server.statuses[-1]["state"], "success")

    def test_reserved_fork_gate_posts_only_neutral_admission(self):
        self.server.pr = {"number": 1, "state": "open", "head": {"ref": publisher.PREFIX + "update/test", "sha": self.base, "repo": {"full_name": "other/tap"}}, "base": {"ref": "main", "repo": {"full_name": self.server.repository}}}
        publisher.gate(self.server, {"repository": {"default_branch": "main"}, "pull_request": {"number": 1, "head": {"sha": self.base}}})
        self.assertEqual(self.server.statuses[-1]["state"], "success")
        self.assertEqual(self.server.statuses[-1]["description"], "Pull request metadata admitted")

    def test_no_rewind_protection_is_required(self):
        self.server.no_rewind = False
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "non-fast-forward"):
            self.publish()
        self.assertEqual(self.server.merge_calls, 0)

    def test_malformed_response_is_reconcilable_runtime_error(self):
        github = publisher.GitHub(self.server.repository)
        with patch.object(publisher, "run", return_value="not JSON"):
            with self.assertRaisesRegex(RuntimeError, "malformed response"):
                github.api("pulls/1/merge", {"sha": self.base}, "PUT")

    def test_changed_event_head_never_receives_success(self):
        self.server.pr = {"number": 1, "state": "open", "head": {"ref": "fix/example", "sha": "a" * 40}, "base": {"ref": "main", "repo": {"full_name": self.server.repository}}}
        publisher.gate(self.server, {"repository": {"default_branch": "main"}, "pull_request": {"number": 1, "head": {"sha": self.base}}})
        self.assertEqual(self.server.statuses, [])

    def test_closed_event_writes_no_status(self):
        self.server.pr = {"number": 1, "state": "closed", "head": {"ref": "fix/example", "sha": self.base}, "base": {"ref": "main", "repo": {"full_name": self.server.repository}}}
        publisher.gate(self.server, {"repository": {"default_branch": "main"}, "pull_request": {"number": 1, "head": {"sha": self.base}}})
        self.assertEqual(self.server.statuses, [])

    def test_retargeted_event_writes_no_status(self):
        self.server.pr = {"number": 1, "state": "open", "head": {"ref": "fix/example", "sha": self.base}, "base": {"ref": "other", "repo": {"full_name": self.server.repository}}}
        publisher.gate(self.server, {"repository": {"default_branch": "main"}, "pull_request": {"number": 1, "head": {"sha": self.base}}})
        self.assertEqual(self.server.statuses, [])

    def test_redacted_bypass_metadata_does_not_require_admin(self):
        self.server.redacted = True
        Path("Formula/example.rb").write_text("updated\n")
        self.publish()
        self.assertEqual(self.server.merge_calls, 1)

    def test_exposed_current_actor_bypass_is_rejected(self):
        self.server.can_bypass = "always"
        Path("Formula/example.rb").write_text("updated\n")
        with self.assertRaisesRegex(RuntimeError, "Publication held"):
            self.publish()
        self.assertEqual(self.server.merge_calls, 0)


if __name__ == "__main__":
    unittest.main()
