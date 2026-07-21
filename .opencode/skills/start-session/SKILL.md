---
name: start-session
description: Restores OmniState session state with context purge and minimal token usage. Use at the start of every coding session to load project memory efficiently.
---

# Start Session (OmniState v1.2.0)

**SKILL GOAL:** Restore session state while minimizing the context window to maximize performance and save tokens.

**INSTRUCTIONS:**

1. **Context Purge:** Ignore all files/history not explicitly listed below. Start fresh.
2. **Integrity Check:** If OmniState is installed globally, run the update script:
   - Check `~/.config/opencode/omnistate/update.sh` or `~/.gemini/antigravity/plugins/omnistate/update.sh`
   - Run `bash <path>/update.sh --auto .` if found.
3. **State Loading:**
   - Read `omnistate.config.json` (settings).
   - Read `project-summary.md` (architecture).
   - Read `tasks-history.json` (active tasks).
   - Read `AGENTS.md`, `AI_POLICY.md`, and `CONTEXT.md`.
   - **Proactive Population**: If any of these files contain placeholders or are incomplete, perform a shallow scan of the repository to populate them with relevant project context.
4. **Summary (Strictly English & Concise):**
   - Display: "OmniState v[version] active."
   - Display: "Core architecture loaded."
   - List only "todo" tasks from `tasks-history.json`.
5. **Enforcement:** Do not read full repository files until explicitly requested for a specific task.
