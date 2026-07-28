#!/usr/bin/env python3
"""Scan PR commits and diffs for tokens, credentials, and database details.

Checks added/changed lines and commit messages between base and head for patterns
such as JDBC URLs, passwords, API keys, and access tokens.

Prints a Markdown report to stdout. Exits 1 when findings are detected.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from dataclasses import dataclass
from typing import Iterable, List, Optional, Pattern, Sequence, Tuple

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from changeset_utils import get_git_diff  # noqa: E402

EMPTY_VALUE_RE = re.compile(r"""^[\s"'`]*$""")
PLACEHOLDER_RE = re.compile(
    r"(?i)(?:your[_-]?password|changeme|<password>|xxx+|placeholder|insert[_-]?here|todo|tbd|example)"
)

SECRET_RULES: Sequence[Tuple[str, Pattern[str]]] = (
    (
        "JDBC connection string",
        re.compile(r"jdbc:(?:mysql|postgresql|oracle|sqlserver|mariadb)://[^\s\"']+", re.I),
    ),
    (
        "MySQL connection URI with credentials",
        re.compile(r"mysql://[^\s:/]+:[^\s@\"']+@[^\s\"']+", re.I),
    ),
    (
        "Database password assignment",
        re.compile(
            r"(?:(?:jdbc_)?password|passwd|pwd)\s*(?:=|=>|:)\s*(['\"])(?!\1\s*$)(?!\1\s*,)(.+?)\1",
            re.I,
        ),
    ),
    (
        "Database user assignment",
        re.compile(
            r"jdbc_user\s*(?:=|=>|:)\s*(['\"])(?!\1\s*$)(?!\1\s*,)(.+?)\1",
            re.I,
        ),
    ),
    (
        "API key or token assignment",
        re.compile(
            r"(?:api[_-]?key|access[_-]?token|auth[_-]?token|secret[_-]?token)"
            r"\s*(?:=|=>|:)\s*(['\"])(?!\1\s*$)(?!\1\s*,)(.+?)\1",
            re.I,
        ),
    ),
    (
        "Secret key assignment",
        re.compile(
            r"(?<![\w])secret[_-]?key\s*(?:=|=>|:)\s*(['\"])(?!\1\s*$)(?!\1\s*,)(.+?)\1",
            re.I,
        ),
    ),
    (
        "AWS access key ID",
        re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    ),
    (
        "Bearer token",
        re.compile(r"\bBearer\s+[A-Za-z0-9\-._~+/]{20,}={0,2}\b", re.I),
    ),
    (
        "Private key block",
        re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    ),
    (
        "Database host with inline credentials",
        re.compile(
            r"(?:host|hostname|server)\s*(?:=|=>|:)\s*['\"][^'\"]+['\"].{0,80}"
            r"(?:password|passwd|pwd)\s*(?:=|=>|:)\s*['\"][^'\"]{4,}['\"]",
            re.I | re.S,
        ),
    ),
)


@dataclass
class SecretFinding:
    source: str
    location: str
    rule_name: str
    snippet: str


