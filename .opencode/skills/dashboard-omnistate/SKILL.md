---
name: dashboard-omnistate
description: Generates an interactive OmniState Visual Dashboard with real project metrics, token savings, and task progress. Use when the user asks to see project status, metrics, or dashboard.
---

# Dashboard Generator

**Goal:** Generate a premium HTML dashboard with **real** project metrics.

**Enforcement:** Add `omnistate-dashboard.html` to `.gitignore` before writing.

## Data Sources (Real Only)

| Source | Extract |
|--------|---------|
| `tasks-history.json` | Total tasks, active ("todo") tasks, done tasks |
| `tasks-archive.json` | Archived tasks count |
| `chunks/` directory | Session chunks (dates, labels, word count) |
| `project-summary.md` | Project name, tech stack, modules |
| `omni_cost.json` | API cost data (if tracked) |
| `omnistate.config.json` | OmniState version |

## Steps

### 1. Collect Real Data

**Option A: Use the collection script (recommended)**
```bash
# Linux/macOS
bash <OmniState>/dist/scripts/collect-dashboard-data.sh . dashboard-data.json

# Windows (PowerShell)
python <OmniState>\dist\scripts\collect-dashboard-data.py . dashboard-data.json
```

**Option B: Manual collection**
Read each source file and extract real values. Do NOT make up data.

### 2. Calculate Metrics
- **Token Savings**: Sum word count of `chunks/` and `tasks-archive.json`, multiply by ~1.3 tokens/word, plus context overhead savings (~4k per chunk). Report in 'k'.
- **Chart Data**: Real cumulative token savings over time, mapped to actual chunk dates.
- **Task Counts**: Exact numbers from JSON files.
- **Timeline**: Last 5 chunks mapped to `{date, label, text}` from real filesystem timestamps.
- **Architecture**: Modules from `project-summary.md`.

### 3. Find Dashboard Template
Check in order:
1. `.opencode/templates/dashboard.html` (project local)
2. The OmniState installation directory's `dist/templates/dashboard.html`
3. If no template found, report error — do NOT generate inline

### 4. Inject Data
- Use `dashboard-data.json` from step 1 (or manually collected data)
- **SECURITY**: Escape `<` as `\u003c` to prevent `</script>` breakout
- Replace `{{DATA}}` placeholder in the template

### 5. Output
Write `omnistate-dashboard.html` to the project root.
Report: "Dashboard updated with real data. Open `omnistate-dashboard.html` to view."

## Important
- **Never fabricate data.** If a source file doesn't exist, show 0 or "N/A".
- **Always use real file reads.** Do not invent task names, dates, or metrics.
- The dashboard template has NO fallback — if `{{DATA}}` is not replaced, it shows "No Dashboard Data".
