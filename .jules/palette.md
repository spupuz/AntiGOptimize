## 2024-08-30 - Actionable Empty State Styling
**Learning:** Empty states in data-heavy views must include actionable subtext. Styling CLI commands directly within empty state subtext using monospace and distinctive backgrounds significantly improves user comprehension.
**Action:** Always wrap inline commands or critical actionable keywords in `<code>` tags with distinctive styling (e.g., `font-mono`, `bg-slate-800`) within static empty state descriptions, using `innerHTML` if the string is purely static.
