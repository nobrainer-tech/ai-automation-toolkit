# Repository Security Setup

## Quick Start

### Single Repository

```bash
cd /path/to/your/repo
./scripts/shell/setup-repo-security.sh

# Or specify repository explicitly
./scripts/shell/setup-repo-security.sh nobrainer-tech/ai-automation-toolkit
```

### Multiple Repositories

```bash
# Create repos list
cat > my-repos.txt << EOF
nobrainer-tech/repo1
nobrainer-tech/repo2
aras88/personal-repo
EOF

# Run bulk setup
./scripts/shell/setup-multiple-repos.sh my-repos.txt
```

### Custom Configuration

```bash
# Different branch and settings
DEFAULT_BRANCH=master MIN_APPROVALS=2 CODEOWNER=@myteam ./setup-repo-security.sh

# For multiple repos
DEFAULT_BRANCH=master MIN_APPROVALS=2 ./setup-multiple-repos.sh repos.txt
```

## Applied Settings

### Branch Protection
- Require N approving reviews (default: 1)
- Require code owner review
- Dismiss stale reviews on new commits
- Require last push approval
- Require linear history
- Block force pushes
- Block branch deletion
- Require conversation resolution
- Enforce for administrators

### Security Features
- Vulnerability alerts enabled
- Automated security fixes enabled

### CODEOWNERS
- Created in .github/CODEOWNERS
- Default owner applied to all files
- Customizable per path

## Environment Variables

- `DEFAULT_BRANCH` - Branch to protect (default: main)
- `MIN_APPROVALS` - Minimum required approvals (default: 1)
- `CODEOWNER` - Default code owner (default: @nobrainer-tech)
