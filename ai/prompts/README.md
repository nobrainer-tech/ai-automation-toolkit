# AI Prompts

Reusable AI prompts for various development tasks.

## Categories

### GitHub (`github/`)
Prompts for GitHub repository management and automation:
- `repo-security-setup.md` - Configure repository security settings with CODEOWNERS, branch protection, and security features

## Usage

### Quick Use
Simply reference the prompt when working with Claude Code:

```
Use the prompt from ai/prompts/github/repo-security-setup.md
```

The prompt will offer to install itself globally for easier future use.

### Global Installation
For easier access across all repositories, see the installation instructions in each category's README.

Example: Add to your `~/.claude/CLAUDE.md`:
```markdown
When the user says "setup repo security", use the prompt from ~/.claude/prompts/github/repo-security-setup.md
```

Then simply type `setup repo security` in any repository.
