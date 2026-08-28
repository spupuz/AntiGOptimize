## 2024-05-24 - JSON XSS Escaping Completeness
**Vulnerability:** Escaping only `<` as `\u003c` in injected JSON is insufficient. In some contexts, an unescaped `>` can still be leveraged for XSS or cause parsing issues within script blocks if an attacker crafts malicious input to break out of the tag context.
**Learning:** Both `<` and `>` must be escaped as `\u003c` and `\u003e` respectively when injecting untrusted JSON data into an HTML script block to ensure complete safety from tag-breaking XSS attacks.
**Prevention:** Always escape both `<` and `>` characters when serializing or injecting JSON into HTML templates.

## 2024-08-28 - `.gitignore` Security Mismatch
**Vulnerability:** Checking if a pattern exists in a file using a substring match (e.g., `*pattern*` in bash or `.Contains(pattern)` in PowerShell) introduces false positives. If the target string `chunks/` is prefixed differently like `not-chunks/`, the matcher believes the requirement is fulfilled and skips appending `chunks/` to `.gitignore`. This can inadvertently expose confidential files and security secrets on version control.
**Learning:** Exact match pattern validation in configuration and ignore files requires line-oriented string evaluation instead of indiscriminate `.Contains()` checks.
**Prevention:** Always prepend a newline to both the source content block (`\n + content`) and the pattern check (`\n + pattern`) to forcefully lock substring searches to line beginnings or exact line values.
