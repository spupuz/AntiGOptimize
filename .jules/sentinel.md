## 2026-08-18 - Critical Command Injection in Python Scripts Embedded in Shell
**Vulnerability:** Shell variables (`$PROJECT_NAME`, `$TASKS_HISTORY`, etc.) were directly interpolated into strings representing Python scripts run via `python3 -c "..."`. This allowed an attacker to execute arbitrary Python code by injecting single quotes and Python payloads into variable values (e.g. project names or filenames).
**Learning:** Even though the scripts are invoked from a bash environment, dynamically constructing code strings in interpreted languages (Python, Node.js) using bash parameter expansion is a direct vector for command injection.
**Prevention:** Never use string interpolation to pass dynamic data into embedded scripts. For Python, pass dynamic strings securely via `sys.argv` (e.g. `python3 -c "import sys; print(sys.argv[1])" "$VAR"`) or standard environment variables (`os.environ`). For JSON escaping specifically, utilities like `jq --arg` provide a robust alternative.

## 2025-03-03 - Prevent XSS in JSON Script Injection
**Vulnerability:** JSON data injected directly into an HTML `<script>` tag via a template placeholder (e.g., `{{DATA}}`) can cause an XSS vulnerability. If the JSON data contains `</script>`, the browser will close the script block early and execute any subsequent HTML/JS.
**Learning:** Even when the data is formatted as valid JSON, the HTML parser takes precedence and will look for closing tags. This means simple stringification isn't safe if the data contains user input or file contents (like project names) with malicious tags.
**Prevention:** When generating JSON for `<script>` tag injection (like in `collect-dashboard-data.sh` and `.py`), always escape the `<` character as `\u003c` in the final JSON string.
