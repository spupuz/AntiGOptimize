#!/bin/bash

# Define project root relative to tests directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source the script containing the log function
source "${PROJECT_ROOT}/update.sh"

# Variable to track overall test status
EXIT_CODE=0

echo "Running tests for log() function in update.sh"
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

# Test 1: SILENT=false should echo the string
test_silent_false() {
    SILENT=false
    local output
    output=$(log "Test Message 1")
    assert_equal "log() outputs message when SILENT=false" "Test Message 1" "$output"
}

# Test 2: SILENT=true should echo nothing
test_silent_true() {
    SILENT=true
    local output
    output=$(log "Test Message 2")
    assert_equal "log() outputs nothing when SILENT=true" "" "$output"
}

# Test 3: Test behavior with unexpected SILENT values
test_silent_other() {
    SILENT="other"
    local output
    output=$(log "Test Message 3")
    assert_equal "log() outputs nothing when SILENT='other' (not 'false')" "" "$output"
}

# Run tests
test_silent_false
test_silent_true
test_silent_other

# Exit with appropriate code
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "----------------------------------------------"
    echo "🎉 All tests passed!"
    exit 0
else
    echo "----------------------------------------------"
    echo "💥 Some tests failed."
    exit 1
fi
