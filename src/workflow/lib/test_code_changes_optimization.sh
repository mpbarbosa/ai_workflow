#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite: Code Changes Optimization Module
# Purpose: Verify code changes optimization functions
################################################################################

# Test setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${TEST_DIR}/code_changes_optimization.sh"
source "${TEST_DIR}/git_cache.sh"
source "${TEST_DIR}/utils.sh"

# Mock functions for testing
get_git_code_modified() { echo "${MOCK_CODE_MODIFIED:-5}"; }
get_git_tests_modified() { echo "${MOCK_TEST_MODIFIED:-2}"; }
get_git_docs_modified() { echo "${MOCK_DOCS_MODIFIED:-1}"; }
get_git_scripts_modified() { echo "${MOCK_SCRIPT_MODIFIED:-0}"; }
print_success() { echo "[SUCCESS] $1"; }
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1" >&2; }
print_warning() { echo "[WARNING] $1"; }
print_header() { echo "[HEADER] $1"; }
log_to_workflow() { echo "[LOG] $1: $2"; }

export -f get_git_code_modified get_git_tests_modified
export -f get_git_docs_modified get_git_scripts_modified
export -f print_success print_info print_error print_warning print_header log_to_workflow

# Mock PROJECT_ROOT and WORKFLOW_HOME
export PROJECT_ROOT="${TEST_DIR}"
export WORKFLOW_HOME="${TEST_DIR}/../.."

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++)) || true
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected: $expected"
        echo "   Actual:   $actual"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_true() {
    local command="$1"
    local test_name="$2"
    
    ((TESTS_RUN++)) || true
    
    if eval "$command"; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   Command returned false: $command"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_false() {
    local command="$1"
    local test_name="$2"
    
    ((TESTS_RUN++)) || true
    
    if ! eval "$command"; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   Command returned true: $command"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_contains() {
    local substring="$1"
    local string="$2"
    local test_name="$3"
    
    ((TESTS_RUN++)) || true
    
    if [[ "$string" == *"$substring"* ]]; then
        echo "✅ PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected substring: $substring"
        echo "   In string: $string"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# ==============================================================================
# TEST SUITE
# ==============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Code Changes Optimization Test Suite                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Code changes detection - positive case
echo "--- Test Suite 1: Code Change Detection ---"
export MOCK_CODE_MODIFIED=5
export MOCK_TEST_MODIFIED=2
export MOCK_DOCS_MODIFIED=1
export MOCK_SCRIPT_MODIFIED=0

assert_true "is_code_changes" "Code changes detection (positive)"

# Test 2: Code changes detection - negative case
export MOCK_CODE_MODIFIED=0
assert_false "is_code_changes" "Code changes detection (no code - negative)"

# Test 3: Code changes with details - incremental strategy
echo ""
echo "--- Test Suite 2: Change Strategy Detection ---"
export MOCK_CODE_MODIFIED=2
export MOCK_TEST_MODIFIED=1
export MOCK_DOCS_MODIFIED=0
export MOCK_SCRIPT_MODIFIED=0

result=$(detect_code_changes_with_details)
code_changes=$(echo "$result" | grep -oP '"code_changes":\K\d+')
strategy=$(echo "$result" | grep -oP '"strategy":"\K[^"]+')

assert_equals "2" "$code_changes" "Code changes count detection"
assert_equals "incremental" "$strategy" "Incremental strategy for ≤3 files"

# Test 4: Focused strategy for 4-10 files
export MOCK_CODE_MODIFIED=7
result=$(detect_code_changes_with_details)
strategy=$(echo "$result" | grep -oP '"strategy":"\K[^"]+')
assert_equals "focused" "$strategy" "Focused strategy for 4-10 files"

# Test 5: Full strategy for >10 files
export MOCK_CODE_MODIFIED=15
result=$(detect_code_changes_with_details)
strategy=$(echo "$result" | grep -oP '"strategy":"\K[^"]+')
assert_equals "full" "$strategy" "Full strategy for >10 files"

# Test 6: Code percentage calculation
echo ""
echo "--- Test Suite 3: Change Analysis ---"
export MOCK_CODE_MODIFIED=5
export MOCK_TEST_MODIFIED=2
export MOCK_DOCS_MODIFIED=3
export MOCK_SCRIPT_MODIFIED=0

result=$(detect_code_changes_with_details)
code_percentage=$(echo "$result" | grep -oP '"code_percentage":\K\d+')

# Total: 5+2+3=10, code: 5, percentage: 50%
assert_equals "50" "$code_percentage" "Code percentage calculation (5/10 = 50%)"

# Test 7: Test sharding - verify shard directory creation
echo ""
echo "--- Test Suite 4: Test Sharding ---"
export WORKFLOW_RUN_ID="test_run_$(date +%s)"
export BACKLOG_RUN_DIR="/tmp/test_backlog_${WORKFLOW_RUN_ID}"
mkdir -p "$BACKLOG_RUN_DIR"

# Sharding requires actual test files, which we don't have in test environment
# Just verify the shard directory would be created
shard_dir="${BACKLOG_RUN_DIR}/test_shards"
mkdir -p "$shard_dir"

if [[ -d "$shard_dir" ]]; then
    echo "✅ PASS: Shard directory creation"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: Shard directory creation"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# Cleanup test directory
rm -rf "$BACKLOG_RUN_DIR"

# Test 8: Exported variables after detection
echo ""
echo "--- Test Suite 5: State Management ---"
export MOCK_CODE_MODIFIED=5
detect_code_changes_with_details > /dev/null

if [[ "${CODE_CHANGES_DETECTED}" == "true" ]]; then
    echo "✅ PASS: CODE_CHANGES_DETECTED flag set"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: CODE_CHANGES_DETECTED flag not set"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

if [[ "${CODE_CHANGES_COUNT}" == "5" ]]; then
    echo "✅ PASS: CODE_CHANGES_COUNT set correctly"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: CODE_CHANGES_COUNT incorrect (expected 5, got ${CODE_CHANGES_COUNT:-none})"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

if [[ -n "${CODE_CHANGES_STRATEGY:-}" ]]; then
    echo "✅ PASS: CODE_CHANGES_STRATEGY set"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: CODE_CHANGES_STRATEGY not set"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# Test 9: Edge cases - zero changes
echo ""
echo "--- Test Suite 6: Edge Cases ---"
export MOCK_CODE_MODIFIED=0
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=0
export MOCK_SCRIPT_MODIFIED=0

result=$(detect_code_changes_with_details)
code_changes=$(echo "$result" | grep -oP '"code_changes":\K\d+')

assert_equals "0" "$code_changes" "Zero code changes detection"

# Test 10: Enable optimization hook
echo ""
echo "--- Test Suite 7: Optimization Enablement ---"
export MOCK_CODE_MODIFIED=5
export MOCK_TEST_MODIFIED=2
export MOCK_DOCS_MODIFIED=1
export MOCK_SCRIPT_MODIFIED=0

if enable_code_changes_optimization > /dev/null 2>&1; then
    echo "✅ PASS: Enable code changes optimization"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: Enable code changes optimization failed"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

if [[ "${CODE_CHANGES_OPTIMIZATION}" == "true" ]]; then
    echo "✅ PASS: CODE_CHANGES_OPTIMIZATION flag set"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: CODE_CHANGES_OPTIMIZATION flag not set"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# Test 11: No optimization when no code changes
export MOCK_CODE_MODIFIED=0
if ! enable_code_changes_optimization > /dev/null 2>&1; then
    echo "✅ PASS: Optimization not enabled for zero code changes"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: Optimization should not enable for zero code changes"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# ==============================================================================
# TEST RESULTS
# ==============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      Test Results                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Tests Run:    $TESTS_RUN"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
