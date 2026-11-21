#!/usr/bin/env python3
"""Publish validated tap changes through an immutable, source-current PR."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time
from urllib.parse import quote

import update_formula


CONTEXT = "Publication merge admission"
# Observed on this tap's GitHub Actions check runs, not a caller-selected App.
ACTIONS_APP_ID = 15368
PREFIX = "automation/tap/"
TOKEN = r"[a-z0-9][a-z0-9+@._-]*"
PAYLOAD_PATH = re.compile(rf"(?:Formula|Casks)/{TOKEN}\.rb")
MARKER_PATH = re.compile(rf"\.github/formula-handoffs/{TOKEN}\.json")


def run(*args: str, check: bool = True) -> str:
    result = subprocess.run(args, text=True, capture_output=True)
    if check and result.returncode:
        raise RuntimeError(result.stderr.strip() or f"{args[0]} failed")
    return result.stdout.strip()


class GitHub:
    def __init__(self, repository: str):
        self.repository = repository

    def api(self, endpoint: str, payload: dict | None = None, method: str = "GET"):
        command = ["gh", "api", f"repos/{self.repository}/{endpoint}", "--method", method]
        # A real file also works through gh-compatible proxies which do not forward stdin.
        with tempfile.TemporaryDirectory(prefix="tap-api-") as directory:
            if payload is not None:
                path = Path(directory) / "payload.json"
                path.write_text(json.dumps(payload))
                command += ["--input", str(path)]
            output = run(*command)
        try:
            return json.loads(output) if output else None
        except json.JSONDecodeError as error:
            raise RuntimeError("GitHub returned a malformed response") from error

    def pages(self, endpoint: str) -> list:
        result = []
        for page in range(1, 101):
            separator = "&" if "?" in endpoint else "?"
            items = self.api(f"{endpoint}{separator}per_page=100&page={page}")
            result.extend(items)
            if len(items) < 100:
                return result
        raise RuntimeError("GitHub pagination exceeded the bounded publication inventory")

    def tip(self, branch: str) -> str:
        return self.api(f"git/ref/heads/{quote(branch, safe='')}")["object"]["sha"]

    def ruleset(self, rule: dict) -> dict:
        return self.api(f"rulesets/{rule['ruleset_id']}")


def hold(message: str):
    raise RuntimeError(f"Publication held: {message}; retain the candidate and inspect its PR before retrying")


def pending(github: GitHub) -> None:
    for pr in github.pages("pulls?state=open"):
        head = pr["head"]
        if head["repo"] and head["repo"]["full_name"] == github.repository and head["ref"].startswith(PREFIX):
            hold(f"pending tap payload at {pr['html_url']}")


def require_strict_rule(github: GitHub, branch: str) -> None:
    rules = github.api(f"rules/branches/{quote(branch, safe='')}")
    configs = {}

    def admitted(rule):
        identifier = rule["ruleset_id"]
        if identifier not in configs:
            configs[identifier] = github.ruleset(rule)
        config = configs[identifier]
        # GitHub redacts bypass actors from metadata-only readers. Activation is
        # operator-verified; reject an exposed bypass without requesting admin.
        return (config.get("enforcement") == "active"
                and ("bypass_actors" not in config or config["bypass_actors"] == [])
                and ("current_user_can_bypass" not in config or config["current_user_can_bypass"] == "never"))

    no_rewind = any(rule["type"] == "non_fast_forward"
                    and admitted(rule) for rule in rules)
    if not no_rewind:
        hold("missing bypass-free non-fast-forward protection")
    for rule in rules:
        params = rule.get("parameters", {})
        checks = params.get("required_status_checks", [])
        if (rule["type"] == "required_status_checks"
                and params.get("strict_required_status_checks_policy") is True
                and {"context": CONTEXT, "integration_id": ACTIONS_APP_ID} in checks):
            # Effective rules alone do not expose bypasses. Inspect the actual owner rule.
            if admitted(rule):
                return
    hold(f"missing active strict {CONTEXT!r} rule from GitHub Actions with no bypass actors")


def check_candidate(github: GitHub, pr: dict, default: str) -> tuple[str, str]:
    head = pr["head"]
    if head["repo"] is None or head["repo"]["full_name"] != github.repository or pr["base"]["ref"] != default:
        hold("reserved publisher branch must belong to this tap and target its default branch")
    match = re.fullmatch(r"automation/tap/(update|verified|reconcile)/([0-9a-f]{40})/([0-9a-f]{40})", head["ref"])
    if not match:
        hold("malformed reserved publisher branch")
    mode, base, tree = match.groups()
    commit = github.api(f"git/commits/{head['sha']}")
    if [item["sha"] for item in commit["parents"]] != [base] or commit["tree"]["sha"] != tree:
        hold("candidate topology does not match its immutable branch")
    if github.tip(default) != base:
        hold("default branch advanced; regenerate and validate from its current head")
    files = github.pages(f"pulls/{pr['number']}/files")
    if not files or len(files) != pr["changed_files"]:
        hold("incomplete or empty candidate file inventory")
    for item in files:
        path = item["filename"]
        if item["status"] == "renamed" or not (PAYLOAD_PATH.fullmatch(path) or (mode == "verified" and MARKER_PATH.fullmatch(path))):
            hold("candidate changes paths outside the publisher-owned payload")
    return head["sha"], base


def status(github: GitHub, head: str, state: str, description: str) -> None:
    github.api(f"statuses/{head}", {"state": state, "context": CONTEXT,
               "description": description[:140]}, "POST")


def gate(github: GitHub, event: dict) -> None:
    default = event["repository"]["default_branch"]
    expected = event["pull_request"]

    def current_pr():
        pr = github.api(f"pulls/{expected['number']}")
        if (default != "main" or pr["state"] != "open" or pr["base"]["ref"] != default
                or pr["base"]["repo"]["full_name"] != github.repository
                or pr["head"]["sha"] != expected["head"]["sha"]):
            return None
        return pr

    if current_pr() is None:
        print("Obsolete pull request event; no status written")
        return
    # This is a commit-wide admission status. Only the publisher owns payload
    # and provenance validation; another PR at this SHA cannot negate it.
    status(github, expected["head"]["sha"], "success", "Pull request metadata admitted")


def verify_tag() -> None:
    if not os.environ.get("SOURCE_TAG_OBJECT"):
        return
    # The tag probe already isolates all credentials and Git configuration itself.
    update_formula.verify_remote_source_tag(os.environ["REPOSITORY"], os.environ["TAG"],
                                            os.environ["SOURCE_TAG_OBJECT"], os.environ["SOURCE_TAG_COMMIT"])


def publish(github: GitHub, default: str, base: str, mode: str) -> None:
    if run("git", "rev-parse", "HEAD") != base or github.tip(default) != base:
        hold("validated source base is no longer current")
    pending(github)
    paths = [str(path) for path in Path("Formula").glob("*.rb")] if mode == "reconcile" else [f"Formula/{update_formula.validate_tap_token(os.environ['FORMULA'], 'formula')}.rb"]
    subject = "chore: reconcile Homebrew formulae"
    body = ""
    if mode != "reconcile":
        cask = os.environ.get("CASK", "")
        if cask:
            paths.append(f"Casks/{update_formula.validate_tap_token(cask, 'cask')}.rb")
        subject = f"{os.environ['FORMULA']}: update formula{' and cask' if cask else ''} for {os.environ['TAG']}"
    if mode == "verified":
        verify_tag()
        formula = os.environ["FORMULA"]
        marker = Path(f".github/formula-handoffs/{formula}.json")
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(json.dumps({"request_id": os.environ["REQUEST_ID"],
            "repository": os.environ["REPOSITORY"], "tag": os.environ["TAG"],
            "source_tag_object": os.environ["SOURCE_TAG_OBJECT"], "source_tag_commit": os.environ["SOURCE_TAG_COMMIT"],
            "base": base, "run_id": os.environ["GITHUB_RUN_ID"], "run_attempt": os.environ["GITHUB_RUN_ATTEMPT"],
            "formula_blob": run("git", "hash-object", paths[0])}, indent=2, sort_keys=True) + "\n")
        paths.append(str(marker))
        body = "\n".join(f"{key}: {os.environ[value]}" for key, value in (
            ("Source-Repository", "REPOSITORY"), ("Source-Tag-Object", "SOURCE_TAG_OBJECT"),
            ("Source-Tag-Commit", "SOURCE_TAG_COMMIT"), ("Request-ID", "REQUEST_ID")))
    if run("git", "diff", "--cached", "--name-only"):
        hold("publisher requires an unstaged validated payload")
    run("git", "add", "--", *paths)
    changed = run("git", "diff", "--cached", "--name-only").splitlines()
    if not changed:
        print("Formulae already up to date; no publication needed")
        return
    if not set(changed).issubset(paths):
        hold("unexpected staged payload paths")
    tree = run("git", "write-tree")
    run("git", "commit", "-m", subject, "-m", body)
    head = run("git", "rev-parse", "HEAD")
    branch = f"{PREFIX}{mode}/{base}/{tree}"
    refs = github.api(f"git/matching-refs/heads/{quote(branch, safe='')}")
    if refs:
        if len(refs) != 1 or refs[0]["ref"] != f"refs/heads/{branch}":
            hold("ambiguous retained branch")
        head = refs[0]["object"]["sha"]
        commit = github.api(f"git/commits/{head}")
        if commit["tree"]["sha"] != tree or [p["sha"] for p in commit["parents"]] != [base] or commit["message"].strip() != (subject + ("\n\n" + body if body else "")):
            hold("retained branch differs from the validated payload")
        prior = github.pages(f"pulls?state=all&head={quote(github.repository.split('/')[0] + ':' + branch, safe='')}")
        if prior:
            hold(f"retained candidate already has a PR at {prior[0]['html_url']}")
    else:
        run("gh", "auth", "setup-git")
        run("git", "push", "origin", f"{head}:refs/heads/{branch}")
    print(f"Candidate branch retained: {branch}", flush=True)
    try:
        pr = github.api("pulls", {"head": branch, "base": default, "title": subject, "body": body or "Validated tap formula update."}, "POST")
    except RuntimeError as error:
        hold(f"PR creation response failed for {branch}: {error}")
    print(f"Candidate retained at {pr['html_url']}", flush=True)
    pr = github.api(f"pulls/{pr['number']}")
    observed, _ = check_candidate(github, pr, default)
    if observed != head or github.api(f"git/commits/{head}")["tree"]["sha"] != tree:
        hold("PR differs from validated candidate")
    require_strict_rule(github, default)
    verify_tag()
    status(github, head, "success", "Validated publisher candidate admitted")
    for _ in range(30):
        pr = github.api(f"pulls/{pr['number']}")
        if pr["head"]["sha"] != head or pr["mergeable"] is False:
            hold("candidate head changed or is not mergeable")
        if pr["mergeable"] is True:
            break
        time.sleep(2)
    else:
        hold("GitHub did not resolve candidate mergeability")
    require_strict_rule(github, default)
    check_candidate(github, pr, default)
    verify_tag()
    error = None
    try:
        github.api(f"pulls/{pr['number']}/merge", {"sha": head, "merge_method": "squash", "commit_title": subject, "commit_message": body}, "PUT")
    except RuntimeError as failure:
        error = failure
    # One merge mutation only. Read the authoritative result even after a lost response.
    pr = github.api(f"pulls/{pr['number']}")
    if not pr["merged"] or pr["head"]["sha"] != head:
        hold(f"normal merge did not complete ({error or 'rules or checks pending'}) at {pr['html_url']}")
    merged = pr["merge_commit_sha"]
    commit = github.api(f"git/commits/{merged}")
    if [p["sha"] for p in commit["parents"]] != [base] or commit["tree"]["sha"] != tree or github.tip(default) != merged:
        hold("post-merge parent/tree/current-tip receipt mismatch; a commit may already be published")
    if body and commit["message"].strip() != subject + "\n\n" + body:
        hold("post-merge provenance message mismatch")
    verify_tag()
    print(f"Published {pr['html_url']} at {merged}; exact parent and payload verified")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("pending", "publish", "gate"))
    parser.add_argument("--mode", choices=("update", "verified", "reconcile"), default="update")
    args = parser.parse_args()
    github = GitHub(os.environ["GITHUB_REPOSITORY"])
    if args.action == "pending":
        pending(github)
    elif args.action == "gate":
        gate(github, json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text()))
    else:
        publish(github, os.environ["DEFAULT_BRANCH"], os.environ["GITHUB_SHA"], args.mode)


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
