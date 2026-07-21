---
name: snapshot-session
description: Creates an OmniState snapshot with task archiving, summary distillation, and session chunking. Use at the end of a coding session or before context compaction to persist work state.
---

# Snapshot Session (OmniState v1.2.0)

**SKILL GOAL:** Persist work state and optimize memory for future sessions.

**INSTRUCTIONS:**

1. **State Sync:** If OmniState is installed globally, run the update script:
   - Check `~/.config/opencode/omnistate/update.sh` or `~/.gemini/antigravity/plugins/omnistate/update.sh`
   - Run `bash <path>/update.sh --auto .` if found.
2. **Task Archiving:**
   - Scan `tasks-history.json` for `status: done`.
   - If `done` tasks count > 10 OR (archive_threshold from config met):
     - Append them to `tasks-archive.json` with timestamp.
     - Remove them from `tasks-history.json`.
3. **Summary Distillation:**
   - Detect session changes.
   - Update `project-summary.md` section "Latest Progress":
     - Write a max 3-line distilled summary (keywords + core result).
4. **Session Chunk:**
   - Create `chunks/session-YYYYMMDD-HHMM.md`.
   - Content: Bullet points of technical changes ONLY.
5. **Documentation Maintenance:**
   - Review changes made during the session.
   - If architectural changes occurred, update `CONTEXT.md`.
   - If new tools or agent roles were introduced, update `AGENTS.md`.
   - If project rules or AI guidelines changed, update `AI_POLICY.md`.
6. **Dashboard Update (Automatic):**
   - If `omnistate-dashboard.html` exists in the root, run the **dashboard-omnistate** skill immediately to refresh the data.
7. **Report:** "Snapshot saved. [N] tasks archived. Memory optimized."
