# AI Prompts

Reusable AI prompts for various development tasks.

## Categories

### GitHub (`github/`)
Prompts for GitHub repository management and automation:
- `repo-security-setup.md` - Configure repository security settings with CODEOWNERS, branch protection, and security features

## Usage

Simply reference the prompt when working with Claude Code:

```
Use the prompt from ai/prompts/github/repo-security-setup.md
```

The prompt will automatically:
1. Ask if you want to install it globally (one-time setup)
2. Execute the configuration for your current repository
3. Provide instructions for easier future use

After global installation, add this to `~/.claude/CLAUDE.md` for instant access:
```markdown
When user says "setup repo security", use ~/.claude/prompts/github/repo-security-setup.md
```
