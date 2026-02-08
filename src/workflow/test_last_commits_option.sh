#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Script: --last-commits Option
# Purpose: Validate new --last-commits command-line option
# Part of: Tests & Documentation Workflow Automation v3.3.0
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_SCRIPT="${SCRIPT_DIR}/execute_tests_docs_workflow.sh"

# Test helper functions
print_test() {
    echo ""
    echo "========================================"
    echo "TEST: $1"
    echo "========================================"
}

assert_success() {
    ((TESTS_RUN++))
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ PASS${NC}: $1"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $1"
        ((TESTS_FAILED++))
    fi
}

assert_failure() {
    ((TESTS_RUN++))
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✅ PASS${NC}: $1"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $1"
        ((TESTS_FAILED++))
    fi
}

assert_contains() {
    ((TESTS_RUN++))
    local haystack="$1"
    local needle="$2"
    local description="$3"
    
    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}✅ PASS${NC}: $description"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $description"
        echo "  Expected to find: '$needle'"
        echo "  In output: '$haystack'"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ==============================================================================
# TEST 1: Help Text Contains --last-commits
# ==============================================================================
print_test "Help text includes --last-commits option"

help_output=$("${WORKFLOW_SCRIPT}" --help 2>&1 || true)
assert_contains "$help_output" "--last-commits" "Help text shows --last-commits option"

# ==============================================================================
# TEST 2: Argument Parsing - Valid Integer
# ==============================================================================
print_test "Parse valid integer argument"

# Source the argument parser
source "${SCRIPT_DIR}/lib/argument_parser.sh"
source "${SCRIPT_DIR}/lib/color_codes.sh" 2>/dev/null || true

# Mock print functions if not available
if ! command -v print_error &>/dev/null; then
    print_error() { echo "ERROR: $*" >&2; }
    print_info() { echo "INFO: $*"; }
fi

# Test parsing --last-commits 5
LAST_COMMITS=""
if parse_workflow_arguments --last-commits 5 2>/dev/null; then
    if [[ "$LAST_COMMITS" == "5" ]]; then
        ((TESTS_RUN++))
        echo -e "${GREEN}✅ PASS${NC}: Parsed --last-commits 5 correctly"
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        echo -e "${RED}❌ FAIL${NC}: Expected LAST_COMMITS=5, got: $LAST_COMMITS"
        ((TESTS_FAILED++))
    fi
fi

# ==============================================================================
# TEST 3: Argument Parsing - Invalid Values
# ==============================================================================
print_test "Reject invalid argument values"

# Test zero (should fail)
LAST_COMMITS=""
output=$("${WORKFLOW_SCRIPT}" --last-commits 0 2>&1 || true)
if echo "$output" | grep -q "must be a positive integer"; then
    ((TESTS_RUN++))
    echo -e "${GREEN}✅ PASS${NC}: Rejected --last-commits 0"
    ((TESTS_PASSED++))
else
    ((TESTS_RUN++))
    echo -e "${RED}❌ FAIL${NC}: Should reject --last-commits 0"
    ((TESTS_FAILED++))
fi

# Test negative (should fail)
output=$("${WORKFLOW_SCRIPT}" --last-commits -5 2>&1 || true)
if echo "$output" | grep -q "must be a positive integer"; then
    ((TESTS_RUN++))
    echo -e "${GREEN}✅ PASS${NC}: Rejected --last-commits -5"
    ((TESTS_PASSED++))
else
    ((TESTS_RUN++))
    echo -e "${RED}❌ FAIL${NC}: Should reject --last-commits -5"
    ((TESTS_FAILED++))
fi

# Test non-integer (should fail)
output=$("${WORKFLOW_SCRIPT}" --last-commits abc 2>&1 || true)
if echo "$output" | grep -q "must be a positive integer"; then
    ((TESTS_RUN++))
    echo -e "${GREEN}✅ PASS${NC}: Rejected --last-commits abc"
    ((TESTS_PASSED++))
else
    ((TESTS_RUN++))
    echo -e "${RED}❌ FAIL${NC}: Should reject --last-commits abc"
    ((TESTS_FAILED++))
fi

# ==============================================================================
# TEST 4: Commit Count Validation
# ==============================================================================
print_test "Validate commit count in repository"

# Source change detection module
source "${SCRIPT_DIR}/lib/change_detection.sh"

# Get actual commit count
total_commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
echo "Repository has ${total_commits} commits"

# Test with excessive count (should fail if we have < 10000 commits)
if [[ $total_commits -lt 10000 ]]; then
    LAST_COMMITS="10000"
    export LAST_COMMITS
    
    if validate_commit_count 10000 2>&1 | grep -q "only ${total_commits} commits available"; then
        ((TESTS_RUN++))
        echo -e "${GREEN}✅ PASS${NC}: Detected excessive commit count"
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        echo -e "${RED}❌ FAIL${NC}: Should detect excessive commit count"
        ((TESTS_FAILED++))
    fi
    unset LAST_COMMITS
fi

# Test with valid count (should pass)
if [[ $total_commits -ge 5 ]]; then
    if validate_commit_count 5 2>/dev/null; then
        ((TESTS_RUN++))
        echo -e "${GREEN}✅ PASS${NC}: Accepted valid commit count (5)"
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        echo -e "${RED}❌ FAIL${NC}: Should accept valid commit count"
        ((TESTS_FAILED++))
    fi
fi

# ==============================================================================
# TEST 5: Baseline Calculation
# ==============================================================================
print_test "Calculate baseline from HEAD~N"

if [[ $total_commits -ge 5 ]]; then
    LAST_COMMITS="5"
    export LAST_COMMITS
    
    baseline=$(get_last_workflow_commit 2>&1)
    expected_baseline=$(git rev-parse HEAD~5 2>/dev/null)
    
    if [[ "$baseline" == "$expected_baseline" ]]; then
        ((TESTS_RUN++))
        echo -e "${GREEN}✅ PASS${NC}: Baseline correctly calculated as HEAD~5"
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        echo -e "${RED}❌ FAIL${NC}: Baseline mismatch"
        echo "  Expected: $expected_baseline"
        echo "  Got: $baseline"
        ((TESTS_FAILED++))
    fi
    
    unset LAST_COMMITS
fi

# ==============================================================================
# TEST 6: Dry Run Integration Test
# ==============================================================================
print_test "Integration test with --dry-run"

if [[ $total_commits -ge 3 ]]; then
    echo "Running: ${WORKFLOW_SCRIPT} --last-commits 3 --dry-run --steps 0"
    
    output=$("${WORKFLOW_SCRIPT}" --last-commits 3 --dry-run --steps 0 2>&1 || true)
    
    # Check for expected messages
    assert_contains "$output" "Analyzing last 3 commits" "Shows analyzing message"
    assert_contains "$output" "HEAD~3" "References HEAD~3 baseline"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo "========================================"
echo "TEST SUMMARY"
echo "========================================"
echo "Total Tests: ${TESTS_RUN}"
echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
else
    echo "Failed: ${TESTS_FAILED}"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
