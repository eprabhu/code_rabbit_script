#!/usr/bin/env python3
"""Level 3 advisory checks for changed Liquibase YAML files.

Checks:
  - YAML syntax/indentation errors.
  - Duplicate changeSet IDs within the same file.
  - DDL changeSets added in SCRIPTS.yaml (change-request document reminder).

The script always exits 0. Findings are suggestions and never block a PR.
PyYAML is installed by the GitHub Actions workflow.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from collections import defaultdict
from typing import List, Optional, Set

import yaml


CHANGESET_RE = re.compile(r"^(\s*)-\s*changeSet\s*:\s*(?:#.*)?$")
ID_RE = re.compile(r"^(\s*)id\s*:\s*(.*?)\s*(?:#.*)?$")
LABELS_RE = re.compile(r"^(\s*)labels\s*:\s*(.*?)\s*(?:#.*)?$")
SCRIPTS_YAML_NAME = "scripts.yaml"


def display_value(value: str) -> str:
    """Remove optional YAML quotes from a scalar used as a changeSet ID."""
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def is_scripts_yaml(path: str) -> bool:
    """Return True when the file is a module SCRIPTS.yaml changelog."""
    return os.path.basename(path.replace("\\", "/")).lower() == SCRIPTS_YAML_NAME


def labels_include_ddl(labels_value: str) -> bool:
    """Return True when labels include the DDL token."""
    labels = display_value(labels_value.strip())
    tokens = [token.strip() for token in labels.split(",") if token.strip()]
    return "DDL" in tokens


def get_git_diff(path: str, base_sha: str, head_sha: str) -> Optional[str]:
    """Return git diff text for a file between base and head commits."""
    if not base_sha or not head_sha:
        return None
    try:
        result = subprocess.run(
            ["git", "diff", base_sha, head_sha, "--", path],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return result.stdout


HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def collect_touched_new_lines(diff_text: str) -> Set[int]:
    """Return 1-based line numbers in the new file that were added or changed."""
    touched_lines: Set[int] = set()
    new_line = 0

    for raw_line in diff_text.splitlines():
        hunk_match = HUNK_RE.match(raw_line)
        if hunk_match:
            new_line = int(hunk_match.group(1)) - 1
            continue

        if (
            not raw_line
            or raw_line.startswith("+++")
            or raw_line.startswith("---")
            or raw_line.startswith("@@")
        ):
            continue

        prefix = raw_line[0]
        if prefix == " ":
            new_line += 1
        elif prefix == "+":
            new_line += 1
            touched_lines.add(new_line)

    return touched_lines


def collect_changeset_blocks(lines: list) -> List[dict]:
    """Return metadata for each changeSet block in a YAML file."""
    blocks: List[dict] = []
    total_lines = len(lines)
    index = 0

    while index < total_lines:
        match = CHANGESET_RE.match(lines[index].rstrip("\r\n"))
        if not match:
            index += 1
            continue

        start_line = index + 1
        changeset_indent = len(match.group(1).expandtabs(8))
        changeset_id: Optional[str] = None
        labels_value = ""
        index += 1

        while index < total_lines:
            child = lines[index].rstrip("\r\n")
            if not child.strip() or child.lstrip().startswith("#"):
                index += 1
                continue

            child_indent = len(child) - len(child.lstrip())
            if child_indent <= changeset_indent:
                break

            id_match = ID_RE.match(child)
            if id_match:
                changeset_id = display_value(id_match.group(2)) or None

            labels_match = LABELS_RE.match(child)
            if labels_match:
                labels_value = labels_match.group(2)

            index += 1

        if changeset_id:
            blocks.append(
                {
                    "id": changeset_id,
                    "labels": labels_value,
                    "start": start_line,
                    "end": index,
                }
            )

    return blocks


def collect_modified_ddl_changesets(
    lines: list,
    touched_lines: Set[int],
) -> List[str]:
    """Return DDL-labelled changeSet IDs that were modified in the PR diff."""
    modified_ids: List[str] = []

    for block in collect_changeset_blocks(lines):
        block_lines = range(block["start"], block["end"] + 1)
        if not any(line_number in touched_lines for line_number in block_lines):
            continue
        if labels_include_ddl(block["labels"]):
            modified_ids.append(block["id"])

    return modified_ids


def check_scripts_yaml_ddl(
    path: str,
    base_sha: Optional[str],
    head_sha: Optional[str],
) -> List[str]:
    """Return DDL change-request reminders for modified SCRIPTS.yaml changeSets."""
    if not is_scripts_yaml(path):
        return []

    norm = path.replace("\\", "/")
    with open(path, "r", encoding="utf-8", errors="replace") as file:
        lines = file.read().splitlines(keepends=True)

    diff_text = get_git_diff(path, base_sha or "", head_sha or "")
    if diff_text is None:
        return []

    touched_lines = collect_touched_new_lines(diff_text)
    if not touched_lines:
        return []

    ddl_changeset_ids = collect_modified_ddl_changesets(lines, touched_lines)

    findings = []
    for changeset_id in ddl_changeset_ids:
        findings.append(
            f"`{norm}` (changeSet `{changeset_id}`): "
            "Is Change Request Document available for this DDL change?"
        )
    return findings


def collect_changeset_ids(lines: list[str]) -> dict[str, list[int]]:
    """Collect changeSet IDs and their 1-based line numbers."""
    occurrences: dict[str, list[int]] = defaultdict(list)

    for index, line in enumerate(lines):
        match = CHANGESET_RE.match(line.rstrip("\r\n"))
        if not match:
            continue

        changeset_indent = len(match.group(1).expandtabs(8))
        for child_index in range(index + 1, len(lines)):
            child = lines[child_index].rstrip("\r\n")
            if not child.strip() or child.lstrip().startswith("#"):
                continue

            child_indent = len(child) - len(child.lstrip())
            if child_indent <= changeset_indent:
                break

            id_match = ID_RE.match(child)
            if id_match:
                changeset_id = display_value(id_match.group(2))
                if changeset_id:
                    occurrences[changeset_id].append(child_index + 1)
                break

    return occurrences


def check_file(path: str) -> list[str]:
    """Return advisory findings for one YAML file."""
    if not os.path.isfile(path):
        return []

    norm = path.replace("\\", "/")
    with open(path, "r", encoding="utf-8", errors="replace") as file:
        content = file.read()
    lines = content.splitlines(keepends=True)
    findings = []

    try:
        yaml.safe_load(content)
    except yaml.MarkedYAMLError as error:
        mark = error.problem_mark
        location = (
            f"line {mark.line + 1}, column {mark.column + 1}"
            if mark
            else "an unknown location"
        )
        problem = error.problem or "invalid YAML syntax or indentation"
        findings.append(f"`{norm}`: YAML error at {location}: {problem}.")
    except yaml.YAMLError as error:
        findings.append(f"`{norm}`: YAML error: {error}.")

    for changeset_id, line_numbers in collect_changeset_ids(lines).items():
        if len(line_numbers) > 1:
            lines_text = ", ".join(str(number) for number in line_numbers)
            findings.append(
                f"`{norm}`: duplicate changeSet ID `{changeset_id}` "
                f"appears on lines {lines_text}. Every ID in a file must be unique."
            )

    return findings


def main() -> int:
    yaml_files = [
        path for path in sys.argv[1:] if path.lower().endswith(".yaml")
    ]
    base_sha = os.environ.get("GITHUB_BASE_SHA", "").strip() or None
    head_sha = os.environ.get("GITHUB_HEAD_SHA", "").strip() or None
    yaml_findings: List[str] = []
    ddl_findings: List[str] = []

    for path in yaml_files:
        yaml_findings.extend(check_file(path))
        ddl_findings.extend(check_scripts_yaml_ddl(path, base_sha, head_sha))

    if ddl_findings:
        print("### DDL Change Review\n")
        for finding in ddl_findings:
            print(f"- {finding}")

    if yaml_findings:
        print("### YAML Content Quality\n")
        for finding in yaml_findings:
            print(f"- {finding}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
