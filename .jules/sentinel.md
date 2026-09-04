## 2024-09-04 - Fix symlink traversal mitigation bypass in migrate.sh
**Vulnerability:** When mitigating symlink traversal vulnerabilities using `mktemp`, using `cp -a` to copy the original file's contents into the temporary file defeats the mitigation by preserving symlinks, replacing the secure temp file.
**Learning:** The `-a` (archive) flag preserves symlinks. Overwriting a securely created temporary file with `cp -a` introduces a symlink traversal vulnerability.
**Prevention:** Use `cat "$original_file" > "$tmp_file"` to copy only the file contents into the securely created temporary file, ensuring the temporary file remains a regular file.
