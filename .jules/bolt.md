## 2026-08-28 - [Batching loop operations]
**Learning:** Subprocesses inside loops like 'wc -w' create an N+1 performance bottleneck that adds significant execution overhead.
**Action:** Batch the file inputs into an array and call 'wc -w' outside the loop, streaming the outputs directly into 'while read' to maintain low execution time.
