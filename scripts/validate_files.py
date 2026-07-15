#!/usr/bin/env python3
"""
validate_files.py  (Level 2 - file-level review)

Advisory-only checks for file naming:

  - SQL routine files (.sql): file name must be UPPERCASE and must match the
    routine name declared inside the file (CREATE PROCEDURE/FUNCTION/VIEW).
    e.g. MERGE_AWD_MASTER_DATA.sql with CREATE PROCEDURE `MERGE_AWD_MASTER_DATA` -> OK
         merge_awd_master_data.sql                                      -> suggestion
         WRONG_NAME.sql with CREATE PROCEDURE `MERGE_AWD_MASTER_DATA`   -> suggestion
  - Module-level YAML changelogs must use one of these common names:
      PROCEDURES.yaml, FUNCTIONS.yaml, SCRIPTS.yaml, VIEWS.yaml
    e.g. PROCEDURES.yaml   -> OK
         proceduresss.yaml -> suggestion to use an approved common name

Higher-level aggregator/config files such as NTU.yaml, ALL.yaml, RELEASE.yaml,
and properties.yaml are not module changelogs and are excluded from the common
YAML-name rule.

This script is ADVISORY ONLY: it prints Markdown suggestions and ALWAYS
exits 0, so it can never block or reject a PR. If every file name is already
uppercase, it prints nothing.

Usage:
  python3 validate_files.py file1.sql file2.yaml ...
  Prints a Markdown report to stdout and appends it to $GITHUB_STEP_SUMMARY
  when running inside GitHub Actions.
"""

import os
import re
import sys

# Extensions we review: routines (.sql) and scripts (.yaml).
CHECKED_EXTENSIONS = (".sql", ".yaml")
COMMON_YAML_NAMES = {
    "PROCEDURES.yaml",
    "FUNCTIONS.yaml",
    "SCRIPTS.yaml",
    "VIEWS.yaml",
}

# CREATE [OR REPLACE] PROCEDURE|FUNCTION|VIEW|TRIGGER `NAME` or NAME
ROUTINE_NAME_RE = re.compile(
    r"CREATE\s+(?:OR\s+REPLACE\s+)?(?:DEFINER\s*=\s*\S+\s+)?"
    r"(PROCEDURE|FUNCTION|VIEW|TRIGGER)\s+`?([A-Za-z0-9_]+)`?",
    re.IGNORECASE | re.DOTALL,
)


def read_routine_name(path: str):
    """Return the routine/object name declared inside a .sql file, or None."""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            content = f.read(16384)
    except OSError:
        return None
    match = ROUTINE_NAME_RE.search(content)
    return match.group(2) if match else None


def check_file_name(path: str):
    """Return naming suggestions for a DB file (empty list when valid)."""
    suggestions = []
    norm = path.replace("\\", "/")
    if not os.path.isfile(path):
        return suggestions

    base = os.path.basename(norm)
    stem, ext = os.path.splitext(base)

    if ext.lower() == ".sql":
        routine_name = read_routine_name(path)

        # Prefer a single clear suggestion: rename to match the routine (uppercase).
        if routine_name and routine_name.upper() != stem.upper():
            expected = routine_name.upper()
            suggestions.append(
                f"`{norm}`: file name `{stem}` does not match the routine name "
                f"`{routine_name}` inside the file. "
                f"Consider renaming the file to `{expected}.sql`."
            )
        elif stem != stem.upper():
            suggestions.append(
                f"`{norm}`: file name should be UPPERCASE. "
                f"Consider renaming `{stem}` to `{stem.upper()}`."
            )

        return suggestions

    # Module changelogs follow:
    # <release>/<client>/<module>/<COMMON_NAME>.yaml
    is_module_yaml = ext.lower() == ".yaml" and len(norm.split("/")) >= 4
    if is_module_yaml and base not in COMMON_YAML_NAMES:
        allowed = ", ".join(f"`{name}`" for name in sorted(COMMON_YAML_NAMES))
        suggestions.append(
            f"`{norm}`: module YAML file must use an approved common name. "
            f"Allowed names: {allowed}."
        )

    return suggestions


def main():
    files = sys.argv[1:]
    db_files = [f for f in files if f.lower().endswith(CHECKED_EXTENSIONS)]

    suggestions = []
    for path in db_files:
        suggestions.extend(check_file_name(path))

    # Only post a message when a file name violates a naming rule.
    if not suggestions:
        return 0

    lines = ["### File Naming Quality", ""]
    for s in suggestions:
        lines.append(f"- {s}")

    emit("\n".join(lines))
    return 0


def emit(report: str):
    print(report)
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as f:
            f.write(report + "\n")


if __name__ == "__main__":
    sys.exit(main())
