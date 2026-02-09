#!/bin/bash
################################################################################
# Test Suite for File Operations Module
# Purpose: Validate file resilience features and error recovery
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Set non-interactive mode to prevent blocking on stdin
export AUTO_MODE=true

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${SCRIPT_DIR}/../../src/workflow/lib"
source "${WORKFLOW_LIB_DIR}/colors.sh"
source "${WORKFLOW_LIB_DIR}/config.sh"
source "${WORKFLOW_LIB_DIR}/utils.sh"
source "${WORKFLOW_LIB_DIR}/file_operations.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
declare -a FAILED_TESTS

# Test directory
TEST_DIR="/tmp/file_ops_test_$$"

# Cleanup handler
cleanup_test_files() {
    [[ -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

# Register cleanup on exit
trap cleanup_test_files EXIT

# Setup
setup() {
    mkdir -p "$TEST_DIR"
}

# Teardown (kept for compatibility but trap handles cleanup)
teardown() {
    rm -rf "$TEST_DIR"
}

# ==============================================================================
# TEST FRAMEWORK
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

assert_file_exists() {
    local filepath="$1"
    local test_name="$2"
    
    ((TESTS_RUN++)) || true
    
    if [[ -f "$filepath" ]]; then
        ((TESTS_PASSED++)) || true
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        return 0
    else
        ((TESTS_FAILED++)) || true
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   File not found: ${YELLOW}$filepath${NC}"
        return 1
    fi
}

assert_file_not_exists() {
    local filepath="$1"
    local test_name="$2"
    
    ((TESTS_RUN++)) || true
    
    if [[ ! -f "$filepath" ]]; then
        ((TESTS_PASSED++)) || true
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        return 0
    else
        ((TESTS_FAILED++)) || true
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo -e "   File exists: ${YELLOW}$filepath${NC}"
        return 1
    fi
}

# ==============================================================================
# FILE EXISTENCE TESTS
# ==============================================================================

test_check_file_exists_new_file() {
    local testfile="$TEST_DIR/new_file.txt"
    
    check_file_exists "$testfile" "fail" > /dev/null 2>&1
    local result=$?
    
    assert_equals "0" "$result" "check_file_exists returns 0 for non-existent file"
}

test_check_file_exists_fail_strategy() {
    local testfile="$TEST_DIR/existing.txt"
    echo "test" > "$testfile"
    
    # Disable errexit for this check since we expect it to return non-zero
    set +e
    check_file_exists "$testfile" "fail" > /dev/null 2>&1
    local result=$?
    set -e
    
    assert_equals "1" "$result" "check_file_exists returns 1 with fail strategy"
}

test_check_file_exists_overwrite_strategy() {
    local testfile="$TEST_DIR/overwrite.txt"
    echo "test" > "$testfile"
    
    check_file_exists "$testfile" "overwrite" > /dev/null 2>&1
    local result=$?
    
    assert_equals "0" "$result" "check_file_exists returns 0 with overwrite strategy"
}

test_check_file_exists_append_timestamp_strategy() {
    local testfile="$TEST_DIR/timestamp.txt"
    echo "test" > "$testfile"
    
    set +e
    check_file_exists "$testfile" "append_timestamp" > /dev/null 2>&1
    local result=$?
    set -e
    
    assert_equals "2" "$result" "check_file_exists returns 2 with append_timestamp strategy"
}

# ==============================================================================
# SAFE FILENAME GENERATION TESTS
# ==============================================================================

test_get_safe_filename_timestamp() {
    local original="$TEST_DIR/test.txt"
    local safe_name
    safe_name=$(get_safe_filename "$original" "append_timestamp")
    
    if [[ "$safe_name" =~ test_[0-9]{8}_[0-9]{6}\.txt$ ]]; then
        assert_equals "true" "true" "get_safe_filename generates timestamp filename"
    else
        assert_equals "true" "false" "get_safe_filename generates timestamp filename"
    fi
}

test_get_safe_filename_increment() {
    local original="$TEST_DIR/count.txt"
    touch "$original"
    
    local safe_name
    safe_name=$(get_safe_filename "$original" "increment")
    
    assert_equals "$TEST_DIR/count_1.txt" "$safe_name" "get_safe_filename increments counter"
}

test_get_safe_filename_increment_multiple() {
    local original="$TEST_DIR/multi.txt"
    touch "$original"
    touch "$TEST_DIR/multi_1.txt"
    touch "$TEST_DIR/multi_2.txt"
    
    local safe_name
    safe_name=$(get_safe_filename "$original" "increment")
    
    assert_equals "$TEST_DIR/multi_3.txt" "$safe_name" "get_safe_filename finds next available number"
}

# ==============================================================================
# SAFE FILE CREATION TESTS
# ==============================================================================

test_safe_create_file_new() {
    local testfile="$TEST_DIR/safe_new.txt"
    local content="Test content"
    
    local result
    result=$(safe_create_file "$testfile" "$content" "fail" false 2>/dev/null)
    
    if [[ -f "$testfile" ]] && [[ "$(cat "$testfile")" == "$content" ]]; then
        assert_equals "true" "true" "safe_create_file creates new file"
    else
        assert_equals "true" "false" "safe_create_file creates new file"
    fi
}

test_safe_create_file_fail_on_existing() {
    local testfile="$TEST_DIR/fail_existing.txt"
    echo "original" > "$testfile"
    
    set +e
    safe_create_file "$testfile" "new content" "fail" false > /dev/null 2>&1
    local result=$?
    set -e
    
    assert_equals "1" "$result" "safe_create_file fails when file exists (fail strategy)"
}

test_safe_create_file_overwrite() {
    local testfile="$TEST_DIR/overwrite.txt"
    echo "original" > "$testfile"
    
    safe_create_file "$testfile" "new content" "overwrite" false > /dev/null 2>&1
    local content=$(cat "$testfile")
    
    assert_equals "new content" "$content" "safe_create_file overwrites with overwrite strategy"
}

test_safe_create_file_append_timestamp() {
    local testfile="$TEST_DIR/timestamp.txt"
    echo "original" > "$testfile"
    
    local result
    result=$(safe_create_file "$testfile" "new content" "append_timestamp" false 2>/dev/null | tail -1)
    
    # Check if result path has timestamp and file exists
    if [[ -f "$result" ]] && [[ "$result" =~ timestamp_[0-9]{8}_[0-9]{6}\.txt$ ]]; then
        assert_equals "true" "true" "safe_create_file appends timestamp when file exists"
    else
        assert_equals "true" "false" "safe_create_file appends timestamp when file exists"
    fi
}

test_safe_create_file_with_backup() {
    local testfile="$TEST_DIR/backup_test.txt"
    echo "original" > "$testfile"
    
    safe_create_file "$testfile" "new content" "overwrite" true > /dev/null 2>&1
    
    local backup_count
    backup_count=$(ls "$TEST_DIR"/backup_test.txt.backup.* 2>/dev/null | wc -l)
    
    if [[ $backup_count -gt 0 ]]; then
        assert_equals "true" "true" "safe_create_file creates backup when requested"
    else
        assert_equals "true" "false" "safe_create_file creates backup when requested"
    fi
}

# ==============================================================================
# DIRECTORY OPERATIONS TESTS
# ==============================================================================

test_ensure_directory_new() {
    local testdir="$TEST_DIR/new_dir"
    
    ensure_directory "$testdir" > /dev/null 2>&1
    
    if [[ -d "$testdir" ]]; then
        assert_equals "true" "true" "ensure_directory creates new directory"
    else
        assert_equals "true" "false" "ensure_directory creates new directory"
    fi
}

test_ensure_directory_existing() {
    local testdir="$TEST_DIR/existing_dir"
    mkdir -p "$testdir"
    
    ensure_directory "$testdir" > /dev/null 2>&1
    local result=$?
    
    assert_equals "0" "$result" "ensure_directory succeeds for existing directory"
}

test_ensure_directory_nested() {
    local testdir="$TEST_DIR/level1/level2/level3"
    
    ensure_directory "$testdir" > /dev/null 2>&1
    
    if [[ -d "$testdir" ]]; then
        assert_equals "true" "true" "ensure_directory creates nested directories"
    else
        assert_equals "true" "false" "ensure_directory creates nested directories"
    fi
}

# ==============================================================================
# ATOMIC OPERATIONS TESTS
# ==============================================================================

test_atomic_update_file() {
    local testfile="$TEST_DIR/atomic.txt"
    local content="atomic content"
    
    atomic_update_file "$testfile" "$content" "fail" > /dev/null 2>&1
    
    if [[ -f "$testfile" ]] && [[ "$(cat "$testfile")" == "$content" ]]; then
        # Check no temp files left (disable errexit for ls glob that may not match)
        local temp_count
        set +e
        temp_count=$(ls "$TEST_DIR"/atomic.txt.tmp.* 2>/dev/null | wc -l)
        set -e
        
        if [[ $temp_count -eq 0 ]]; then
            assert_equals "true" "true" "atomic_update_file creates file and cleans up temp"
        else
            assert_equals "true" "false" "atomic_update_file creates file and cleans up temp"
        fi
    else
        assert_equals "true" "false" "atomic_update_file creates file and cleans up temp"
    fi
}

# ==============================================================================
# FILE LOCKING TESTS
# ==============================================================================

test_acquire_and_release_lock() {
    local lockfile="$TEST_DIR/test.lock"
    
    acquire_file_lock "$lockfile" 5 > /dev/null 2>&1
    local acquire_result=$?
    
    local lock_exists=false
    [[ -d "$lockfile" ]] && lock_exists=true
    
    release_file_lock "$lockfile" > /dev/null 2>&1
    local release_result=$?
    
    local lock_removed=true
    [[ -d "$lockfile" ]] && lock_removed=false
    
    if [[ $acquire_result -eq 0 ]] && [[ "$lock_exists" == true ]] && \
       [[ $release_result -eq 0 ]] && [[ "$lock_removed" == true ]]; then
        assert_equals "true" "true" "acquire and release file lock works"
    else
        assert_equals "true" "false" "acquire and release file lock works"
    fi
}

# ==============================================================================
# RETRY OPERATION TESTS
# ==============================================================================

test_retry_operation_success() {
    retry_operation 3 "true" > /dev/null 2>&1
    local result=$?
    
    assert_equals "0" "$result" "retry_operation succeeds on first attempt"
}

test_retry_operation_eventual_success() {
    local counter_file="$TEST_DIR/retry_counter"
    echo "0" > "$counter_file"
    
    # Command that fails twice then succeeds
    local test_cmd="count=\$(cat $counter_file); echo \$((count + 1)) > $counter_file; [[ \$count -ge 2 ]]"
    
    retry_operation 5 "$test_cmd" > /dev/null 2>&1
    local result=$?
    
    assert_equals "0" "$result" "retry_operation succeeds after retries"
}

# ==============================================================================
# MAIN TEST RUNNER
# ==============================================================================

main() {
    echo ""
    print_header "File Operations Test Suite"
    
    setup
    
    echo -e "${CYAN}Running File Existence Tests...${NC}\n"
    test_check_file_exists_new_file
    test_check_file_exists_fail_strategy
    test_check_file_exists_overwrite_strategy
    test_check_file_exists_append_timestamp_strategy
    
    echo -e "\n${CYAN}Running Safe Filename Generation Tests...${NC}\n"
    test_get_safe_filename_timestamp
    test_get_safe_filename_increment
    test_get_safe_filename_increment_multiple
    
    echo -e "\n${CYAN}Running Safe File Creation Tests...${NC}\n"
    test_safe_create_file_new
    test_safe_create_file_fail_on_existing
    test_safe_create_file_overwrite
    test_safe_create_file_append_timestamp
    test_safe_create_file_with_backup
    
    echo -e "\n${CYAN}Running Directory Operations Tests...${NC}\n"
    test_ensure_directory_new
    test_ensure_directory_existing
    test_ensure_directory_nested
    
    echo -e "\n${CYAN}Running Atomic Operations Tests...${NC}\n"
    test_atomic_update_file
    
    echo -e "\n${CYAN}Running File Locking Tests...${NC}\n"
    test_acquire_and_release_lock
    
    echo -e "\n${CYAN}Running Retry Operation Tests...${NC}\n"
    test_retry_operation_success
    test_retry_operation_eventual_success
    
    teardown
    
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
exit_code=$?
exit $exit_code
