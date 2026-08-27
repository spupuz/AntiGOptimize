## 2024-05-24 - JSON XSS Escaping Completeness
**Vulnerability:** Escaping only `<` as `\u003c` in injected JSON is insufficient. In some contexts, an unescaped `>` can still be leveraged for XSS or cause parsing issues within script blocks if an attacker crafts malicious input to break out of the tag context.
**Learning:** Both `<` and `>` must be escaped as `\u003c` and `\u003e` respectively when injecting untrusted JSON data into an HTML script block to ensure complete safety from tag-breaking XSS attacks.
**Prevention:** Always escape both `<` and `>` characters when serializing or injecting JSON into HTML templates.
