---
name: dashboard-omnistate
description: Generates an interactive OmniState Visual Dashboard with real project metrics, token savings, and task progress. Use when the user asks to see project status, metrics, or dashboard.
---

# Dashboard Generator

**Goal:** Generate a premium HTML dashboard with real project metrics.

**Enforcement:** Add `omnistate-dashboard.html` to `.gitignore` before writing.

## Steps

### 1. Collect Data
Read from the project:

| Source | Extract |
|--------|---------|
| `project-summary.md` | Project name, tech stack, modules |
| `tasks-history.json` | Total tasks, active ("todo") tasks |
| `tasks-archive.json` | Archived tasks count |
| `chunks/` directory | Last 5 session chunks (dates, labels) |
| `omnistate.config.json` | OmniState version |

### 2. Calculate Metrics
- **Token Savings**: Sum word count of `chunks/` and `tasks-archive.json`, multiply by ~1.3 tokens/word, plus context overhead savings. Report in 'k'.
- **Chart Data**: Real cumulative token savings over time, mapped to actual chunk dates.
- **Task Counts**: Exact numbers from JSON files.
- **Timeline**: Last 5 chunks mapped to `{date, label, text}` from real filesystem timestamps.

### 3. Find Dashboard Template
Check in order:
1. `.opencode/templates/dashboard.html` (project local)
2. The OmniState installation directory's `dist/templates/dashboard.html`
3. Generate inline if no template found

### 4. Inject Data
- Stringify the computed data as JSON
- **SECURITY**: Escape `<` as `\u003c` to prevent `</script>` breakout
- Replace `{{DATA}}` placeholder in the template

### 5. Output
Write `omnistate-dashboard.html` to the project root.
Report: "Dashboard updated. Open `omnistate-dashboard.html` to view."
