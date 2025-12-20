#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Unit Tests for lib/utils.sh
# Purpose: Test common utility functions
# Part of: Technical Debt Reduction Phase 1
################################################################################

# Test framework setup
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Setup test environment
setup_test() {
    TEST_COUNT=$((TEST_COUNT + 1))
    
    # Create temp directory for test artifacts
    TEST_TEMP_DIR=$(mktemp -d)
    export TEST_TEMP_DIR
    
    # Mock global variables that utils.sh expects
    export DRY_RUN=false
    export AUTO_MODE=false
    export VERBOSE=false
    export BACKLOG_RUN_DIR="${TEST_TEMP_DIR}/backlog"
    export SUMMARIES_RUN_DIR="${TEST_TEMP_DIR}/summaries"
    export WORKFLOW_RUN_ID="test_run_$(date +%s)"
    export SCRIPT_NAME="Test Script"
    export SCRIPT_VERSION="1.0.0"
    export TOTAL_STEPS=5
    
    # Color codes for utils.sh
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export CYAN='\033[0;36m'
    export MAGENTA='\033[0;35m'
    export NC='\033[0m'
    
    # Workflow status tracking
    declare -gA WORKFLOW_STATUS
    export WORKFLOW_STATUS
    
    # Temp files array
    declare -ga TEMP_FILES
    export TEMP_FILES
}

# Teardown test environment
teardown_test() {
    if [[ -d "${TEST_TEMP_DIR:-}" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Assert functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Expected: '$expected'"
        echo -e "  Actual:   '$actual'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain: $needle}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} $message"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Haystack: '$haystack'"
        echo -e "  Needle:   '$needle'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Source the module under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/src/workflow"
source "${SCRIPT_DIR}/lib/utils.sh"

# ==============================================================================
# TEST CASES
# ==============================================================================

test_save_step_issues() {
    echo -e "\n${YELLOW}Test: save_step_issues${NC}"
    setup_test
    
    # Test saving issues to backlog
    local step_num="1"
    local step_name="Test Step"
    local issues="Issue 1\nIssue 2\nIssue 3"
    
    save_step_issues "$step_num" "$step_name" "$issues"
    
    local expected_file="${BACKLOG_RUN_DIR}/step1_Test_Step.md"
    assert_file_exists "$expected_file" "Issue file created"
    
    if [[ -f "$expected_file" ]]; then
        local content=$(cat "$expected_file")
        assert_contains "$content" "Step 1: Test Step" "Header present"
        assert_contains "$content" "Issue 1" "Issue 1 present"
        assert_contains "$content" "Issue 2" "Issue 2 present"
    fi
    
    teardown_test
}

test_save_step_issues_dry_run() {
    echo -e "\n${YELLOW}Test: save_step_issues (dry-run mode)${NC}"
    setup_test
    export DRY_RUN=true
    
    save_step_issues "1" "Test Step" "Issues"
    
    local expected_file="${BACKLOG_RUN_DIR}/step1_Test_Step.md"
    if [[ ! -f "$expected_file" ]]; then
        echo -e "${GREEN}✓${NC} No file created in dry-run mode"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} File should not be created in dry-run mode"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    teardown_test
}

test_save_step_summary() {
    echo -e "\n${YELLOW}Test: save_step_summary${NC}"
    setup_test
    
    local step_num="2"
    local step_name="Summary Test"
    local summary="All checks passed successfully"
    local status="✅"
    
    save_step_summary "$step_num" "$step_name" "$summary" "$status"
    
    local expected_file="${SUMMARIES_RUN_DIR}/step2_Summary_Test_summary.md"
    assert_file_exists "$expected_file" "Summary file created"
    
    if [[ -f "$expected_file" ]]; then
        local content=$(cat "$expected_file")
        assert_contains "$content" "Step 2: Summary Test" "Header present"
        assert_contains "$content" "✅" "Status present"
        assert_contains "$content" "All checks passed" "Summary content present"
    fi
    
    teardown_test
}

test_update_workflow_status() {
    echo -e "\n${YELLOW}Test: update_workflow_status${NC}"
    setup_test
    
    update_workflow_status "step_1" "✅"
    update_workflow_status "step_2" "⚠️"
    update_workflow_status "step_3" "❌"
    
    assert_equals "✅" "${WORKFLOW_STATUS[step_1]}" "Step 1 status set"
    assert_equals "⚠️" "${WORKFLOW_STATUS[step_2]}" "Step 2 status set"
    assert_equals "❌" "${WORKFLOW_STATUS[step_3]}" "Step 3 status set"
    
    teardown_test
}

test_cleanup_temp_files() {
    echo -e "\n${YELLOW}Test: cleanup${NC}"
    setup_test
    
    # Create temp files
    local temp1="${TEST_TEMP_DIR}/temp1.txt"
    local temp2="${TEST_TEMP_DIR}/temp2.txt"
    touch "$temp1" "$temp2"
    
    TEMP_FILES=("$temp1" "$temp2")
    
    # Run cleanup in subshell to avoid exit
    (cleanup) 2>/dev/null || true
    
    if [[ ! -f "$temp1" ]] && [[ ! -f "$temp2" ]]; then
        echo -e "${GREEN}✓${NC} Temp files cleaned up"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} Temp files not cleaned up"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    teardown_test
}

test_print_functions() {
    echo -e "\n${YELLOW}Test: print functions${NC}"
    setup_test
    
    # Test that print functions execute without errors
    local output
    
    output=$(print_success "Success message" 2>&1)
    assert_contains "$output" "Success message" "print_success works"
    
    output=$(print_error "Error message" 2>&1)
    assert_contains "$output" "Error message" "print_error works"
    
    output=$(print_warning "Warning message" 2>&1)
    assert_contains "$output" "Warning message" "print_warning works"
    
    output=$(print_info "Info message" 2>&1)
    assert_contains "$output" "Info message" "print_info works"
    
    output=$(print_step "5" "Step Name" 2>&1)
    assert_contains "$output" "Step 5" "print_step works"
    assert_contains "$output" "Step Name" "print_step includes name"
    
    teardown_test
}

test_confirm_action_auto_mode() {
    echo -e "\n${YELLOW}Test: confirm_action (auto mode)${NC}"
    setup_test
    export AUTO_MODE=true
    
    # In auto mode, should return 0 immediately
    if confirm_action "Test prompt"; then
        echo -e "${GREEN}✓${NC} Auto mode returns true"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} Auto mode should return true"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    teardown_test
}

# ==============================================================================
# TEST RUNNER
# ==============================================================================

run_all_tests() {
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  Unit Tests for lib/utils.sh${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    
    test_save_step_issues
    test_save_step_issues_dry_run
    test_save_step_summary
    test_update_workflow_status
    test_cleanup_temp_files
    test_print_functions
    test_confirm_action_auto_mode
    
    echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  Test Summary${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "Total Tests:  $TEST_COUNT"
    echo -e "${GREEN}Passed:       $PASS_COUNT${NC}"
    if [[ $FAIL_COUNT -gt 0 ]]; then
        echo -e "${RED}Failed:       $FAIL_COUNT${NC}"
        return 1
    else
        echo -e "Failed:       $FAIL_COUNT"
        echo -e "\n${GREEN}✅ All tests passed!${NC}"
        return 0
    fi
}

# Run tests
run_all_tests
