#!/usr/bin/env python3
"""Level 4 advisory checks for SQL inside modified SCRIPTS.yaml changeSets.

Checks modified changeSets only (PR diff scoped) for:
  - Inline SQL quality (typos, semicolons, deprecated functions)
  - Disallowed USE database statements
  - Destructive UPDATE/DELETE without WHERE
  - SQL_SAFE_UPDATES left at 0
  - Missing rollback on DDL changeSets
  - Required changeSet metadata (author, labels, comment, changes)

The script always exits 0. Findings are suggestions and never block a PR.
"""

from __future__ import annotations

import os
import re
import sys
from typing import Any, List, Optional, Tuple

import yaml

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from changeset_utils import (  # noqa: E402
    display_value,
    get_modified_changesets,
    is_scripts_yaml,
    labels_include_ddl,
)
from validate_sql import check_sql_content  # noqa: E402

USE_DB_RE = re.compile(r"\bUSE\s+[A-Za-z0-9_]+\s*;", re.IGNORECASE)
UPDATE_DELETE_RE = re.compile(r"\b(UPDATE|DELETE)\b", re.IGNORECASE)
WHERE_RE = re.compile(r"\bWHERE\b", re.IGNORECASE)
SQL_SAFE_UPDATES_OFF_RE = re.compile(r"SQL_SAFE_UPDATES\s*=\s*0", re.IGNORECASE)
SQL_SAFE_UPDATES_ON_RE = re.compile(r"SQL_SAFE_UPDATES\s*=\s*1", re.IGNORECASE)
VALID_LABELS = {"DDL", "DML"}
REQUIRED_FIELDS = ("id", "author", "labels", "comment", "changes")


def normalize_changesets(document: Any) -> List[dict]:
    """Return changeSet dicts from a parsed Liquibase YAML document."""
    if not isinstance(document, dict):
        return []

    entries = document.get("databaseChangeLog", [])
    if not isinstance(entries, list):
        return []

    changesets: List[dict] = []
    for entry in entries:
        if isinstance(entry, dict) and "changeSet" in entry:
            changeset = entry["changeSet"]
            if isinstance(changeset, dict):
                changesets.append(changeset)
    return changesets


def extract_sql_sections(changeset: dict) -> List[Tuple[str, str]]:
    """Return (section, sql_text) pairs from a changeSet."""
    sections: List[Tuple[str, str]] = []

    for section_name in ("changes", "rollback"):
        section_value = changeset.get(section_name)
        if not section_value or section_value == "empty":
            continue
        if not isinstance(section_value, list):
            continue

        for item in section_value:
            if not isinstance(item, dict):
                continue
            sql_value = item.get("sql")
            if isinstance(sql_value, dict):
                sql_text = sql_value.get("sql")
            else:
                sql_text = sql_value
            if isinstance(sql_text, str) and sql_text.strip():
                sections.append((section_name, sql_text))

    return sections


def rollback_is_empty(changeset: dict) -> bool:
    """Return True when rollback is missing or explicitly empty."""
    rollback = changeset.get("rollback")
    if rollback is None:
        return True
    if rollback == "empty":
        return True
    if isinstance(rollback, str) and not rollback.strip():
        return True
    if isinstance(rollback, list) and not rollback:
        return True
    return False


def labels_are_valid(labels_value: Any) -> bool:
    """Return True when labels include at least one approved DML/DDL token."""
    if labels_value is None:
        return False
    labels = display_value(str(labels_value).strip())
    tokens = [token.strip() for token in labels.split(",") if token.strip()]
    if not tokens:
        return False
    return any(token in VALID_LABELS for token in tokens)


