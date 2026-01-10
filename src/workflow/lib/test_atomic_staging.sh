#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test: Atomic Staging in Step 11
# Purpose: Verify that Step 11 always maintains consistent git state
# Version: 1.0.0
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_PASSED=0
TEST_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() {
    echo -e "${YELLOW}TEST:${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((TEST_PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((TEST_FAILED++))
}

# Test 1: Detect mixed staged/unstaged files
test_mixed_state_detection() {
    print_test "Mixed state detection"
    
    local test_output=$(git status --porcelain | grep -E "^(MM|AM)")
    
    if [[ -n "$test_output" ]]; then
        print_fail "Mixed state detected - atomic staging needed"
        echo "$test_output"
        return 1
    else
        print_pass "No mixed state detected"
        return 0
    fi
}

# Test 2: Verify git add -A behavior
test_atomic_staging_command() {
    print_test "Atomic staging command (git add -A)"
    
    # Check if command exists and is correct in step_11
    if grep -q "git add -A" "$SCRIPT_DIR/../steps/step_11_git.sh"; then
        print_pass "Atomic staging command present"
        return 0
    else
        print_fail "git add -A not found in step_11_git.sh"
        return 1
    fi
}

# Test 3: Verify mixed state reset logic
test_mixed_state_reset() {
    print_test "Mixed state reset logic"
    
    # Check for reset logic in step_11
    if grep -q "git reset HEAD" "$SCRIPT_DIR/../steps/step_11_git.sh"; then
        print_pass "Mixed state reset logic present"
        return 0
    else
        print_fail "Mixed state reset not found"
        return 1
    fi
}

# Test 4: Verify atomic staging verification
test_atomic_verification() {
    print_test "Post-staging verification"
    
    # Check for verification logic
    if grep -q "verify_mixed_state" "$SCRIPT_DIR/../steps/step_11_git.sh"; then
        print_pass "Atomic staging verification present"
        return 0
    else
        print_fail "Verification logic not found"
        return 1
    fi
}

# Test 5: Current repository state
test_current_git_state() {
    print_test "Current repository git state"
    
    # Get counts
    local staged_count=$(git diff --cached --name-only | wc -l)
    local unstaged_count=$(git diff --name-only | wc -l)
    local mixed_count=$(git status --porcelain | grep -E "^(MM|AM)" | wc -l)
    
    echo "  Staged: $staged_count, Unstaged: $unstaged_count, Mixed: $mixed_count"
    
    if [[ $mixed_count -eq 0 ]]; then
        print_pass "Repository state is atomic (no mixed files)"
        return 0
    else
        print_fail "Repository has $mixed_count mixed-state files"
        return 1
    fi
}

# Main test execution
main() {
    echo "=================================="
    echo "Atomic Staging Test Suite"
    echo "=================================="
    echo ""
    
    test_mixed_state_detection || true
    test_atomic_staging_command || true
    test_mixed_state_reset || true
    test_atomic_verification || true
    test_current_git_state || true
    
    echo ""
    echo "=================================="
    echo "Test Results"
    echo "=================================="
    echo -e "${GREEN}Passed: $TEST_PASSED${NC}"
    echo -e "${RED}Failed: $TEST_FAILED${NC}"
    
    if [[ $TEST_FAILED -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}✓ All tests passed${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

main "$@"
