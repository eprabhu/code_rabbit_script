#!/usr/bin/env python3
"""
validate_files.py  (Level 2 - file-level review)

Advisory-only checks for file naming:

  - SQL routine file names must be UPPERCASE.
    e.g. MERGE_AWD_MASTER_DATA.sql  -> OK
         merge_awd_master_data.sql  -> suggestion to rename
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
import sys

# Extensions we review: routines (.sql) and scripts (.yaml).
CHECKED_EXTENSIONS = (".sql", ".yaml")
COMMON_YAML_NAMES = {
    "PROCEDURES.yaml",
    "FUNCTIONS.yaml",
    "SCRIPTS.yaml",
    "VIEWS.yaml",
}


def check_file_name(path: str):
    """Return a naming suggestion for a DB file, or None when valid."""
    norm = path.replace("\\", "/")
    # Deleted / missing paths are not naming issues for this PR tip.
    if not os.path.isfile(path):
        return None

    base = os.path.basename(norm)
    stem, ext = os.path.splitext(base)

    if ext.lower() == ".sql" and stem != stem.upper():
        return (
            f"`{norm}`: file name should be UPPERCASE. "
            f"Consider renaming `{stem}` to `{stem.upper()}`."
        )

    # Module changelogs follow:
    # <release>/<client>/<module>/<COMMON_NAME>.yaml
    is_module_yaml = ext.lower() == ".yaml" and len(norm.split("/")) >= 4
    if is_module_yaml and base not in COMMON_YAML_NAMES:
        allowed = ", ".join(f"`{name}`" for name in sorted(COMMON_YAML_NAMES))
        return (
            f"`{norm}`: module YAML file must use an approved common name. "
            f"Allowed names: {allowed}."
        )

    return None


def main():
    files = sys.argv[1:]
    db_files = [f for f in files if f.lower().endswith(CHECKED_EXTENSIONS)]

    suggestions = []
    for path in db_files:
        result = check_file_name(path)
        if result:
            suggestions.append(result)

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
