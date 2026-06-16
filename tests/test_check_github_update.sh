#!/bin/bash

# Define project root relative to tests directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source the script containing the function
source "${PROJECT_ROOT}/update.sh"

EXIT_CODE=0

echo "Running tests for check_github_update() function in update.sh"
echo "----------------------------------------------"

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

# Mock TARGET_PLUGIN_PATH directory creation
setup_test_dir() {
    export TARGET_PLUGIN_PATH="$(mktemp -d)"
}

teardown_test_dir() {
    rm -rf "$TARGET_PLUGIN_PATH"
}

# Test 1: No .git directory exists
test_no_git_dir() {
    setup_test_dir
    check_github_update
    local status=$?
    assert_equal "check_github_update() returns 0 when no .git directory exists" "0" "$status"
    teardown_test_dir
}

# Test 2: Hashes match
test_hashes_match() {
    setup_test_dir
    mkdir -p "$TARGET_PLUGIN_PATH/.git"

    GIT_MOCK_REMOTE_HASH="abcdef1234567890"
    GIT_MOCK_LOCAL_HASH="abcdef1234567890"

    # Store current dir to return to it
    local orig_dir=$(pwd)

    check_github_update
    local status=$?

    # Restore dir because check_github_update cds into TARGET_PLUGIN_PATH
    cd "$orig_dir"

    assert_equal "check_github_update() returns 0 when local and remote hashes match" "0" "$status"
    teardown_test_dir
}

# Test 3: Hashes differ
test_hashes_differ() {
    setup_test_dir
    mkdir -p "$TARGET_PLUGIN_PATH/.git"

    GIT_MOCK_REMOTE_HASH="1234567890abcdef"
    GIT_MOCK_LOCAL_HASH="abcdef1234567890"

    # Store current dir to return to it
    local orig_dir=$(pwd)

    check_github_update
    local status=$?

    # Restore dir
    cd "$orig_dir"

    assert_equal "check_github_update() returns 1 when hashes differ (update available)" "1" "$status"
    teardown_test_dir
}

# Run tests
test_no_git_dir
test_hashes_match
test_hashes_differ

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "----------------------------------------------"
    echo "🎉 All tests passed!"
else
    echo "----------------------------------------------"
    echo "💥 Some tests failed."
fi

exit $EXIT_CODE
