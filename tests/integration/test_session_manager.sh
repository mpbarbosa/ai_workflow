#!/bin/bash
################################################################################
# Test Suite for Bash Session Management Module
# Purpose: Validate session management, timeouts, and cleanup functionality
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Set non-interactive mode to prevent blocking on stdin
export AUTO_MODE=true

# Source the module to test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${SCRIPT_DIR}/../../src/workflow/lib"
source "${WORKFLOW_LIB_DIR}/colors.sh"
source "${WORKFLOW_LIB_DIR}/config.sh"
source "${WORKFLOW_LIB_DIR}/utils.sh"
source "${WORKFLOW_LIB_DIR}/session_manager.sh"

# Track test sessions and log files for cleanup
TEST_SESSIONS=()
TEST_LOG_FILES=()

# Cleanup handler
cleanup_test_files() {
    # Clean up any log files created during tests
    for log_file in "${TEST_LOG_FILES[@]}"; do
        [[ -f "$log_file" ]] && rm -f "$log_file"
    done
    # Clean up any session files
    rm -f /tmp/workflow_*.log 2>/dev/null || true
}

# Register cleanup on exit
trap cleanup_test_files EXIT

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
declare -a FAILED_TESTS

# ==============================================================================
# TEST FRAMEWORK FUNCTIONS
# ==============================================================================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++)) || true
    
    if [[ "$expected" == "$actual" ]]; then
        ((TESTS_PASSED++)) || true
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        return 0
    else
        ((TESTS_FAILED++)) || true
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Expected: ${YELLOW}$expected${NC}"
        echo -e "   Actual:   ${YELLOW}$actual${NC}"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"
    
    ((TESTS_RUN++)) || true
    
    if eval "$condition"; then
        ((TESTS_PASSED++)) || true
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        return 0
    else
        ((TESTS_FAILED++)) || true
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Condition failed: ${YELLOW}$condition${NC}"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_RUN++)) || true
    
    if [[ "$haystack" == *"$needle"* ]]; then
        ((TESTS_PASSED++)) || true
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        return 0
    else
        ((TESTS_FAILED++)) || true
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   Haystack: ${YELLOW}$haystack${NC}"
        echo -e "   Needle:   ${YELLOW}$needle${NC}"
        return 1
    fi
}

# ==============================================================================
# SESSION ID GENERATION TESTS
# ==============================================================================

test_generate_session_id_format() {
    local session_id
    session_id=$(generate_session_id "07" "test_exec")
    
    # Check that it contains expected components
    assert_contains "$session_id" "step07" "Session ID contains step number"
    assert_contains "$session_id" "test_exec" "Session ID contains operation name"
    
    # Check format with regex
    if [[ "$session_id" =~ ^step[0-9]+_[a-z_]+_[0-9]{8}_[0-9]{6}_[a-z0-9]{6}$ ]]; then
        assert_true "true" "Session ID matches expected format"
    else
        assert_true "false" "Session ID matches expected format"
    fi
}

test_generate_unique_session_ids() {
    local id1
    local id2
    
    id1=$(generate_session_id "01" "test")
    sleep 0.1
    id2=$(generate_session_id "01" "test")
    
    if [[ "$id1" != "$id2" ]]; then
        assert_true "true" "Generated session IDs are unique"
    else
        assert_true "false" "Generated session IDs are unique"
    fi
}

# ==============================================================================
# SESSION REGISTRATION TESTS
# ==============================================================================

test_register_and_unregister_session() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local test_id="test_session_001"
    
    register_session "$test_id" "Test session"
    
    # Check registration
    assert_true "[[ -v ACTIVE_SESSIONS['$test_id'] ]]" "Session registered in ACTIVE_SESSIONS"
    
    local found_in_queue=false
    for sid in "${SESSION_CLEANUP_QUEUE[@]}"; do
        if [[ "$sid" == "$test_id" ]]; then
            found_in_queue=true
            break
        fi
    done
    
    if [[ "$found_in_queue" == "true" ]]; then
        assert_true "true" "Session added to cleanup queue"
    else
        assert_true "false" "Session added to cleanup queue"
    fi
    
    # Test unregister
    unregister_session "$test_id"
    
    assert_true "[[ ! -v ACTIVE_SESSIONS['$test_id'] ]]" "Session unregistered from ACTIVE_SESSIONS"
    
    found_in_queue=false
    for sid in "${SESSION_CLEANUP_QUEUE[@]}"; do
        if [[ "$sid" == "$test_id" ]]; then
            found_in_queue=true
            break
        fi
    done
    
    if [[ "$found_in_queue" == "false" ]]; then
        assert_true "true" "Session removed from cleanup queue"
    else
        assert_true "false" "Session removed from cleanup queue"
    fi
}

# ==============================================================================
# COMMAND EXECUTION TESTS
# ==============================================================================

test_execute_with_session_sync_success() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local exit_code
    execute_with_session "99" "test_sync" "echo 'test'" 5 "sync" > /dev/null 2>&1
    exit_code=$?
    
    assert_equals "0" "$exit_code" "Sync command returns 0 on success"
    
    # Session should be cleaned up immediately for sync mode
    assert_equals "0" "${#ACTIVE_SESSIONS[@]}" "Sync session cleaned up immediately"
}

