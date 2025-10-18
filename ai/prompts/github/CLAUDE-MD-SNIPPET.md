# CLAUDE.md Snippet for GitHub Repository Security Setup

Add this to your `~/.claude/CLAUDE.md` file to enable quick access to the repo security setup prompt.

## Installation Steps

1. Copy the prompt to global location (if not already done):
```bash
mkdir -p ~/.claude/prompts/github
cp ai/prompts/github/repo-security-setup.md ~/.claude/prompts/github/
```

2. Add this snippet to `~/.claude/CLAUDE.md`:

```markdown
## GitHub Repository Security Setup

When the user says "setup repo security" or "configure repo security", use the prompt from ~/.claude/prompts/github/repo-security-setup.md to configure the current repository with:
- CODEOWNERS file (@nobrainer-tech as default owner)
- Branch protection rules (if available)
- Security features (vulnerability alerts, automated fixes)
- Comprehensive verification checks

This prompt will ask if the user wants to install it globally before proceeding with the setup.
```

## Usage

After adding to CLAUDE.md, simply type in any repository:

```
setup repo security
```

or

```
configure repo security
```

Claude will automatically use the global prompt to configure your repository security settings.

## Benefits

- No need to remember the full prompt path
- Works in any repository
- Natural language command
- Consistent security configuration across all your projects
