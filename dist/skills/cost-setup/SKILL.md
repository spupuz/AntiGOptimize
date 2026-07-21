---
name: cost-setup
description: Initializes OmniState persistent memory for a project. Sets up config, task tracking, memory files, and git protection. Use when first setting up OmniState in a new project.
---

# Cost Setup

**Goal:** Initialize project memory with token-saving configuration and git protection.

**Rules:**
- Output in English only.
- Never commit memory files to git.

## Steps

### 1. Find OmniState Installation
Locate the OmniState installation by checking these paths in order:
- `~/.agents/skills/` (global skills)
- `~/.config/opencode/skills/`
- `~/.gemini/antigravity/plugins/omnistate/`
- The current project's `.opencode/skills/`

If found, run the update script to sync: `bash <path>/update.sh --auto .`

### 2. Create Memory Files
Create these files in the project root if they don't exist:

| File | Purpose |
|------|---------|
| `omnistate.config.json` | OmniState configuration |
| `project-summary.md` | Architecture and state index |
| `tasks-history.json` | Active and completed tasks |
| `tasks-archive.json` | Archived (old) tasks |
| `AGENTS.md` | AI agent definitions |
| `AI_POLICY.md` | AI interaction rules |
| `CONTEXT.md` | Project context for AI |

Use templates from the OmniState installation directory, or create minimal versions inline.

### 3. Git Protection
Add these to `.gitignore`:
```
omnistate.config.json
project-summary.md
tasks-history.json
tasks-archive.json
AGENTS.md
AI_POLICY.md
CONTEXT.md
omnistate-dashboard.html
/omnistate-dashboard.html
chunks/
.opencode/
.agents/
.kilo/
.omnistate/
```

### 4. Cost Routing
Tell the user: "Cost routing active. I will suggest smaller models for routine tasks."
Ask: "Activate model-switch reminders? (Y/N)"

### 5. Completion
Display: "OmniState initialized. Memory files created. Git protection enforced."
