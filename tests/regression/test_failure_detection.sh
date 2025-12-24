#!/bin/bash
set -euo pipefail

################################################################################
# Regression Test: Test Failure Detection
# Purpose: Verify that test failures are properly detected and reported
# Version: 1.0.0
# Created: 2025-12-24
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_NAME="Test Regression Detection"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test utilities
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    export WORKFLOW_HOME="$(mktemp -d)"
    mkdir -p "${WORKFLOW_HOME}/src/workflow/lib"
    
    # Source test validation module
    source "${SCRIPT_DIR}/../../src/workflow/lib/test_validation.sh"
}

# Cleanup
cleanup_test_env() {
    if [[ -n "${WORKFLOW_HOME:-}" ]] && [[ -d "${WORKFLOW_HOME}" ]]; then
        rm -rf "${WORKFLOW_HOME}"
    fi
}

# Test validation functions
test_validation_functions() {
    echo ""
    echo "=========================================="
    echo "Test Suite: Result Validation"
    echo "=========================================="
    
    if validate_test_results 0 10 10 0; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: All tests passed validates correctly"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: All tests passed should validate"
    fi
    ((TESTS_TOTAL++))
    
    if ! validate_test_results 1 10 8 2; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Non-zero exit code detected as failure"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Non-zero exit should fail validation"
    fi
    ((TESTS_TOTAL++))
    
    if ! validate_test_results 0 10 8 2; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: Failed tests detected even with exit 0"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: Failed tests should be detected"
    fi
    ((TESTS_TOTAL++))
}

# Test step7 scenario
test_step7_scenario() {
    echo ""
    echo "=========================================="
    echo "Test Suite: Step7 Integration Scenario"
    echo "=========================================="
    
    local mock_status=""
    update_workflow_status() {
        mock_status="$2"
    }
    export -f update_workflow_status
    
    validate_and_update_test_status "7" 0 10 10 0
    assert_equals "✅" "$mock_status" "Status is ✅ when all tests pass"
    
    mock_status=""
    validate_and_update_test_status "7" 1 10 8 2
    assert_equals "❌" "$mock_status" "Status is ❌ when tests fail (exit 1)"
    
    echo -e "\n${YELLOW}CRITICAL: Testing regression bug scenario${NC}"
    mock_status=""
    validate_and_update_test_status "7" 0 37 30 7
    assert_equals "❌" "$mock_status" "Status is ❌ when failures exist (even with exit 0)"
    
    if [[ "$mock_status" == "❌" ]]; then
        echo -e "${GREEN}✓${NC} REGRESSION PREVENTED: Failures detected despite exit code 0"
    else
        echo -e "${RED}✗${NC} REGRESSION DETECTED: Silent failure would be marked as success"
    fi
}

# Main
main() {
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║          Test Regression Detection - Validation Suite               ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    
    setup_test_env
    test_validation_functions
    test_step7_scenario
    cleanup_test_env
    
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests:  $TESTS_TOTAL"
    echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ ALL TESTS PASSED - Regression Fix Verified${NC}"
        return 0
    else
        echo -e "\n${RED}✗ SOME TESTS FAILED - Review Required${NC}"
        return 1
    fi
}

main "$@"
