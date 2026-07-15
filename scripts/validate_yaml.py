#!/usr/bin/env python3
"""Level 3 advisory checks for changed Liquibase YAML files.

Checks:
  - YAML syntax/indentation errors.
  - Duplicate changeSet IDs within the same file.

The script always exits 0. Findings are suggestions and never block a PR.
PyYAML is installed by the GitHub Actions workflow.
"""

import os
import re
import sys
from collections import defaultdict

import yaml


CHANGESET_RE = re.compile(r"^(\s*)-\s*changeSet\s*:\s*(?:#.*)?$")
ID_RE = re.compile(r"^(\s*)id\s*:\s*(.*?)\s*(?:#.*)?$")


def display_value(value: str) -> str:
    """Remove optional YAML quotes from a scalar used as a changeSet ID."""
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


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
    findings = []
    for path in yaml_files:
        findings.extend(check_file(path))

    if findings:
        print("### YAML Content Quality\n")
        for finding in findings:
            print(f"- {finding}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
