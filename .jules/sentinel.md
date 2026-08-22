## 2026-08-18 - Critical Command Injection in Python Scripts Embedded in Shell
**Vulnerability:** Shell variables (`$PROJECT_NAME`, `$TASKS_HISTORY`, etc.) were directly interpolated into strings representing Python scripts run via `python3 -c "..."`. This allowed an attacker to execute arbitrary Python code by injecting single quotes and Python payloads into variable values (e.g. project names or filenames).
**Learning:** Even though the scripts are invoked from a bash environment, dynamically constructing code strings in interpreted languages (Python, Node.js) using bash parameter expansion is a direct vector for command injection.
**Prevention:** Never use string interpolation to pass dynamic data into embedded scripts. For Python, pass dynamic strings securely via `sys.argv` (e.g. `python3 -c "import sys; print(sys.argv[1])" "$VAR"`) or standard environment variables (`os.environ`). For JSON escaping specifically, utilities like `jq --arg` provide a robust alternative.

## 2024-08-22 - XSS via Unenforced LLM Instructions
**Vulnerability:** The dashboard data collection relied solely on prompt instructions (`SKILL.md`) telling the AI agent to escape `<` as `\u003c` to prevent `</script>` breakouts. LLM outputs are non-deterministic and can easily fail to apply the escape, resulting in Cross-Site Scripting (XSS) when the JSON is injected into the HTML dashboard.
**Learning:** Critical security controls like JSON string escaping must never be delegated to AI agent prompts.
**Prevention:** Implement security measures deterministically inside the data generation scripts (Bash/Python) to guarantee execution regardless of how the agent behaves.
