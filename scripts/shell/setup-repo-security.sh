#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
MIN_APPROVALS="${MIN_APPROVALS:-1}"
REPO_NAME="${1:-}"
CODEOWNER="${CODEOWNER:-@nobrainer-tech}"

print_usage() {
    echo "Usage: $0 [REPO_OWNER/REPO_NAME]"
    echo ""
    echo "Environment variables:"
    echo "  DEFAULT_BRANCH    - Branch to protect (default: main)"
    echo "  MIN_APPROVALS     - Minimum required approvals (default: 1)"
    echo "  CODEOWNER         - Default code owner (default: @nobrainer-tech)"
    echo ""
    echo "Examples:"
    echo "  $0 nobrainer-tech/ai-automation-toolkit"
    echo "  DEFAULT_BRANCH=master MIN_APPROVALS=2 $0 myorg/myrepo"
    exit 1
}

check_gh_auth() {
    if ! gh auth status &>/dev/null; then
        echo "Error: GitHub CLI not authenticated. Run 'gh auth login' first."
        exit 1
    fi
}

get_current_repo() {
    local repo
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
    if [ -z "$repo" ]; then
        echo "Error: Not in a git repository or no remote configured"
        exit 1
    fi
    echo "$repo"
}

create_codeowners() {
    local repo=$1
    local codeowners_dir=".github"
    local codeowners_file="$codeowners_dir/CODEOWNERS"

    echo "Creating CODEOWNERS file..."

    if [ ! -d "$codeowners_dir" ]; then
        mkdir -p "$codeowners_dir"
    fi

    cat > "$codeowners_file" << EOF
# CODEOWNERS file
# These owners will be requested for review when someone opens a pull request.
# https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

# Global owners - will be requested for review on all changes
* $CODEOWNER

# Specific paths (examples - customize as needed)
# /scripts/ $CODEOWNER
# *.sh $CODEOWNER
# /n8n/ $CODEOWNER
# /.github/ $CODEOWNER
EOF

    echo "CODEOWNERS file created at $codeowners_file"
}

create_copilot_workflow() {
    local workflows_dir=".github/workflows"
    local workflow_file="$workflows_dir/auto-request-copilot-review.yml"

    echo "Creating auto-request Copilot review workflow..."

    if [ ! -d "$workflows_dir" ]; then
        mkdir -p "$workflows_dir"
    fi

    cat > "$workflow_file" << 'EOF'
name: Auto Request Copilot Review

on:
  pull_request:
    types: [opened, ready_for_review]

permissions:
  pull-requests: write

jobs:
  request-copilot-review:
    runs-on: ubuntu-latest
    if: github.event.pull_request.draft == false

    steps:
      - name: Request review from Copilot
        uses: actions/github-script@v7
        with:
          script: |
            try {
              await github.rest.pulls.requestReviewers({
                owner: context.repo.owner,
                repo: context.repo.repo,
                pull_number: context.payload.pull_request.number,
                reviewers: ['copilot']
              });
              console.log('✓ Successfully requested review from @copilot');
            } catch (error) {
              console.log('Note: Could not add @copilot as reviewer:', error.message);
              console.log('This is expected if @copilot is not a collaborator');
            }
EOF

    echo "Copilot workflow created at $workflow_file"
}

enable_branch_protection() {
    local repo=$1
    local branch=$2

    echo "Enabling branch protection for $branch..."

    local response
    response=$(gh api \
        --method PUT \
        "/repos/$repo/branches/$branch/protection" \
        --input - 2>&1 <<EOF
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": $MIN_APPROVALS,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "require_last_push_approval": true
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
EOF
)

    if echo "$response" | grep -q "HTTP 403"; then
        echo "WARNING: Branch protection not available for this repository"
        echo "  - Branch protection requires GitHub Pro or public repository"
        echo "  - CODEOWNERS file will still work for PR reviews"
        echo "  - Consider upgrading to GitHub Pro or making repo public"
        return 1
    elif echo "$response" | grep -q "message"; then
        echo "ERROR: Failed to enable branch protection"
        echo "$response"
        return 1
    else
        echo "Branch protection enabled for $branch"
        return 0
    fi
}

