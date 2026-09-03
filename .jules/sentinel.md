## 2024-05-14 - Fix Symlink Traversal Vulnerability in update.sh
**Vulnerability:** Found symlink traversal risk via insecure file overwriting (`>>` and `>`) for `.gitignore` and `.last_update_check` files in `update.sh`.
**Learning:** Shell scripts using naive redirection natively follow symlinks. An attacker could exploit this by creating a symlink in a predictable location and tricking the script into overwriting sensitive target files.
**Prevention:** Always use `mktemp` to securely create an ephemeral file in the destination directory, manipulate it, apply `chmod 644` to enforce correct permissions, and substitute the destination file using `mv` for atomicity.
