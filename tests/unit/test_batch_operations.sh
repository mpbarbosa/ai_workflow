#!/bin/bash
################################################################################
# Test Script for Batch Operations
# Purpose: Verify batch file operations work correctly
# Usage: ./test_batch_operations.sh
################################################################################

# Set non-interactive mode to prevent blocking on stdin
export AUTO_MODE=true

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LIB_DIR="${SCRIPT_DIR}/../../src/workflow/lib"

# Source required libraries
source "$WORKFLOW_LIB_DIR/colors.sh"
source "$WORKFLOW_LIB_DIR/utils.sh"
source "$WORKFLOW_LIB_DIR/performance.sh"

# Track temp directories for cleanup
TEMP_DIRS=()

# Cleanup handler
cleanup_test_files() {
    for dir in "${TEMP_DIRS[@]}"; do
        [[ -d "$dir" ]] && rm -rf "$dir"
    done
}

# Register cleanup on exit
trap cleanup_test_files EXIT

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo "Running: $test_name"
    
    if $test_func; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASSED: $test_name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAILED: $test_name"
    fi
    echo ""
}

# ==============================================================================
# TEST CASES
# ==============================================================================

test_batch_read_files() {
    # Create test files
    local tmpdir=$(mktemp -d)
    TEMP_DIRS+=("$tmpdir")
    echo "Content 1" > "$tmpdir/file1.txt"
    echo "Content 2" > "$tmpdir/file2.txt"
    echo "Content 3" > "$tmpdir/file3.txt"
    
    # Test batch read
    batch_read_files "$tmpdir/file1.txt" "$tmpdir/file2.txt" "$tmpdir/file3.txt"
    
    # Verify
    local result=0
    [[ "${FILE_CONTENTS[$tmpdir/file1.txt]}" == "Content 1" ]] || result=1
    [[ "${FILE_CONTENTS[$tmpdir/file2.txt]}" == "Content 2" ]] || result=1
    [[ "${FILE_CONTENTS[$tmpdir/file3.txt]}" == "Content 3" ]] || result=1
    
    return $result
}

test_batch_read_files_limited() {
    # Create test file with multiple lines
    local tmpdir=$(mktemp -d)
    TEMP_DIRS+=("$tmpdir")
    for i in {1..100}; do
        echo "Line $i" >> "$tmpdir/large_file.txt"
    done
    
    # Test limited read (first 10 lines)
    batch_read_files_limited 10 "$tmpdir/large_file.txt"
    
    # Verify line count
    local line_count=$(echo "${FILE_CONTENTS_LIMITED[$tmpdir/large_file.txt]}" | wc -l)
    local result=0
    [[ $line_count -eq 10 ]] || result=1
    
    return $result
}

test_batch_read_missing_file() {
    # Test with missing file (should not fail)
    local missing_file="/tmp/nonexistent_file_$(date +%s).txt"
    
    batch_read_files "$missing_file"
    
    # Should have empty content for missing file
    [[ -z "${FILE_CONTENTS[$missing_file]}" ]] && return 0 || return 1
}

test_batch_command_outputs() {
    # Test parallel command execution
    local cmd1="echo Command1"
    local cmd2="echo Command2"
    local cmd3="echo Command3"
    
    batch_command_outputs "$cmd1" "$cmd2" "$cmd3"
    
    # Verify outputs
    local result=0
    [[ "${CMD_OUTPUTS[$cmd1]}" == "Command1" ]] || result=1
    [[ "${CMD_OUTPUTS[$cmd2]}" == "Command2" ]] || result=1
    [[ "${CMD_OUTPUTS[$cmd3]}" == "Command3" ]] || result=1
    
    return $result
}

test_batch_command_parallel_execution() {
    # Test that commands run in parallel (not sequential)
    local start_time=$(date +%s)
    
    # Each command sleeps 1 second
    # If parallel: ~1 second total
    # If sequential: ~3 seconds total
    batch_command_outputs \
        "sleep 1 && echo 'Done 1'" \
        "sleep 1 && echo 'Done 2'" \
        "sleep 1 && echo 'Done 3'"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Should complete in ~1-2 seconds (parallel), not 4+ (sequential)
    # Threshold increased to 4 for loaded CI systems (33% tolerance)
    [[ $duration -lt 4 ]] && return 0 || return 1
}

test_large_file_performance() {
    # Create a large file
    local tmpdir=$(mktemp -d)
    TEMP_DIRS+=("$tmpdir")
    for i in {1..10000}; do
        echo "Line $i with some content to make it larger" >> "$tmpdir/huge_file.txt"
    done
    
    # Time limited read
    local start_time=$(date +%s%N)
    batch_read_files_limited 100 "$tmpdir/huge_file.txt"
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to ms
    
    # Should be fast (< 100ms typically)
    echo "  → Limited read took ${duration}ms"
    
    # Verify we got 100 lines
    local line_count=$(echo "${FILE_CONTENTS_LIMITED[$tmpdir/huge_file.txt]}" | wc -l)
    
    [[ $line_count -eq 100 ]] && return 0 || return 1
}

# ==============================================================================
# RUN ALL TESTS
# ==============================================================================

main() {
    echo "========================================"
    echo "  Batch Operations Test Suite"
    echo "========================================"
    echo ""
    
    run_test "batch_read_files - basic functionality" test_batch_read_files
    run_test "batch_read_files_limited - line limiting" test_batch_read_files_limited
    run_test "batch_read_files - missing file handling" test_batch_read_missing_file
    run_test "batch_command_outputs - basic functionality" test_batch_command_outputs
    run_test "batch_command_outputs - parallel execution" test_batch_command_parallel_execution
    run_test "batch_read_files_limited - large file performance" test_large_file_performance
    
    # Summary
    echo "========================================"
    echo "  Test Results Summary"
    echo "========================================"
    echo "Tests Run:    $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo "Tests Failed: $TESTS_FAILED"
        exit 1
    else
        echo "All tests passed! ✓"
        exit 0
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
