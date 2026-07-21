---
name: dashboard-omnistate
description: Generates or updates the interactive OmniState Visual Dashboard with real project metrics, token savings, and task progress. Use when the user asks to see project status or dashboard.
---

# Dashboard Generator (OmniState v1.2.0)

**SKILL GOAL:** Extract project metrics and status to generate a premium-looking Visual Dashboard.

**ENFORCEMENT:**
- Add `omnistate-dashboard.html` to `.gitignore` before writing the file.

**INSTRUCTIONS:**

1. **Information Extraction:**
   - Read `project-summary.md` -> Extract Project Name, Main Tech Stack, and Modules.
   - Read `tasks-history.json` -> Count total tasks and "todo" tasks.
   - Read `tasks-archive.json` -> Count total archived tasks.
   - List `chunks/` folder -> Count files and extract metadata (dates/labels) from the last 5 chunks.
   - Read `omnistate.config.json` -> Get current OmniState version.
2. **Data Processing:**
   - **Token Savings Estimate**: Calculate realistically by estimating the length of the data preserved and avoided. Sum the word count of `chunks/` and `tasks-archive.json`, multiply by ~1.3 tokens per word, plus estimate the context overhead saved per interaction. Report the final result in 'k'.
   - **Chart Data**: Calculate real cumulative token savings over time (array of integers) mapped to actual chronological snapshot (chunks) dates.
   - **Task Accuracy**: Ensure `totalTasks`, `activeTasks`, and `archivedTasks` accurately reflect the exact real count from the JSON files.
   - **Timeline**: Map the last 5 chunks to `{date, label, text}` objects realistically using their actual filesystem timestamps and contents.
3. **Template Injection:**
   - **Check Local Template**: If `.opencode/templates/dashboard.html` exists, use it.
   - **Fallback**: Check the OmniState installation directory for `dist/templates/dashboard.html`.
   - **Final Fallback**: Use the built-in template logic to generate the HTML inline.
   - Stringify the extracted data into a JSON object.
   - **SECURITY**: Ensure the JSON is HTML-safe for injection into a `<script>` tag. Escape any `<` character as `\u003c` to prevent `</script>` breakout.
   - Replace the `{{DATA}}` placeholder in the template with the sanitized JSON.
4. **Output:**
   - Write the resulting file to `omnistate-dashboard.html` in the project root.
   - Also generate a summary in the session output.
5. **Report:** "Visual Dashboard updated. Open `omnistate-dashboard.html` (ignored by git) to view progress."
