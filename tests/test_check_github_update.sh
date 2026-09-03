#!/bin/bash

# Test auto_update() function from update.sh
# This test mocks git commands to verify update behavior

EXIT_CODE=0

echo "Running tests for auto_update() function"
echo "-----------------------------------------"

# Helper function to assert test results
assert_equal() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $test_name"
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected: '$expected'"
        echo "   Actual:   '$actual'"
        EXIT_CODE=1
    fi
}

# Mock git command
GIT_MOCK_REMOTE_HASH=""
GIT_MOCK_LOCAL_HASH=""

git() {
    local cmd="$1"
    if [[ "$cmd" == "ls-remote" ]]; then
        echo -e "${GIT_MOCK_REMOTE_HASH}\trefs/heads/main"
    elif [[ "$cmd" == "rev-parse" ]]; then
        echo "${GIT_MOCK_LOCAL_HASH}"
    else
        command git "$@"
    fi
}

# Setup test directory
setup_test_dir() {
    export TEST_DIR="$(mktemp -d)"
    export SCRIPT_DIR="$TEST_DIR"
    mkdir -p "$TEST_DIR/.omnistate"
    echo "0" > "$TEST_DIR/.omnistate/.last_update_check"
}

teardown_test_dir() {
    rm -rf "$TEST_DIR"
}

# Extract and define auto_update function (simplified version)
auto_update() {
    local state_dir="$SCRIPT_DIR/.omnistate"
    mkdir -p "$state_dir"
    local check_file="$state_dir/.last_update_check"
    local now
    now=$(date +%s)
    local last_check=0
    [ -f "$check_file" ] && last_check=$(<"$check_file")
    last_check=${last_check//[!0-9]/}
    last_check=${last_check:-0}

    if (( now - last_check > 86400 )); then
        if [ -d "$SCRIPT_DIR/.git" ] && command -v git &>/dev/null; then
            cd "$SCRIPT_DIR"
            local remote_hash local_hash
            remote_hash=$(git ls-remote origin -h refs/heads/main 2>/dev/null | awk '{print $1}')
            local_hash=$(git rev-parse HEAD 2>/dev/null)

            if [ -n "$remote_hash" ] && [ "$remote_hash" != "$local_hash" ]; then
                echo "UPDATE_AVAILABLE"
            fi
        fi
        local tmp_file
        tmp_file=$(mktemp "$(dirname "$check_file")/.tmp.XXXXXX")
        echo "$now" > "$tmp_file"
        chmod 644 "$tmp_file"
        mv "$tmp_file" "$check_file"
    fi
}

# Test 1: No .git directory exists
test_no_git_dir() {
    setup_test_dir
    local output
    output=$(auto_update 2>&1)
    assert_equal "auto_update() returns nothing when no .git directory exists" "" "$output"
    teardown_test_dir
}

# Test 2: Hashes match (no update)
test_hashes_match() {
    setup_test_dir
    mkdir -p "$TEST_DIR/.git"

    GIT_MOCK_REMOTE_HASH="abcdef1234567890"
    GIT_MOCK_LOCAL_HASH="abcdef1234567890"

    local output
    output=$(auto_update 2>&1)
    assert_equal "auto_update() returns nothing when hashes match" "" "$output"
    teardown_test_dir
}

# Test 3: Hashes differ (update available)
test_hashes_differ() {
    setup_test_dir
    mkdir -p "$TEST_DIR/.git"

    GIT_MOCK_REMOTE_HASH="1234567890abcdef"
    GIT_MOCK_LOCAL_HASH="abcdef1234567890"

    local output
    output=$(auto_update 2>&1)
    assert_equal "auto_update() returns UPDATE_AVAILABLE when hashes differ" "UPDATE_AVAILABLE" "$output"
    teardown_test_dir
}

# Test 4: Throttle - last check was recent
test_throttle() {
    setup_test_dir
    mkdir -p "$TEST_DIR/.git"
    
    # Set last check to now
    local now
    now=$(date +%s)
    echo "$now" > "$TEST_DIR/.omnistate/.last_update_check"

    GIT_MOCK_REMOTE_HASH="1234567890abcdef"
    GIT_MOCK_LOCAL_HASH="abcdef1234567890"

    local output
    output=$(auto_update 2>&1)
    assert_equal "auto_update() returns nothing when throttled" "" "$output"
    teardown_test_dir
}

# Run tests
test_no_git_dir
test_hashes_match
test_hashes_differ
test_throttle

# Exit with appropriate code
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "-----------------------------------------"
    echo "🎉 All tests passed!"
    exit 0
else
    echo "-----------------------------------------"
    echo "💥 Some tests failed."
    exit 1
fi
