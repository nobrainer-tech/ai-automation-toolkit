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

Just run this command in any repository:

```
Use the prompt from ai/prompts/github/repo-security-setup.md
```

**What happens:**
1. Prompt asks if you want to install it globally (recommended)
2. If yes, it copies itself to `~/.claude/prompts/github/`
3. Then runs the security configuration for your current repository

**For even easier access** (after global installation), add to `~/.claude/CLAUDE.md`:

```markdown
When user says "setup repo security", use ~/.claude/prompts/github/repo-security-setup.md
```

Then just type: `setup repo security`

## Requirements

- GitHub CLI (gh) - will be installed if not present
- GitHub authentication
- Repository access rights
