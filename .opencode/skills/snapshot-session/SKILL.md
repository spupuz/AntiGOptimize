---
name: snapshot-session
description: Saves an OmniState snapshot with task archiving, summary distillation, and session chunking. Use at the end of a coding session or before context compaction.
---

# Snapshot Session

**Goal:** Persist work state and optimize memory for future sessions.

## Steps

### 1. Auto-Update
Check for updates: run `bash <omnistate-path>/update.sh --auto .`

### 2. Archive Completed Tasks
Read `tasks-history.json`. Find tasks with `status: "done"`.

If done tasks count > 10:
- Append them to `tasks-archive.json` with a timestamp
- Remove them from `tasks-history.json`

### 3. Distill Summary
Read `project-summary.md`. Update the "Latest Progress" section with a max 3-line summary:
- Keywords + core result
- Date stamped

### 4. Create Session Chunk
Create `chunks/session-YYYYMMDD-HHMM.md` with:
- Bullet points of technical changes only
- No prose, no explanations

### 5. Update Documentation
If the session involved architectural changes:
- Update `CONTEXT.md` with new architecture info
- Update `AGENTS.md` if new agents or tools were introduced
- Update `AI_POLICY.md` if rules changed

### 6. Dashboard Refresh
If `omnistate-dashboard.html` exists in the project root, run the **dashboard-omnistate** skill to refresh it.

### 7. Report
"Snapshot saved. [N] tasks archived. Memory optimized."
