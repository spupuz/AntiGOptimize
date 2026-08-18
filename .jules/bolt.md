## 2024-08-18 - Python Subprocesses in Bash
**Learning:** Using `python3 -c` inside bash scripts repeatedly (e.g. for simple JSON parsing or string serialization) is extremely slow due to Python VM startup overhead. In this project, running python 9 times took over 1 second total, whereas the native `jq` utility takes around 0.005s per invocation and `awk` is extremely fast.
**Action:** When parsing JSON in bash scripts, use `jq` natively instead of invoking `python3 -c` inline, as it significantly improves shell execution performance and eliminates subprocess VM startup bottlenecks.
