#!/bin/bash
set -euo pipefail
test_dir=$(mktemp -d)
mkdir -p "$test_dir/chunks"
cat << 'JSON' > "$test_dir/omnistate.config.json"
{
  "project_name": "Test \" Project",
  "omnistate_version": "1.5.0"
}
JSON
bash dist/scripts/collect-dashboard-data.sh "$test_dir" "$test_dir/output.json" > /dev/null
if [ ! -f "$test_dir/output.json" ]; then
    echo "❌ FAIL: output.json not created"
    exit 1
fi
if ! jq . "$test_dir/output.json" >/dev/null; then
    echo "❌ FAIL: output.json is not valid JSON"
    exit 1
fi
if ! grep -q '"Test \\" Project"' "$test_dir/output.json"; then
    echo "❌ FAIL: output.json does not contain project name"
    exit 1
fi
echo "✅ PASS: collect-dashboard-data.sh"
rm -rf "$test_dir"
