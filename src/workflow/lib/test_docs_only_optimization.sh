#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite: Docs-Only Optimization Module
# Purpose: Verify docs-only fast track optimization functions
################################################################################

# Test setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${TEST_DIR}/docs_only_optimization.sh"
source "${TEST_DIR}/git_cache.sh"
source "${TEST_DIR}/utils.sh"

# Mock functions for testing
get_git_code_modified() { echo "${MOCK_CODE_MODIFIED:-0}"; }
get_git_tests_modified() { echo "${MOCK_TEST_MODIFIED:-0}"; }
get_git_docs_modified() { echo "${MOCK_DOCS_MODIFIED:-5}"; }
get_git_scripts_modified() { echo "${MOCK_SCRIPT_MODIFIED:-0}"; }
print_success() { echo "[SUCCESS] $1"; }
print_info() { echo "[INFO] $1"; }
print_error() { echo "[ERROR] $1" >&2; }
print_header() { echo "[HEADER] $1"; }
log_to_workflow() { echo "[LOG] $1: $2"; }

export -f get_git_code_modified get_git_tests_modified
export -f get_git_docs_modified get_git_scripts_modified
export -f print_success print_info print_error print_header log_to_workflow

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

# ==============================================================================
# TEST SUITE
# ==============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           Docs-Only Optimization Test Suite                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Docs-only detection - positive case
echo "--- Test Suite 1: Docs-Only Detection ---"
export MOCK_CODE_MODIFIED=0
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=5
export MOCK_SCRIPT_MODIFIED=0

assert_true "is_docs_only_change" "Docs-only change detection (positive)"

# Test 2: Docs-only detection - negative case (code changes)
export MOCK_CODE_MODIFIED=2
assert_false "is_docs_only_change" "Docs-only change detection (code present - negative)"

# Test 3: Docs-only detection - negative case (test changes)
export MOCK_CODE_MODIFIED=0
export MOCK_TEST_MODIFIED=3
assert_false "is_docs_only_change" "Docs-only change detection (tests present - negative)"

# Test 4: Docs-only detection - negative case (script changes)
export MOCK_TEST_MODIFIED=0
export MOCK_SCRIPT_MODIFIED=1
assert_false "is_docs_only_change" "Docs-only change detection (scripts present - negative)"

# Test 5: Docs-only detection with confidence
echo ""
echo "--- Test Suite 2: Confidence Detection ---"
export MOCK_CODE_MODIFIED=0
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=5
export MOCK_SCRIPT_MODIFIED=0

result=$(detect_docs_only_with_confidence)
is_docs=$(echo "$result" | grep -oP '"is_docs_only":\K\w+')
confidence=$(echo "$result" | grep -oP '"confidence":\K\d+')

assert_equals "true" "$is_docs" "Docs-only confidence detection (is_docs_only)"
assert_equals "100" "$confidence" "Docs-only confidence score (100%)"

# Test 6: Step skip decision for docs-only
echo ""
echo "--- Test Suite 3: Step Skip Decisions ---"

# Setup for docs-only scenario
export MOCK_CODE_MODIFIED=0
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=5
export MOCK_SCRIPT_MODIFIED=0

# Steps that should be skipped
assert_true "should_skip_step_docs_only 5" "Step 5 (Test Review) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 6" "Step 6 (Test Generation) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 7" "Step 7 (Test Execution) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 8" "Step 8 (Dependencies) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 9" "Step 9 (Code Quality) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 10" "Step 10 (Context) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 13" "Step 13 (Prompt Engineer) should be skipped for docs-only"
assert_true "should_skip_step_docs_only 14" "Step 14 (UX Analysis) should be skipped for docs-only"

# Steps that should NOT be skipped
assert_false "should_skip_step_docs_only 0" "Step 0 (Pre-Analysis) should NOT be skipped"
assert_false "should_skip_step_docs_only 1" "Step 1 (Documentation) should NOT be skipped"
assert_false "should_skip_step_docs_only 2" "Step 2 (Consistency) should NOT be skipped"
assert_false "should_skip_step_docs_only 11" "Step 11 (Git Finalization) should NOT be skipped"
assert_false "should_skip_step_docs_only 12" "Step 12 (Markdown Linting) should NOT be skipped"

# Test 7: Dependency hash generation
echo ""
echo "--- Test Suite 4: Dependency Cache ---"

# Mock PROJECT_ROOT for testing
export PROJECT_ROOT="${TEST_DIR}"

# Test hash generation (should not fail even if no lock files exist)
hash=$(get_deps_hash || echo "FAILED")
if [[ "$hash" != "FAILED" && -n "$hash" ]]; then
    echo "✅ PASS: Dependency hash generation"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: Dependency hash generation"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# Test 8: Dependency cache validation
# Cache should not exist initially
if ! is_deps_validated_cached; then
    echo "✅ PASS: Initial dependency cache miss"
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
else
    echo "❌ FAIL: Initial dependency cache should not exist"
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
fi

# Test 9: Non-docs scenario (should not trigger fast track)
echo ""
echo "--- Test Suite 5: Non-Docs Scenarios ---"
export MOCK_CODE_MODIFIED=5
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=0
export MOCK_SCRIPT_MODIFIED=0

assert_false "is_docs_only_change" "Non-docs scenario should not be detected as docs-only"

# Test 10: Mixed changes (docs + code)
export MOCK_CODE_MODIFIED=2
export MOCK_TEST_MODIFIED=0
export MOCK_DOCS_MODIFIED=3
export MOCK_SCRIPT_MODIFIED=0

assert_false "is_docs_only_change" "Mixed changes (docs+code) should not be docs-only"

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
