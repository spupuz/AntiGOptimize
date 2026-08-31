## 2024-05-14 - [File Read Overhead in Python]
**Learning:** Loading entire files into memory using `path.read_text().split()` or `path.read_text().splitlines()` before processing creates unnecessary overhead for large files.
**Action:** Use line-by-line reading with file iterators for tasks like word counting or finding headers, which is faster and uses less memory.