enable_security_features() {
    local repo=$1

    echo "Enabling security features..."

    gh api \
        --method PATCH \
        "/repos/$repo" \
        -f has_vulnerability_alerts=true \
        &>/dev/null

    gh api \
        --method PUT \
        "/repos/$repo/automated-security-fixes" \
        &>/dev/null || echo "Note: Automated security fixes require Dependabot to be enabled"

    echo "Security features enabled"
}

configure_default_branch() {
    local repo=$1
    local branch=$2

    local current_default
    current_default=$(gh repo view "$repo" --json defaultBranchRef -q .defaultBranchRef.name)

    if [ "$current_default" != "$branch" ]; then
        echo "Current default branch: $current_default"
        echo "Checking if $branch exists..."

        if gh api "/repos/$repo/git/refs/heads/$branch" &>/dev/null; then
            echo "Setting $branch as default branch..."
            gh api \
                --method PATCH \
                "/repos/$repo" \
                -f default_branch="$branch" \
                &>/dev/null
            echo "Default branch updated to $branch"
        else
            echo "Warning: Branch $branch does not exist. Using current default: $current_default"
            DEFAULT_BRANCH=$current_default
        fi
    else
        echo "Default branch is already $branch"
    fi
}

commit_and_push_files() {
    echo "Committing and pushing configuration files..."

    local has_changes=false

    if ! git diff --quiet .github/CODEOWNERS 2>/dev/null; then
        has_changes=true
    fi

    if ! git diff --quiet .github/workflows/auto-request-copilot-review.yml 2>/dev/null; then
        has_changes=true
    fi

    if [ "$has_changes" = false ]; then
        echo "No changes to commit"
        return
    fi

    git add .github/CODEOWNERS .github/workflows/auto-request-copilot-review.yml
    git commit -m "Configure repository security settings

- Add CODEOWNERS file (@nobrainer-tech)
- Add auto-request Copilot review workflow
- Require code owner reviews for all PRs
- Automatically add @copilot as reviewer to PRs"

    git push origin "$DEFAULT_BRANCH"
    echo "Configuration files pushed to remote"
}

main() {
    check_gh_auth

    if [ -z "$REPO_NAME" ]; then
        REPO_NAME=$(get_current_repo)
        echo "Using current repository: $REPO_NAME"
    fi

    echo "========================================="
    echo "Repository Security Setup"
    echo "========================================="
    echo "Repository: $REPO_NAME"
    echo "Protected Branch: $DEFAULT_BRANCH"
    echo "Min Approvals: $MIN_APPROVALS"
    echo "Code Owner: $CODEOWNER"
    echo "========================================="
    echo ""

    configure_default_branch "$REPO_NAME" "$DEFAULT_BRANCH"

    create_codeowners "$REPO_NAME"

    create_copilot_workflow

    commit_and_push_files

    local branch_protection_enabled=false
    if enable_branch_protection "$REPO_NAME" "$DEFAULT_BRANCH"; then
        branch_protection_enabled=true
    fi

    enable_security_features "$REPO_NAME"

    echo ""
    echo "========================================="
    echo "Setup completed!"
    echo "========================================="
    echo ""

    if [ "$branch_protection_enabled" = true ]; then
        echo "Branch protection rules applied:"
        echo "  - Require $MIN_APPROVALS approving review(s)"
        echo "  - Require code owner review"
        echo "  - Dismiss stale reviews on new commits"
        echo "  - Require last push approval"
        echo "  - Require linear history"
        echo "  - Block force pushes"
        echo "  - Block branch deletion"
        echo "  - Require conversation resolution"
        echo "  - Enforce for administrators"
        echo ""
    else
        echo "Branch protection: NOT AVAILABLE"
        echo "  Note: Requires GitHub Pro or public repository"
        echo ""
    fi

    echo "CODEOWNERS configured:"
    echo "  - Default owner: $CODEOWNER"
    echo "  - Will request review on all PRs"
    echo ""
    echo "Auto-request Copilot review:"
    echo "  - Workflow: .github/workflows/auto-request-copilot-review.yml"
    echo "  - Automatically adds @copilot as reviewer to all non-draft PRs"
    echo ""
    echo "Security features enabled:"
    echo "  - Vulnerability alerts"
    echo "  - Automated security fixes"
    echo ""
    echo "View settings: https://github.com/$REPO_NAME/settings"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_usage
fi

main
