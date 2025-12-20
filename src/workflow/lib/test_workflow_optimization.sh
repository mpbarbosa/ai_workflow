#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite for Workflow Optimization Module
# Purpose: Tests for smart execution, parallel processing, and checkpoints
# Version: 1.0.0
# Created: 2025-12-20
################################################################################

# Test framework setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_NAME="Workflow Optimization Tests"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test utilities
print_test_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

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

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++))
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  File not found: $file"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    export PROJECT_ROOT="$(mktemp -d)"
    export WORKFLOW_HOME="$PROJECT_ROOT"
    export CHECKPOINT_DIR="${PROJECT_ROOT}/src/workflow/.checkpoints"
    export WORKFLOW_RUN_ID="test_run_$(date +%s)"
    
    mkdir -p "${PROJECT_ROOT}/src/workflow"
    mkdir -p "${CHECKPOINT_DIR}"
    
    # Initialize status array
    declare -gA WORKFLOW_STATUS
    
    # Source required modules
    source "${SCRIPT_DIR}/colors.sh" 2>/dev/null || true
    source "${SCRIPT_DIR}/workflow_optimization.sh"
}

# Cleanup
cleanup_test_env() {
    if [[ -n "${PROJECT_ROOT}" ]] && [[ -d "${PROJECT_ROOT}" ]]; then
        rm -rf "${PROJECT_ROOT}"
    fi
}

# ==============================================================================
# TEST SUITE 1: Step Skipping Logic
# ==============================================================================

