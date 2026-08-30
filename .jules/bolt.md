## 2023-10-27 - Batching jq calls in Bash is a micro-optimization
**Learning:** Combining multiple `jq` calls into a single execution using Bashisms like process substitution (`< <(...)`) in cold paths (e.g., dashboard scripts run once per build) sacrifices readability for negligible milliseconds of gain.
**Action:** Focus performance optimizations on blocking frontend resources (like adding `defer` to heavy CDN scripts) or true hot loops, rather than micro-optimizing Bash subprocess spawns in setup scripts.
