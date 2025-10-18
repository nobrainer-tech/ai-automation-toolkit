# GitHub Repository Security Setup

Configure repository security settings following best practices using GitHub CLI.

## Task Overview

Set up comprehensive security configuration for the current GitHub repository including:
- CODEOWNERS file
- Branch protection rules
- Security alerts and automated fixes
- Verification of all settings

## Initial Setup Question

**IMPORTANT:** Before proceeding with repository security configuration, ask the user:

"Would you like to add this prompt to your global Claude Code configuration? This will make it available in all your repositories by simply saying 'setup repo security'."

Options:
1. **Yes, add to global configuration** - Copy this prompt to `~/.claude/prompts/github/repo-security-setup.md`
2. **No, just run it now** - Skip global installation and proceed with current repository setup
3. **Only install globally, don't run now** - Just copy to global config without running setup

### If user chooses "Yes" or "Only install globally":

1. Create directory if it doesn't exist:
   ```bash
   mkdir -p ~/.claude/prompts/github
   ```

2. Copy this prompt file to global location:
   ```bash
   cp ai/prompts/github/repo-security-setup.md ~/.claude/prompts/github/repo-security-setup.md
   ```

3. Verify installation:
   ```bash
   ls -lh ~/.claude/prompts/github/repo-security-setup.md
   ```

4. Inform user:
   ```
   ✓ Prompt installed globally!

   You can now use this in any repository by saying:
   - "Use the prompt from ~/.claude/prompts/github/repo-security-setup.md"
   - "setup repo security" (if you add this to your CLAUDE.md)

   Global prompts location: ~/.claude/prompts/github/
   ```

### If user chooses "Only install globally":
- Stop here after installation
- Do not proceed with repository setup

### If user chooses "Yes" or "No":
- Proceed with the repository security setup below

---

## Prerequisites Check

1. **Check GitHub CLI Installation**
   - Verify if `gh` CLI is installed
   - If not installed, install it based on the OS:
     - macOS: `brew install gh`
     - Linux: Follow official installation guide
     - Windows: `winget install --id GitHub.cli`

2. **Verify GitHub Authentication**
   - Run `gh auth status`
   - If not authenticated, run `gh auth login` and guide the user through authentication

## Configuration Steps

### 1. Repository Detection
- Detect current repository using `gh repo view --json nameWithOwner -q .nameWithOwner`
- Detect default branch using `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
- Display repository information to confirm with user

### 2. CODEOWNERS Setup
Create `.github/CODEOWNERS` file with the following configuration:
- Default owner: `@nobrainer-tech` (or ask user for custom owner if needed)
- Apply to all files by default (`*`)
- Include helpful comments and documentation URL
- Allow customization for specific paths

Example structure:
```
# CODEOWNERS file
# These owners will be requested for review when someone opens a pull request.
# https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

# Global owners - will be requested for review on all changes
* @nobrainer-tech

# Specific paths (customize as needed)
# /scripts/ @nobrainer-tech
# *.sh @nobrainer-tech
# /.github/ @nobrainer-tech
```

### 3. Commit and Push CODEOWNERS
- Stage the `.github/CODEOWNERS` file
- Create commit with descriptive message
- Push to the default branch

### 4. Branch Protection Configuration
Apply the following branch protection rules to the default branch:

```json
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
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
```

**Important:** Branch protection requires GitHub Pro or public repository. Handle gracefully if unavailable:
- Catch HTTP 403 errors
- Inform user about limitation
- Continue with other security settings

Use command:
```bash
gh api --method PUT "/repos/{owner}/{repo}/branches/{branch}/protection" --input - <<EOF
{...json above...}
EOF
```

### 5. Security Features
Enable repository security features:

**Vulnerability Alerts:**
```bash
gh api --method PATCH "/repos/{owner}/{repo}" -f has_vulnerability_alerts=true
```

**Automated Security Fixes:**
```bash
gh api --method PUT "/repos/{owner}/{repo}/automated-security-fixes"
```

## Verification Checks

After completing the setup, perform the following verification checks:

### Check 1: CODEOWNERS File Validation
- Verify `.github/CODEOWNERS` file exists
- Read and display the file content
- Confirm owner is properly set
- Check file is committed and pushed to remote

### Check 2: Branch Protection Status
Query branch protection status:
```bash
gh api "/repos/{owner}/{repo}/branches/{branch}/protection" 2>&1
```

Expected results:
- **Success (200):** Display enabled protection rules
- **HTTP 403:** Expected for free private repos - display informational message
- **HTTP 404:** Branch protection not configured - display warning

### Check 3: Security Features Status
Check enabled security features:
```bash
gh repo view --json hasVulnerabilityAlertsEnabled,securityPolicyUrl -q '.'
```

Display:
- Vulnerability alerts status
- Security policy URL (if exists)

### Check 4: Repository Settings Summary
Display final summary:
```bash
gh repo view --json nameWithOwner,defaultBranchRef,visibility,owner -q '.'
```

### Check 5: CODEOWNERS Syntax Validation
- Parse CODEOWNERS file
- Verify GitHub username/team format (@username or @org/team)
- Check for common syntax errors
- Confirm at least one global owner is defined

## Verification Report

Generate a comprehensive report showing:

```
========================================
Repository Security Verification Report
========================================

Repository: {owner}/{repo}
Visibility: {public/private}
Default Branch: {branch}

CODEOWNERS Configuration: ✓
  - File exists: Yes
  - Location: .github/CODEOWNERS
  - Global owner: @nobrainer-tech
  - Custom paths: {count}

Branch Protection: {✓ or ✗}
  - Status: {Enabled/Not Available/Error}
  - Require reviews: {1}
  - Require code owner review: {Yes/No}
  - Dismiss stale reviews: {Yes/No}
  - Enforce for admins: {Yes/No}
  - Linear history: {Yes/No}
  - Block force pushes: {Yes/No}

Security Features: ✓
  - Vulnerability alerts: {Enabled/Disabled}
  - Automated security fixes: {Enabled/Disabled}

Recommendations:
  - {List any recommendations or warnings}

View full settings: https://github.com/{owner}/{repo}/settings
========================================
```

## Error Handling

Handle common errors gracefully:

1. **GH CLI not installed:** Offer to install or provide installation instructions
2. **Not authenticated:** Guide user through `gh auth login`
3. **Not in git repository:** Display error and exit
4. **No remote configured:** Display error and ask user to configure remote
5. **Insufficient permissions:** Display error with link to repository settings
6. **Branch protection unavailable:** Inform user about GitHub Pro requirement
7. **API rate limit:** Display retry time and suggest waiting

## Customization Options

Allow user to customize (ask before proceeding if unclear):
- CODEOWNER username/team (default: @nobrainer-tech)
- Minimum required approvals (default: 1)
- Specific path ownership rules
- Whether to enforce for admins

## Success Criteria

Setup is successful when:
1. CODEOWNERS file created and pushed
2. Security features enabled
3. Branch protection configured (or gracefully skipped with explanation)
4. All verification checks pass
5. User receives comprehensive verification report