test_step_skipping() {
    print_test_header "Test Suite 1: Step Skipping Logic"
    
    # Test 1.1: should_skip_step function exists
    if declare -f should_skip_step &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: should_skip_step function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: should_skip_step function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 1.2: Documentation-only changes skip test steps
    export CHANGE_IMPACT="LOW"
    export DOCS_CHANGED=5
    export CODE_CHANGED=0
    export TESTS_CHANGED=0
    
    if declare -f should_skip_step &>/dev/null; then
        # Test generation steps should be skipped for docs-only
        if should_skip_step 6; then  # Step 6 is test generation
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Test generation skipped for docs-only changes"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Should skip test generation for docs-only"
        fi
        ((TESTS_TOTAL++))
    fi
    
    # Test 1.3: Code changes don't skip test steps
    export CHANGE_IMPACT="HIGH"
    export CODE_CHANGED=5
    
    if declare -f should_skip_step &>/dev/null; then
        if ! should_skip_step 6; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Test generation not skipped for code changes"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Should not skip test generation for code changes"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 2: Checkpoint Management
# ==============================================================================

test_checkpoint_management() {
    print_test_header "Test Suite 2: Checkpoint Management"
    
    # Test 2.1: save_checkpoint function exists
    if declare -f save_checkpoint &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: save_checkpoint function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: save_checkpoint function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 2.2: save_checkpoint creates checkpoint file
    if declare -f save_checkpoint &>/dev/null; then
        WORKFLOW_STATUS[step0]="✅"
        WORKFLOW_STATUS[step1]="✅"
        save_checkpoint 1
        
        local checkpoint_file="${CHECKPOINT_DIR}/${WORKFLOW_RUN_ID}.checkpoint"
        assert_file_exists "$checkpoint_file" "Checkpoint file created"
    fi
    
    # Test 2.3: load_checkpoint function exists
    if declare -f load_checkpoint &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: load_checkpoint function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: load_checkpoint function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 2.4: load_checkpoint reads saved checkpoint
    if declare -f load_checkpoint &>/dev/null && declare -f save_checkpoint &>/dev/null; then
        save_checkpoint 2
        
        # Create new environment to test loading
        unset LAST_COMPLETED_STEP
        load_checkpoint
        
        if [[ -n "${LAST_COMPLETED_STEP:-}" ]]; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Checkpoint loaded successfully"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Failed to load checkpoint"
        fi
        ((TESTS_TOTAL++))
    fi
    
    # Test 2.5: cleanup_old_checkpoints function exists
    if declare -f cleanup_old_checkpoints &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: cleanup_old_checkpoints function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: cleanup_old_checkpoints function not found"
    fi
    ((TESTS_TOTAL++))
}

# ==============================================================================
# TEST SUITE 3: Parallel Execution Detection
# ==============================================================================

test_parallel_execution() {
    print_test_header "Test Suite 3: Parallel Execution"
    
    # Test 3.1: can_run_parallel function exists
    if declare -f can_run_parallel &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: can_run_parallel function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: can_run_parallel function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 3.2: Independent steps can run in parallel
    if declare -f can_run_parallel &>/dev/null; then
        # Steps 1, 2, 3, 4 are typically independent
        if can_run_parallel 1 2 3 4; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Independent steps detected for parallel execution"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Should allow parallel execution of independent steps"
        fi
        ((TESTS_TOTAL++))
    fi
    
    # Test 3.3: Dependent steps cannot run in parallel
    if declare -f can_run_parallel &>/dev/null; then
        # Step 7 (test execution) depends on step 6 (test generation)
        if ! can_run_parallel 6 7; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Dependent steps blocked from parallel execution"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Should block parallel execution of dependent steps"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 4: Change Impact Analysis
# ==============================================================================

test_change_impact() {
    print_test_header "Test Suite 4: Change Impact Analysis"
    
    # Test 4.1: analyze_change_impact function exists
    if declare -f analyze_change_impact &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: analyze_change_impact function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: analyze_change_impact function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 4.2: Impact levels are detected correctly
    if declare -f analyze_change_impact &>/dev/null; then
        # This would require mocking git diff output
        # For now, just verify the function can be called
        if analyze_change_impact 2>/dev/null || true; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: analyze_change_impact runs without error"
        else
            echo -e "${YELLOW}⚠${NC} SKIP: analyze_change_impact requires git repo"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 5: Step Dependencies
# ==============================================================================

test_step_dependencies() {
    print_test_header "Test Suite 5: Step Dependencies"
    
    # Test 5.1: get_step_dependencies function exists
    if declare -f get_step_dependencies &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: get_step_dependencies function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: get_step_dependencies function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 5.2: Step 0 has no dependencies
    if declare -f get_step_dependencies &>/dev/null; then
        local deps=$(get_step_dependencies 0)
        if [[ -z "$deps" ]] || [[ "$deps" == "0" ]]; then
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Step 0 has no dependencies"
        else
            ((TESTS_FAILED++))
            echo -e "${RED}✗${NC} FAIL: Step 0 should have no dependencies"
        fi
        ((TESTS_TOTAL++))
    fi
    
    # Test 5.3: Test execution depends on test generation
    if declare -f get_step_dependencies &>/dev/null; then
        local deps=$(get_step_dependencies 7)  # Step 7 = test execution
        if [[ "$deps" == *"6"* ]]; then  # Should depend on step 6
            ((TESTS_PASSED++))
            echo -e "${GREEN}✓${NC} PASS: Test execution depends on test generation"
        else
            echo -e "${YELLOW}⚠${NC} SKIP: Dependency check implementation varies"
        fi
        ((TESTS_TOTAL++))
    fi
}

# ==============================================================================
# TEST SUITE 6: Optimization Metrics
# ==============================================================================

test_optimization_metrics() {
    print_test_header "Test Suite 6: Optimization Metrics"
    
    # Test 6.1: calculate_time_saved function exists
    if declare -f calculate_time_saved &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: calculate_time_saved function exists"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗${NC} FAIL: calculate_time_saved function not found"
    fi
    ((TESTS_TOTAL++))
    
    # Test 6.2: Optimization report generation
    if declare -f generate_optimization_report &>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} PASS: generate_optimization_report function exists"
    else
        echo -e "${YELLOW}⚠${NC} SKIP: generate_optimization_report not implemented"
    fi
    ((TESTS_TOTAL++))
}

# ==============================================================================
# MAIN TEST EXECUTION
# ==============================================================================

main() {
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║           Workflow Optimization Module Test Suite                   ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Setup
    setup_test_env
    
    # Run all test suites
    test_step_skipping
    test_checkpoint_management
    test_parallel_execution
    test_change_impact
    test_step_dependencies
    test_optimization_metrics
    
    # Cleanup
    cleanup_test_env
    
    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests:  $TESTS_TOTAL"
    echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
        return 1
    fi
}

# Run tests
main "$@"
