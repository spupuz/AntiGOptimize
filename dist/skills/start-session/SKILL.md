---
name: start-session
description: Loads OmniState session state with minimal token usage. Use at the start of every coding session to restore project context efficiently.
---

# Start Session

**Goal:** Restore session state while minimizing context window usage.

## Steps

### 1. Context Purge
Start fresh. Ignore files not listed below.

### 2. Auto-Update
Check for OmniState updates (runs once per day):
- Find the update script in `~/.agents/skills/`, `~/.config/opencode/`, or `~/.gemini/antigravity/plugins/omnistate/`
- Run: `bash <path>/update.sh --auto .`

### 3. Load State
Read these files (only if they exist):

| File | Content |
|------|---------|
| `omnistate.config.json` | Settings and preferences |
| `project-summary.md` | Architecture overview |
| `tasks-history.json` | Active tasks |
| `AGENTS.md` | Agent definitions |
| `AI_POLICY.md` | Interaction rules |
| `CONTEXT.md` | Project context |

If any file has placeholders or is empty, scan the repository to populate it.

### 4. Report
Display concisely:
- "OmniState v[version] active."
- "Architecture loaded."
- List only tasks with `status: "todo"` from `tasks-history.json`.

### 5. Enforcement
Do NOT read full repository files unless explicitly asked for a specific task.