def run_git(args: Sequence[str]) -> Optional[str]:
    """Run a git command and return stdout, or None on failure."""
    try:
        result = subprocess.run(
            ["git", *args],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    if result.returncode != 0:
        return None
    return result.stdout


def extract_assignment_value(match: re.Match[str]) -> str:
    """Return captured secret value for assignment-style regexes."""
    groups = match.groups()
    if len(groups) >= 2 and isinstance(groups[1], str):
        return groups[1].strip()
    return match.group(0).strip()


def is_benign_value(value: str) -> bool:
    """Skip empty values and obvious placeholders."""
    cleaned = value.strip().strip("'\"")
    if not cleaned or EMPTY_VALUE_RE.match(cleaned):
        return True
    if PLACEHOLDER_RE.search(cleaned):
        return True
    return False


def scan_text(source: str, location: str, text: str) -> List[SecretFinding]:
    """Return secret findings for one text block."""
    findings: List[SecretFinding] = []

    for line_number, raw_line in enumerate(text.splitlines(), start=1):
        line = raw_line.strip()
        if not line or line.startswith("#") or line.startswith("--"):
            continue

        for rule_name, pattern in SECRET_RULES:
            match = pattern.search(line)
            if not match:
                continue

            if len(match.groups()) >= 2:
                value = extract_assignment_value(match)
                if is_benign_value(value):
                    continue

            findings.append(
                SecretFinding(
                    source=source,
                    location=f"{location}:{line_number}",
                    rule_name=rule_name,
                    snippet=redact_sensitive_line(line),
                )
            )
            break

    return findings


def redact_sensitive_line(line: str) -> str:
    """Return a redacted preview safe to show in PR comments."""
    redacted = line
    redacted = re.sub(
        r"((?:jdbc_)?password|passwd|pwd|jdbc_user|api[_-]?key|access[_-]?token|"
        r"auth[_-]?token|secret[_-]?token|secret[_-]?key)\s*(?:=|=>|:)\s*['\"][^'\"]*['\"]",
        r"\1 => '[REDACTED]'",
        redacted,
        flags=re.I,
    )
    redacted = re.sub(
        r"jdbc:(?:mysql|postgresql|oracle|sqlserver|mariadb)://[^\s\"']+",
        "jdbc:[REDACTED]",
        redacted,
        flags=re.I,
    )
    redacted = re.sub(r"mysql://[^\s\"']+", "mysql://[REDACTED]", redacted, flags=re.I)
    redacted = re.sub(r"\bAKIA[0-9A-Z]{16}\b", "AKIA[REDACTED]", redacted)
    redacted = re.sub(
        r"\bBearer\s+[A-Za-z0-9\-._~+/]{20,}={0,2}\b",
        "Bearer [REDACTED]",
        redacted,
        flags=re.I,
    )
    return redacted[:200]


def collect_changed_files(base_sha: str, head_sha: str) -> List[str]:
    """Return files changed between base and head."""
    output = run_git(["diff", "--name-only", "--diff-filter=ACMRT", base_sha, head_sha])
    if output is None:
        return []
    return [line.strip() for line in output.splitlines() if line.strip()]


def scan_file_diff(path: str, base_sha: str, head_sha: str) -> List[SecretFinding]:
    """Scan added lines in one file diff."""
    diff_text = get_git_diff(path, base_sha, head_sha)
    if not diff_text:
        return []

    added_lines: List[str] = []
    for raw_line in diff_text.splitlines():
        if raw_line.startswith("+") and not raw_line.startswith("+++"):
            added_lines.append(raw_line[1:])

    if not added_lines:
        return []

    return scan_text("file diff", path, "\n".join(added_lines))


def scan_commit_messages(base_sha: str, head_sha: str) -> List[SecretFinding]:
    """Scan commit messages introduced by the PR."""
    output = run_git(["log", "--format=%B%x1e---COMMIT---%x1e", f"{base_sha}..{head_sha}"])
    if not output:
        return []

    findings: List[SecretFinding] = []
    commits = [part.strip() for part in output.split("---COMMIT---") if part.strip()]
    for index, message in enumerate(commits, start=1):
        findings.extend(scan_text("commit message", f"commit #{index}", message))
    return findings


def scan_pr(base_sha: str, head_sha: str) -> List[SecretFinding]:
    """Scan all changed files and commit messages in a PR."""
    findings: List[SecretFinding] = []
    findings.extend(scan_commit_messages(base_sha, head_sha))

    for path in collect_changed_files(base_sha, head_sha):
        if not os.path.isfile(path):
            continue
        findings.extend(scan_file_diff(path, base_sha, head_sha))

    return findings


def format_report(findings: Sequence[SecretFinding]) -> str:
    """Return Markdown report text."""
    if not findings:
        return ""

    lines = ["### Security Review", ""]
    for finding in findings:
        lines.append(
            f"- ❌ `{finding.location}` ({finding.source}): "
            f"Possible {finding.rule_name} detected. "
            f"Remove tokens/credentials before committing. "
            f"Preview: `{finding.snippet}`"
        )
    return "\n".join(lines)


def main() -> int:
    base_sha = os.environ.get("GITHUB_BASE_SHA", "").strip()
    head_sha = os.environ.get("GITHUB_HEAD_SHA", "").strip()

    if not base_sha or not head_sha:
        print("Security scan skipped: GITHUB_BASE_SHA and GITHUB_HEAD_SHA are required.")
        return 0

    findings = scan_pr(base_sha, head_sha)
    report = format_report(findings)
    if report:
        print(report)
        return 1

    print("### Security Review\n\n✅ No tokens or database credentials detected in PR commits.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
