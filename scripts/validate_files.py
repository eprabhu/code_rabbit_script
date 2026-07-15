#!/usr/bin/env python3
"""
validate_files.py  (Level 2 - file-level review)

Advisory-only check for file NAMING. Right now it enforces a single rule:

  - DB script file names must be UPPERCASE.
    Routines are committed as .sql, scripts as .yaml, so BOTH are checked.
    e.g. MERGE_AWD_MASTER_DATA.sql  -> OK
         PROCEDURES.yaml            -> OK
         merge_awd_master_data.sql  -> suggestion to rename
         procedures.yaml            -> suggestion to rename

Only the file name (the part before the extension) is checked; the extension
itself is expected to stay lowercase. Underscores and digits are allowed
inside the name.

This script is ADVISORY ONLY: it prints Markdown suggestions and ALWAYS
exits 0, so it can never block or reject a PR.

Usage:
  python3 validate_files.py file1.sql file2.yaml ...
  Prints a Markdown report to stdout and appends it to $GITHUB_STEP_SUMMARY
  when running inside GitHub Actions.
"""

import os
import sys

# Extensions we review: routines (.sql) and scripts (.yaml).
CHECKED_EXTENSIONS = (".sql", ".yaml")


def check_uppercase(path: str):
    """Return a suggestion string if the file name is not uppercase, else None."""
    norm = path.replace("\\", "/")
    base = os.path.basename(norm)
    stem, _ext = os.path.splitext(base)

    # Compare the name portion against its uppercase form.
    if stem != stem.upper():
        return (
            f"`{norm}`: file name should be UPPERCASE. "
            f"Consider renaming `{stem}` to `{stem.upper()}`."
        )
    return None


def main():
    files = sys.argv[1:]
    lines = ["## Level 2 - File-level review\n"]

    db_files = [f for f in files if f.lower().endswith(CHECKED_EXTENSIONS)]

    if not db_files:
        lines.append("_No .sql or .yaml files to review._")
        emit("\n".join(lines))
        return 0

    suggestions = []
    for path in db_files:
        result = check_uppercase(path)
        if result:
            suggestions.append(result)

    if suggestions:
        lines.append("**Suggestions:**")
        for s in suggestions:
            lines.append(f"- {s}")
    else:
        lines.append("OK - All DB script file names are uppercase.")

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
