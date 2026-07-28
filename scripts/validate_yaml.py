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


def get_git_diff(path: str, base_ref: str) -> Optional[str]:
    """Return git diff text for a file against base_ref, or None when unavailable."""
    if not base_ref:
        return None
    try:
        result = subprocess.run(
            ["git", "diff", base_ref, "HEAD", "--", path],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return result.stdout


def collect_ddl_changesets_from_diff(diff_text: str) -> List[str]:
    """Return changeSet IDs whose labels were added/changed to DDL in the diff."""
    ddl_changeset_ids: List[str] = []
    seen: Set[str] = set()
    current_id: Optional[str] = None

    for raw_line in diff_text.splitlines():
        if raw_line.startswith("@@"):
            current_id = None
            continue

        if not raw_line or raw_line.startswith("+++") or raw_line.startswith("---"):
            continue

        prefix = raw_line[0]
        content = raw_line[1:]

        if prefix in " -":
            id_match = ID_RE.match(content)
            if id_match:
                current_id = display_value(id_match.group(2)) or None

        if prefix != "+":
            continue

        id_match = ID_RE.match(content)
        if id_match:
            current_id = display_value(id_match.group(2)) or None
            continue

        labels_match = LABELS_RE.match(content)
        if labels_match and current_id and labels_include_ddl(labels_match.group(2)):
            if current_id not in seen:
                seen.add(current_id)
                ddl_changeset_ids.append(current_id)

    return ddl_changeset_ids


def collect_ddl_changesets_from_file(lines: list) -> List[str]:
    """Return all changeSet IDs in a SCRIPTS.yaml file that use the DDL label."""
    ddl_changeset_ids: List[str] = []

    for index, line in enumerate(lines):
        if not CHANGESET_RE.match(line.rstrip("\r\n")):
            continue

        changeset_indent = len(CHANGESET_RE.match(line.rstrip("\r\n")).group(1).expandtabs(8))
        changeset_id: Optional[str] = None

        for child_index in range(index + 1, len(lines)):
            child = lines[child_index].rstrip("\r\n")
            if not child.strip() or child.lstrip().startswith("#"):
                continue

            child_indent = len(child) - len(child.lstrip())
            if child_indent <= changeset_indent:
                break

            id_match = ID_RE.match(child)
            if id_match:
                changeset_id = display_value(id_match.group(2)) or None
                continue

            labels_match = LABELS_RE.match(child)
            if labels_match and changeset_id and labels_include_ddl(labels_match.group(2)):
                ddl_changeset_ids.append(changeset_id)
                break

    return ddl_changeset_ids


def check_scripts_yaml_ddl(path: str, base_ref: Optional[str]) -> List[str]:
    """Return DDL change-request reminders for changed SCRIPTS.yaml files."""
    if not is_scripts_yaml(path):
        return []

    norm = path.replace("\\", "/")
    diff_text = get_git_diff(path, base_ref) if base_ref else None
    if diff_text is not None:
        ddl_changeset_ids = collect_ddl_changesets_from_diff(diff_text)
    else:
        with open(path, "r", encoding="utf-8", errors="replace") as file:
            ddl_changeset_ids = collect_ddl_changesets_from_file(file.read().splitlines(keepends=True))

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
    base_ref = os.environ.get("GITHUB_BASE_REF", "").strip() or None
    yaml_findings: List[str] = []
    ddl_findings: List[str] = []

    for path in yaml_files:
        yaml_findings.extend(check_file(path))
        ddl_findings.extend(check_scripts_yaml_ddl(path, base_ref))

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
