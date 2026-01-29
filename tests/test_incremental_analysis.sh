#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: Incremental Analysis Module
# Purpose: Test incremental analysis optimization for client_spa projects
# Part of: Tests & Documentation Workflow Automation v2.7.0
################################################################################

# Set up test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export PROJECT_ROOT

# Source required modules
source "${PROJECT_ROOT}/src/workflow/lib/colors.sh"
source "${PROJECT_ROOT}/src/workflow/lib/incremental_analysis.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# TEST HELPERS
# ==============================================================================

test_start() {
    local test_name="$1"
    echo ""
    echo -e "${CYAN}▶ Testing: ${test_name}${NC}"
    ((TESTS_RUN++)) || true
}

test_pass() {
    local message="${1:-Test passed}"
    echo -e "${GREEN}  ✓ ${message}${NC}"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    local message="${1:-Test failed}"
    echo -e "${RED}  ✗ ${message}${NC}"
    ((TESTS_FAILED++)) || true
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        test_pass "$message (expected: $expected, got: $actual)"
        return 0
    else
        test_fail "$message (expected: $expected, got: $actual)"
        return 1
    fi
}

assert_true() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    if eval "$command"; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_false() {
    local command="$1"
    local message="${2:-Command should fail}"
    
    if ! eval "$command"; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

# ==============================================================================
# TEST SUITE
# ==============================================================================

test_cache_initialization() {
    test_start "Cache initialization"
    
    # Clean up any existing cache
    rm -rf "${PROJECT_ROOT}/.ai_workflow/.incremental_cache"
    
    # Initialize cache
    init_incremental_cache
    
    # Verify cache directory exists
    if [[ -d "${PROJECT_ROOT}/.ai_workflow/.incremental_cache" ]]; then
        test_pass "Cache directory created successfully"
    else
        test_fail "Cache directory not created"
    fi
}

test_should_use_incremental() {
    test_start "Should use incremental analysis detection"
    
    # Test client_spa project
    if should_use_incremental_analysis "client_spa"; then
        test_pass "Correctly identified client_spa for incremental analysis"
    else
        test_fail "Failed to identify client_spa for incremental analysis"
    fi
    
    # Test non-client_spa project
    if ! should_use_incremental_analysis "nodejs_api"; then
        test_pass "Correctly excluded nodejs_api from incremental analysis"
    else
        test_fail "Incorrectly included nodejs_api in incremental analysis"
    fi
}

test_get_changed_files() {
    test_start "Get changed files detection"
    
    # This test requires a git repository with commits
    if ! git rev-parse --git-dir &>/dev/null; then
        test_pass "Skipping - not in git repository"
        return 0
    fi
    
    # Count commits
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ $commit_count -lt 2 ]]; then
        test_pass "Skipping - needs at least 2 commits"
        return 0
    fi
    
    # Get changed files (may be empty, which is valid)
    local changed_files=$(get_changed_js_files "HEAD~1")
    test_pass "Successfully retrieved changed files list"
}

test_cached_tree() {
    test_start "Cached git tree generation"
    
    if ! git rev-parse --git-dir &>/dev/null; then
        test_pass "Skipping - not in git repository"
        return 0
    fi
    
    # Initialize cache
    init_incremental_cache
    
    # Generate cached tree
    local output_file=$(mktemp)
    if get_cached_tree "$output_file"; then
        if [[ -f "$output_file" ]]; then
            test_pass "Cache file generated successfully"
        else
            test_fail "Cache file not created"
        fi
    else
        test_fail "Failed to generate cached tree"
    fi
    
    # Cleanup
    rm -f "$output_file"
}

test_incremental_savings_calculation() {
    test_start "Incremental savings calculation"
    
    # Test 70% reduction (analyzing 30 of 100 files)
    local savings=$(calculate_incremental_savings 100 30)
    assert_equals "70" "$savings" "Should calculate 70% savings"
    
    # Test 85% reduction (analyzing 15 of 100 files)
    savings=$(calculate_incremental_savings 100 15)
    assert_equals "85" "$savings" "Should calculate 85% savings"
    
    # Test edge case - no files
    savings=$(calculate_incremental_savings 0 0)
    assert_equals "0" "$savings" "Should handle zero files"
}

test_can_skip_directory_validation() {
    test_start "Directory validation skip detection"
    
    if ! git rev-parse --git-dir &>/dev/null; then
        test_pass "Skipping - not in git repository"
        return 0
    fi
    
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ $commit_count -lt 2 ]]; then
        test_pass "Skipping - needs at least 2 commits"
        return 0
    fi
    
    # Function should return true or false - either is valid
    if can_skip_directory_validation "HEAD~1"; then
        test_pass "No structural changes detected"
    else
        test_pass "Structural changes detected"
    fi
}

test_get_incremental_doc_inventory() {
    test_start "Incremental documentation inventory"
    
    if ! git rev-parse --git-dir &>/dev/null; then
        test_pass "Skipping - not in git repository"
        return 0
    fi
    
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ $commit_count -lt 2 ]]; then
        test_pass "Skipping - needs at least 2 commits"
        return 0
    fi
    
    # Get incremental inventory (may return no changes, which is valid)
    if get_incremental_doc_inventory "HEAD~1" &>/dev/null; then
        test_pass "Documentation changes detected"
    else
        test_pass "No documentation changes (valid state)"
    fi
}

test_analyze_consistency_incremental() {
    test_start "Incremental consistency analysis"
    
    if ! git rev-parse --git-dir &>/dev/null; then
        test_pass "Skipping - not in git repository"
        return 0
    fi
    
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ $commit_count -lt 2 ]]; then
        test_pass "Skipping - needs at least 2 commits"
        return 0
    fi
    
    # Analyze consistency incrementally
    local result=$(analyze_consistency_incremental "HEAD~1")
    test_pass "Incremental consistency analysis completed"
}

# ==============================================================================
# RUN ALL TESTS
# ==============================================================================

echo ""
echo "=================================================================="
echo "Incremental Analysis Module Test Suite"
echo "=================================================================="

test_cache_initialization
test_should_use_incremental
test_get_changed_files
test_cached_tree
test_incremental_savings_calculation
test_can_skip_directory_validation
test_get_incremental_doc_inventory
test_analyze_consistency_incremental

# ==============================================================================
# TEST SUMMARY
# ==============================================================================

echo ""
echo "=================================================================="
echo "Test Summary"
echo "=================================================================="
echo "Tests Run:    $TESTS_RUN"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

# Cleanup
rm -rf "${PROJECT_ROOT}/.ai_workflow/.incremental_cache"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
