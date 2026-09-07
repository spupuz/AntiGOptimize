## 2024-09-07 - Python dict.get() eager evaluation defeats caching
**Learning:** Using an expensive function call as the default argument in `dict.get()` (e.g., `dict.get(key, expensive_func())`) causes the function to evaluate eagerly on every call, completely defeating the purpose of the cache and leading to redundant disk I/O.
**Action:** Always use lazy evaluation when accessing dictionaries with expensive defaults: assign the result of `.get(key)` to a variable, check if it `is None`, and only execute the expensive function if true.
