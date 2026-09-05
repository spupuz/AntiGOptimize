## 2026-09-05 - Redundant I/O in script chunk parsing
**Learning:** Python scripts processing collections of files (like markdown chunks) often iterate over them multiple times for different metrics (e.g. summing total words vs. building timeline charts), resulting in O(N) redundant disk I/O operations.
**Action:** When multiple sections of a script read the same files to compute metrics, always cache these metrics in a dictionary during the first read to eliminate redundant I/O operations later in the script.
