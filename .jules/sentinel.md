## 2024-09-05 - Symlink Traversal Vulnerability in mktemp Mitigation
**Vulnerability:** When mitigating symlink traversal vulnerabilities using `mktemp` to create a temporary file, using `cp -a` or `cp` to copy the original file's contents into the temp file preserves symlinks or attributes, which could replace the secure temporary file with a symlink to the target, defeating the mitigation.
**Learning:** The `-a` (archive) flag or standard `cp` can preserve symlinks or overwrite file descriptors, defeating the purpose of creating a secure temporary file.
**Prevention:** Instead of `cp`, use `cat "$original_file" > "$tmp_file"` to copy only the file contents securely into the temporary file created by `mktemp`.
