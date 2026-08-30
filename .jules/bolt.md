## 2026-08-28 - [Batching loop operations]
**Learning:** Subprocesses inside loops like 'wc -w' create an N+1 performance bottleneck that adds significant execution overhead.
**Action:** Batch the file inputs into an array and call 'wc -w' outside the loop, streaming the outputs directly into 'while read' to maintain low execution time.

## 2024-05-24 - Native Bash String Matching Over External Processes
**Learning:** Using pipelines with `head` and `grep` inside Bash loops introduces significant N+1 process spawning overhead.
**Action:** Use native Bash string matching inside a `while IFS= read -r line` loop to extract prefixes or read early lines from a file without spawning external processes.