test_execute_with_session_sync_failure() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local exit_code
    execute_with_session "99" "test_fail" "exit 1" 5 "sync" > /dev/null 2>&1
    exit_code=$?
    
    assert_equals "1" "$exit_code" "Sync command returns non-zero on failure"
}

test_execute_with_session_timeout() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local exit_code
    # Command that sleeps longer than timeout
    execute_with_session "99" "test_timeout" "sleep 10" 2 "sync" > /dev/null 2>&1
    exit_code=$?
    
    # Timeout command returns 124
    assert_equals "124" "$exit_code" "Timed out command returns 124"
}

test_execute_with_session_async() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local session_id
    session_id=$(generate_session_id "99" "test_async")
    
    # Start async command
    execute_with_session "99" "test_async" "sleep 2" 30 "async" > /dev/null 2>&1
    
    # Session should still be active
    local active_count=${#ACTIVE_SESSIONS[@]}
    if [[ $active_count -gt 0 ]]; then
        assert_true "true" "Async session remains active"
    else
        assert_true "false" "Async session remains active"
    fi
    
    # Cleanup
    cleanup_all_sessions > /dev/null 2>&1
}

# ==============================================================================
# TIMEOUT RECOMMENDATION TESTS
# ==============================================================================

test_get_recommended_timeout_npm_test() {
    local timeout
    timeout=$(get_recommended_timeout "npm_test")
    assert_equals "300" "$timeout" "npm_test timeout is 300 seconds"
}

test_get_recommended_timeout_npm_install() {
    local timeout
    timeout=$(get_recommended_timeout "npm_install")
    assert_equals "120" "$timeout" "npm_install timeout is 120 seconds"
}

test_get_recommended_timeout_git_operation() {
    local timeout
    timeout=$(get_recommended_timeout "git_operation")
    assert_equals "30" "$timeout" "git_operation timeout is 30 seconds"
}

test_get_recommended_timeout_default() {
    local timeout
    timeout=$(get_recommended_timeout "unknown_operation")
    assert_equals "30" "$timeout" "Unknown operation returns default 30 seconds"
}

# ==============================================================================
# CLEANUP TESTS
# ==============================================================================

test_cleanup_all_sessions() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    # Register multiple sessions
    register_session "test_session_1" "Test 1" > /dev/null 2>&1
    register_session "test_session_2" "Test 2" > /dev/null 2>&1
    register_session "test_session_3" "Test 3" > /dev/null 2>&1
    
    local initial_count=${#ACTIVE_SESSIONS[@]}
    assert_equals "3" "$initial_count" "Three sessions registered"
    
    # Cleanup all
    cleanup_all_sessions > /dev/null 2>&1
    
    local final_count=${#ACTIVE_SESSIONS[@]}
    assert_equals "0" "$final_count" "All sessions cleaned up"
    assert_equals "0" "${#SESSION_CLEANUP_QUEUE[@]}" "Cleanup queue empty"
}

# ==============================================================================
# HELPER FUNCTION TESTS
# ==============================================================================

test_execute_npm_command() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    # Mock npm command (just echo)
    local exit_code
    execute_npm_command "99" "test" "--version" > /dev/null 2>&1
    exit_code=$?
    
    # Should complete (even if npm not installed, session management works)
    if [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 127 ]]; then
        assert_true "true" "execute_npm_command runs without crashing"
    else
        assert_true "false" "execute_npm_command runs without crashing"
    fi
}

test_execute_git_command() {
    # Clear state
    ACTIVE_SESSIONS=()
    SESSION_CLEANUP_QUEUE=()
    
    local exit_code
    execute_git_command "99" "--version" > /dev/null 2>&1
    exit_code=$?
    
    # Git should be available
    assert_equals "0" "$exit_code" "execute_git_command succeeds with git --version"
}

# ==============================================================================
# MAIN TEST RUNNER
# ==============================================================================

main() {
    echo ""
    print_header "Bash Session Manager Test Suite"
    
    echo -e "${CYAN}Running Session ID Generation Tests...${NC}\n"
    test_generate_session_id_format
    test_generate_unique_session_ids
    
    echo -e "\n${CYAN}Running Session Registration Tests...${NC}\n"
    test_register_and_unregister_session
    
    echo -e "\n${CYAN}Running Command Execution Tests...${NC}\n"
    test_execute_with_session_sync_success
    test_execute_with_session_sync_failure
    test_execute_with_session_timeout
    test_execute_with_session_async
    
    echo -e "\n${CYAN}Running Timeout Recommendation Tests...${NC}\n"
    test_get_recommended_timeout_npm_test
    test_get_recommended_timeout_npm_install
    test_get_recommended_timeout_git_operation
    test_get_recommended_timeout_default
    
    echo -e "\n${CYAN}Running Cleanup Tests...${NC}\n"
    test_cleanup_all_sessions
    
    echo -e "\n${CYAN}Running Helper Function Tests...${NC}\n"
    test_execute_npm_command
    test_execute_git_command
    
    # Summary
    echo ""
    print_header "Test Results Summary"
    echo -e "${CYAN}Total Tests:${NC} $TESTS_RUN"
    echo -e "${GREEN}Passed:${NC}      $TESTS_PASSED"
    echo -e "${RED}Failed:${NC}      $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo ""
        echo -e "${RED}Failed Tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${YELLOW}•${NC} $test"
        done
    fi
    
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}\n"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed${NC}\n"
        exit 1
    fi
}

# Run tests
main "$@"
