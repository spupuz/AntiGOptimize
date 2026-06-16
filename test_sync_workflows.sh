#!/bin/bash

# Exit on any failure
set -e

echo "Running sync_workflows tests..."

# Setup temporary directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Mock paths needed by sync_workflows
export TARGET_PLUGIN_PATH="$TEST_DIR/global_plugins/omnistate"
export SCRIPT_DIR="$TEST_DIR/script_dir"

# Create necessary dummy directories
mkdir -p "$TARGET_PLUGIN_PATH/dist/workflows"
mkdir -p "$TARGET_PLUGIN_PATH/dist/templates"
mkdir -p "$SCRIPT_DIR"

# Create dummy source files
echo "workflow content" > "$TARGET_PLUGIN_PATH/dist/workflows/wf1.txt"
echo "template content" > "$TARGET_PLUGIN_PATH/dist/templates/tpl1.txt"

# Provide mock values for variables used inside sync_workflows
export SILENT=true
PROTECTED_PATTERNS=("/omnistate-dashboard.html" "project-summary.md")

# Create a modified script that exposes the functions but doesn't run the main action
cat << 'MOCK' > "$TEST_DIR/test_update.sh"
#!/bin/bash
export SILENT=true
export PROTECTED_PATTERNS=("/omnistate-dashboard.html" "project-summary.md")

log() {
    if [ "$SILENT" = false ]; then
        echo -e "$1"
    fi
}
MOCK

sed -n '/^sync_workflows() {/,/^}/p' update.sh >> "$TEST_DIR/test_update.sh"

source "$TEST_DIR/test_update.sh"

echo "Setup complete."

# Define a function to easily fail and return non-zero
fail() {
    echo "FAIL: $1"
    false
}

# --- Test 1: Sync to an empty target project ---
echo "Test 1: Sync to an empty target project"
TARGET_PROJECT_1="$TEST_DIR/project1"
mkdir -p "$TARGET_PROJECT_1"

sync_workflows "$TARGET_PROJECT_1"

for wfDir in ".agent" ".agents"; do
    if [ ! -f "$TARGET_PROJECT_1/$wfDir/workflows/wf1.txt" ]; then
        fail "Expected workflow file not found in $wfDir"
    fi
    if [ ! -f "$TARGET_PROJECT_1/$wfDir/templates/tpl1.txt" ]; then
        fail "Expected template file not found in $wfDir"
    fi
done

if [ -f "$TARGET_PROJECT_1/.gitignore" ]; then
    fail "Expected .gitignore NOT to be created if it didn't exist"
fi
echo "Test 1 passed."

# --- Test 2: Sync to a project with an existing .gitignore (no trailing newline) ---
echo "Test 2: Sync to a project with existing .gitignore"
TARGET_PROJECT_2="$TEST_DIR/project2"
mkdir -p "$TARGET_PROJECT_2"
printf "node_modules" > "$TARGET_PROJECT_2/.gitignore"

sync_workflows "$TARGET_PROJECT_2"

if ! grep -q "^node_modules$" "$TARGET_PROJECT_2/.gitignore"; then
    fail "Expected original content 'node_modules' to be preserved"
fi
for pattern in ".agent/" ".agents/" "${PROTECTED_PATTERNS[@]}"; do
    if ! grep -q "^$pattern" "$TARGET_PROJECT_2/.gitignore"; then
        fail "Expected pattern '$pattern' in .gitignore"
    fi
done
# check if "node_modules.agent/" or something accidentally appended to the same line
if grep -q "node_modules.agent/" "$TARGET_PROJECT_2/.gitignore"; then
    fail "Expected newline before appending patterns"
fi
echo "Test 2 passed."

# --- Test 3: Sync to a project with pre-existing patterns ---
echo "Test 3: Sync to a project with pre-existing patterns"
TARGET_PROJECT_3="$TEST_DIR/project3"
mkdir -p "$TARGET_PROJECT_3"
echo -e "node_modules\n.agents/\n/omnistate-dashboard.html" > "$TARGET_PROJECT_3/.gitignore"

sync_workflows "$TARGET_PROJECT_3"

# Count occurrences of .agents/ and /omnistate-dashboard.html
count_agents=$(grep -c "^.agents/$" "$TARGET_PROJECT_3/.gitignore")
if [ "$count_agents" -ne 1 ]; then
    fail "Expected '.agents/' to appear exactly once, found $count_agents times"
fi

count_dashboard=$(grep -c "^/omnistate-dashboard.html$" "$TARGET_PROJECT_3/.gitignore")
if [ "$count_dashboard" -ne 1 ]; then
    fail "Expected '/omnistate-dashboard.html' to appear exactly once, found $count_dashboard times"
fi

# Ensure .agent/ was added since it wasn't there
if ! grep -q "^.agent/$" "$TARGET_PROJECT_3/.gitignore"; then
    fail "Expected '.agent/' to be added"
fi
echo "Test 3 passed."

echo "All sync_workflows tests passed successfully."
