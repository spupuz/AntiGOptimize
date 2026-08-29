## 2024-05-24 - Native Bash String Matching Over External Processes
**Learning:** Using pipelines with `head` and `grep` inside Bash loops introduces significant N+1 process spawning overhead.
**Action:** Use native Bash string matching inside a `while IFS= read -r line` loop to extract prefixes or read early lines from a file without spawning external processes.
