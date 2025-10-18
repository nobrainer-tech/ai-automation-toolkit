# AI Automation Toolkit

A comprehensive collection of reusable automation resources, AI tools, and development utilities.

## Structure

### `.github/workflows/`
Reusable GitHub Actions workflows for CI/CD automation.

### `ai/`
AI-related resources and configurations:
- **prompts/** - Reusable AI prompts for development tasks
- **agents/** - Custom AI agents for specialized automation
- **chat-modes/** - VS Code chat mode configurations
- **configs/** - Configuration files for AI development tools

### `n8n/`
n8n automation workflows:
- **data-sync/** - Data synchronization workflows
- **notifications/** - Notification automation
- **backup-automation/** - Automated backup solutions

### `scripts/`
Utility scripts for various automation needs:
- **tampermonkey/** - Browser automation scripts
- **batch/** - Windows batch scripts
- **shell/** - Unix/Linux shell scripts
- **python/** - Python utility scripts

### `docker/`
Docker templates and configurations:
- **playwright/** - Playwright test environment
- **selenium/** - Selenium test environment

### `configs/`
Reusable development tool configurations:
- **eslint/** - ESLint configurations
- **prettier/** - Prettier configurations
- **vscode/** - VS Code settings

## Quick Start

### GitHub Repository Security Setup

Configure repository security with one simple command:

```
Use the prompt from ai/prompts/github/repo-security-setup.md
```

The prompt will:
1. Ask if you want to install it globally (recommended for use across all repositories)
2. Configure CODEOWNERS file with @nobrainer-tech
3. Set up branch protection rules (if available)
4. Enable security features (vulnerability alerts, automated fixes)
5. Run verification checks and generate a report

After global installation, you can use it in any repo by adding this to your `~/.claude/CLAUDE.md`:
```markdown
When user says "setup repo security", use ~/.claude/prompts/github/repo-security-setup.md
```

## Usage

Browse the directories above to find reusable templates and configurations. Each directory contains a README with specific usage instructions.

## Contributing

This is a personal toolkit, but feel free to use any resources that might be helpful for your projects.
