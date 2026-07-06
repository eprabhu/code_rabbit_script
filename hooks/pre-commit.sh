#!/bin/bash

# Check staged files and set the commit template based on file types or paths
if git diff --cached --name-only | grep -q '\.sql$'; then
    git config commit.template .git-templates/db-commit-template.txt
elif git diff --cached --name-only | grep -q '\.java$'; then
    git config commit.template .git-templates/backend-commit-template.txt
elif git diff --cached --name-only | grep -q '\.ts$'; then
    git config commit.template .git-templates/frontend-commit-template.txt
else
    echo "No matching commit template found. Proceeding with default."
    git config --unset commit.template
fi



#!/bin/bash

# Pre-commit hook for validating MySQL .sql scripts

# Patterns to validate
USE_DB_REGEX="USE [a-zA-Z0-9_]+;"
SEMICOLON_REGEX=";$"
CURRENT_TIMESTAMP_REGEX="DEFAULT CURRENT_TIMESTAMP"
ON_UPDATE_REGEX="ON UPDATE CURRENT_TIMESTAMP"
DELIMITER_REGEX="DELIMITER //"
CREATE_TABLE_REGEX="CREATE TABLE"
PRIMARY_KEY_REGEX="PRIMARY KEY"
INDEX_REGEX="INDEX|UNIQUE"
ALTER_TABLE_REGEX="ALTER TABLE"

# Get all staged .sql files
STAGED_SQL_FILES=$(git diff --cached --name-only | grep '\.sql$')

# If no SQL files are staged, skip validation
if [ -z "$STAGED_SQL_FILES" ]; then
    exit 0
fi

echo "Validating staged SQL files..."

for file in $STAGED_SQL_FILES; do
    echo "Checking file: $file"

    # Check if database name is used
    if grep -q -E "$USE_DB_REGEX" "$file"; then
        echo "Error: Database name found in $file. Please remove 'USE <database>' statements."
        exit 1
    fi

    # Check for missing semicolon at the end of statements
    if ! grep -q -E "$SEMICOLON_REGEX" "$file"; then
        echo "Error: Missing semicolon in $file. Ensure all statements end with a semicolon."
        exit 1
    fi

    # Check for CURRENT_TIMESTAMP default and ON UPDATE
    if ! grep -q -E "$CURRENT_TIMESTAMP_REGEX" "$file" && grep -q -E "$ON_UPDATE_REGEX" "$file"; then
        echo "Warning: 'DEFAULT CURRENT_TIMESTAMP' or 'ON UPDATE CURRENT_TIMESTAMP' missing in $file."
    fi

    # Check for proper DELIMITER usage in routines
    if grep -q -i -E "create procedure|create function" "$file"; then
        if ! grep -q -E "$DELIMITER_REGEX" "$file"; then
            echo "Error: DELIMITER not set properly in $file for procedures/functions."
            exit 1
        fi
    fi

    # Validate `CREATE TABLE` includes PRIMARY KEY and INDEX
    if grep -q -i -E "$CREATE_TABLE_REGEX" "$file"; then
        if ! grep -q -i -E "$PRIMARY_KEY_REGEX" "$file"; then
            echo "Warning: PRIMARY KEY not defined in a CREATE TABLE statement in $file."
        fi
        if ! grep -q -i -E "$INDEX_REGEX" "$file"; then
            echo "Warning: INDEX or UNIQUE constraint not defined in $file."
        fi
    fi

    # Check for combined `ALTER TABLE` statements
    if grep -q -i -E "$ALTER_TABLE_REGEX" "$file"; then
        ALTER_COUNT=$(grep -c -i -E "$ALTER_TABLE_REGEX" "$file")
        if [ "$ALTER_COUNT" -gt 1 ]; then
            echo "Warning: Multiple ALTER TABLE statements in $file. Consider combining them."
        fi
    fi

    # Check for missing comments
    if ! grep -q -i -E "-- |/\*.*\*/" "$file"; then
        echo "Warning: No comments found in $file. Please document your changes."
    fi
done

echo "All SQL checks passed!"
exit 0
