#!/usr/bin/env python3
"""
validate_sql.py

Simple, dependency-free SQL sanity checker for CI.
It is intentionally heuristic (not a real SQL parser) so it works on any
.sql file without needing a database connection. It looks for:

  - Missing semicolons (rough statement-vs-terminator count)
  - Unmatched single quotes
  - Common misspelled keywords (FORM, SELET, INSTERT, etc.)
  - Deprecated / risky functions (customize DEPRECATED_FUNCTIONS below)
  - Breaking-change statements (DROP, ALTER) -> warnings, not failures

Exit code:
  0 = no ERRORS (warnings are still allowed)
  1 = at least one ERROR found

Usage:
  python3 validate_sql.py file1.sql file2.sql ...
  Prints a Markdown report to stdout and also writes it to $GITHUB_STEP_SUMMARY
  if that env var is set (GitHub Actions sets this automatically).
"""

import os
import re
import sys

# --- Configure these lists for your team's needs -----------------------

TYPO_MAP = {
    r"\bFORM\b": "FROM",
    r"\bSELET\b": "SELECT",
    r"\bINSTERT\b": "INSERT",
    r"\bUPDTAE\b": "UPDATE",
    r"\bDELET\b": "DELETE",
    r"\bWEHRE\b": "WHERE",
    r"\bGROUB\b": "GROUP",
}

# Example deprecated / discouraged functions. Edit this list to match
# your actual database engine (MySQL/Postgres/SQL Server/etc.)
DEPRECATED_FUNCTIONS = [
    "SQL_CALC_FOUND_ROWS",
    "OLD_PASSWORD",
    "PASSWORD(",
]

STATEMENT_KEYWORDS = re.compile(
    r"\b(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|SET|MERGE|TRUNCATE)\b",
    re.IGNORECASE,
)

DROP_ALTER_RE = re.compile(r"\b(DROP|ALTER)\b", re.IGNORECASE)

# -------------------------------------------------------------------------


def strip_comments(sql: str) -> str:
    """Remove -- line comments and /* */ block comments so they don't
    confuse quote/semicolon counting."""
    sql = re.sub(r"--.*", "", sql)
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.DOTALL)
    return sql


def check_file(path: str):
    errors = []
    warnings = []

    with open(path, "r", encoding="utf-8", errors="replace") as f:
        raw = f.read()

    code = strip_comments(raw)

    # 1. Unmatched single quotes (naive: count of ' should be even,
    #    accounting for escaped '' quotes used as literal apostrophes)
    quote_count = len(re.findall(r"(?<!')'(?!')", code.replace("''", "")))
    if quote_count % 2 != 0:
        errors.append("Unmatched single quote (') detected — check string literals.")

    # 2. Missing semicolons: rough heuristic. Count statement-starting
    #    keywords vs semicolons found. If there are clearly more
    #    statements than terminators, flag it.
    statements = STATEMENT_KEYWORDS.findall(code)
    semicolons = code.count(";")
    if statements and semicolons < 1:
        errors.append(
            f"No semicolons found but {len(statements)} SQL statement(s) detected. "
            "Every statement should end with ';'."
        )
    elif statements and semicolons < max(1, len(statements) - 1):
        # allow some slack (multi-line statements, CASE/END blocks, etc.)
        warnings.append(
            f"Possible missing semicolon: found {len(statements)} statement keyword(s) "
            f"but only {semicolons} ';' terminator(s). Please double-check."
        )

    # 3. Common typos
    for pattern, correct in TYPO_MAP.items():
        for m in re.finditer(pattern, code, re.IGNORECASE):
            errors.append(
                f"Possible typo '{m.group(0)}' near position {m.start()} — did you mean '{correct}'?"
            )

    # 4. Deprecated functions
    for func in DEPRECATED_FUNCTIONS:
        if func.upper() in code.upper():
            warnings.append(f"Use of deprecated/discouraged function: {func}")

    # 5. Breaking changes: DROP / ALTER
    for m in DROP_ALTER_RE.finditer(code):
        line_no = code[: m.start()].count("\n") + 1
        warnings.append(
            f"Breaking-change statement '{m.group(0).upper()}' on line {line_no} — "
            "requires compatibility review before merge."
        )

    return errors, warnings


def main():
    files = sys.argv[1:]
    if not files:
        print("No SQL files passed to validate_sql.py — nothing to check.")
        return 0

    report_lines = ["## 🗄️ SQL Validation Report\n"]
    total_errors = 0

    for path in files:
        if not os.path.isfile(path):
            continue
        errors, warnings = check_file(path)
        total_errors += len(errors)

        report_lines.append(f"### `{path}`")
        if not errors and not warnings:
            report_lines.append("✅ No issues found.\n")
            continue

        if errors:
            report_lines.append("**❌ Errors (must fix):**")
            for e in errors:
                report_lines.append(f"- {e}")
        if warnings:
            report_lines.append("**⚠️ Warnings (needs review):**")
            for w in warnings:
                report_lines.append(f"- {w}")
        report_lines.append("")

    report = "\n".join(report_lines)
    print(report)

    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as f:
            f.write(report + "\n")

    return 1 if total_errors > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
