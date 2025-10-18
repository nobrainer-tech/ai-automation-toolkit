#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup-repo-security.sh"

DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
MIN_APPROVALS="${MIN_APPROVALS:-1}"
CODEOWNER="${CODEOWNER:-@nobrainer-tech}"

print_usage() {
    echo "Usage: $0 <repos_file>"
    echo ""
    echo "The repos_file should contain one repository per line in format:"
    echo "  owner/repo"
    echo ""
    echo "Environment variables:"
    echo "  DEFAULT_BRANCH    - Branch to protect (default: main)"
    echo "  MIN_APPROVALS     - Minimum required approvals (default: 1)"
    echo "  CODEOWNER         - Default code owner (default: @nobrainer-tech)"
    echo ""
    echo "Example repos_file content:"
    echo "  nobrainer-tech/repo1"
    echo "  nobrainer-tech/repo2"
    echo "  aras88/personal-repo"
    echo ""
    echo "Example:"
    echo "  $0 repos.txt"
    echo "  DEFAULT_BRANCH=master $0 repos.txt"
    exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
    print_usage
fi

REPOS_FILE=$1

if [ ! -f "$REPOS_FILE" ]; then
    echo "Error: File $REPOS_FILE not found"
    exit 1
fi

if [ ! -x "$SETUP_SCRIPT" ]; then
    echo "Error: Setup script not found or not executable: $SETUP_SCRIPT"
    exit 1
fi

TOTAL_REPOS=$(grep -v '^[[:space:]]*$' "$REPOS_FILE" | grep -v '^#' | wc -l | tr -d ' ')
CURRENT=0
SUCCEEDED=0
FAILED=0

echo "========================================="
echo "Bulk Repository Security Setup"
echo "========================================="
echo "Total repositories: $TOTAL_REPOS"
echo "Settings:"
echo "  Branch: $DEFAULT_BRANCH"
echo "  Min Approvals: $MIN_APPROVALS"
echo "  Code Owner: $CODEOWNER"
echo "========================================="
echo ""

while IFS= read -r repo || [ -n "$repo" ]; do
    if [ -z "$repo" ] || [[ "$repo" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    repo=$(echo "$repo" | xargs)

    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_REPOS] Processing: $repo"
    echo "----------------------------------------"

    if DEFAULT_BRANCH="$DEFAULT_BRANCH" MIN_APPROVALS="$MIN_APPROVALS" CODEOWNER="$CODEOWNER" "$SETUP_SCRIPT" "$repo"; then
        SUCCEEDED=$((SUCCEEDED + 1))
        echo "SUCCESS: $repo"
    else
        FAILED=$((FAILED + 1))
        echo "FAILED: $repo"
    fi

    echo ""
    echo ""

done < "$REPOS_FILE"

echo "========================================="
echo "Bulk Setup Complete"
echo "========================================="
echo "Total: $TOTAL_REPOS"
echo "Succeeded: $SUCCEEDED"
echo "Failed: $FAILED"
echo "========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi
