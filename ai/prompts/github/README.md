# GitHub Repository Management Prompts

Reusable prompts for GitHub repository configuration and management using GitHub CLI.

## Available Prompts

### repo-security-setup.md
Universal prompt for configuring repository security settings including:
- CODEOWNERS configuration
- Branch protection rules
- Security alerts
- Automated security fixes
- Post-setup verification checks

## Usage

### Option 1: Use in Current Repository
```
Use the prompt from ai/prompts/github/repo-security-setup.md
```

The prompt will ask if you want to install it globally for use in all repositories.

### Option 2: Install Globally First
```bash
# Manual installation
mkdir -p ~/.claude/prompts/github
cp ai/prompts/github/repo-security-setup.md ~/.claude/prompts/github/

# Then use in any repository
Use the prompt from ~/.claude/prompts/github/repo-security-setup.md
```

### Option 3: Add to Global CLAUDE.md
Add this to your `~/.claude/CLAUDE.md` for even easier access:

```markdown
## GitHub Repository Security Setup

When the user says "setup repo security", use the prompt from ~/.claude/prompts/github/repo-security-setup.md
```

Then simply type: `setup repo security`

## Requirements

- GitHub CLI (gh) - will be installed if not present
- GitHub authentication
- Repository access rights
