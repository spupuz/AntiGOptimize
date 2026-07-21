---
name: cost-setup
description: Initializes OmniState persistent memory, auto-archiving, git protection, and cost-routing for a project. Use when setting up OmniState for the first time in a new project, or when reinitializing configuration.
---

# Cost Setup (OmniState v1.2.0)

**SKILL GOAL:** Initialize project memory with token-saving configurations and enforce git protection.

**GLOBAL RULES:**
- Output MUST be strictly in English.
- Never commit memory files, templates, or workflows to Git.

## Instructions:

1. **Automatic Sync:**
   - Identify global OmniState path: check `~/.config/opencode/omnistate/`, then `~/.gemini/antigravity/plugins/omnistate/`.
   - If found, run `bash <path>/update.sh --auto .` to align workflows.
   - If not found, skip sync (standalone mode).
2. **Memory Setup:**
   - Create `omnistate.config.json`, `project-summary.md`, `tasks-history.json`, `AGENTS.md`, `AI_POLICY.md`, and `CONTEXT.md` from templates if missing.
   - Initialize `tasks-archive.json`.
   - Templates can be found in the OmniState installation directory under `dist/templates/`, or create minimal versions inline.
3. **Total Git Protection:**
   - Ensure the following are in `.gitignore`:
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
4. **Cost Routing:**
   - Inform user: "Cost routing active. I will suggest switching to smaller models for routine tasks."
   - Ask: "Activate model-switch reminders? (Y/N)"
5. **Completion:** Show status: "Memory initialized. Total Git Protection enforced."