def check_destructive_sql(sql_text: str) -> List[str]:
    """Warn when UPDATE/DELETE statements do not include WHERE."""
    warnings: List[str] = []
    statements = [part.strip() for part in sql_text.split(";") if part.strip()]

    for statement in statements:
        if not UPDATE_DELETE_RE.search(statement):
            continue
        if WHERE_RE.search(statement):
            continue
        keyword = UPDATE_DELETE_RE.search(statement).group(1).upper()
        warnings.append(
            f"{keyword} statement without WHERE clause detected — confirm this is intentional."
        )

    return warnings


def check_scripts_sql(
    path: str,
    changeset_id: str,
    section: str,
    sql_text: str,
) -> List[str]:
    """Return advisory findings for one inline SQL block."""
    findings: List[str] = []
    prefix = f"`{path}` (changeSet `{changeset_id}`, {section})"

    errors, warnings = check_sql_content(sql_text)
    for message in errors:
        findings.append(f"{prefix}: {message}")
    for message in warnings:
        findings.append(f"{prefix}: {message}")

    if USE_DB_RE.search(sql_text):
        findings.append(f"{prefix}: Remove `USE <database>` statements from script blocks.")

    for message in check_destructive_sql(sql_text):
        findings.append(f"{prefix}: {message}")

    if SQL_SAFE_UPDATES_OFF_RE.search(sql_text) and not SQL_SAFE_UPDATES_ON_RE.search(sql_text):
        findings.append(
            f"{prefix}: SQL_SAFE_UPDATES is set to 0 but not reset to 1 in the same script block."
        )

    return findings


def check_changeset_structure(path: str, changeset: dict) -> List[str]:
    """Return findings for changeSet metadata and rollback conventions."""
    findings: List[str] = []
    changeset_id = str(changeset.get("id", "<unknown>"))
    prefix = f"`{path}` (changeSet `{changeset_id}`)"

    for field in REQUIRED_FIELDS:
        value = changeset.get(field)
        if value is None or (isinstance(value, str) and not value.strip()):
            findings.append(f"{prefix}: Missing required field `{field}`.")

    labels_value = changeset.get("labels")
    if labels_value is not None and not labels_are_valid(labels_value):
        findings.append(
            f"{prefix}: Labels should use approved values (`DDL`, `DML`, or comma-separated)."
        )

    if not extract_sql_sections(changeset):
        findings.append(f"{prefix}: No inline SQL found under `changes`.")

    if labels_include_ddl(str(labels_value or "")) and rollback_is_empty(changeset):
        findings.append(
            f"{prefix}: DDL changeSet has empty or missing rollback — add rollback SQL when possible."
        )

    return findings


def check_scripts_yaml(
    path: str,
    base_sha: Optional[str],
    head_sha: Optional[str],
) -> List[str]:
    """Return script-level findings for modified SCRIPTS.yaml changeSets."""
    if not is_scripts_yaml(path):
        return []

    norm = path.replace("\\", "/")
    _lines, touched_lines, modified_ids = get_modified_changesets(path, base_sha, head_sha)
    if not modified_ids:
        return []

    with open(path, "r", encoding="utf-8", errors="replace") as file:
        document = yaml.safe_load(file.read())

    modified_id_set = set(modified_ids)
    findings: List[str] = []

    for changeset in normalize_changesets(document):
        changeset_id = str(changeset.get("id", ""))
        if changeset_id not in modified_id_set:
            continue

        findings.extend(check_changeset_structure(norm, changeset))

        for section, sql_text in extract_sql_sections(changeset):
            findings.extend(check_scripts_sql(norm, changeset_id, section, sql_text))

    return findings


def main() -> int:
    yaml_files = [path for path in sys.argv[1:] if path.lower().endswith(".yaml")]
    base_sha = os.environ.get("GITHUB_BASE_SHA", "").strip() or None
    head_sha = os.environ.get("GITHUB_HEAD_SHA", "").strip() or None
    findings: List[str] = []

    for path in yaml_files:
        findings.extend(check_scripts_yaml(path, base_sha, head_sha))

    if findings:
        print("### Scripts Content Review\n")
        for finding in findings:
            print(f"- {finding}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
