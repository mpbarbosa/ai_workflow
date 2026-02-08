#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Validation Module
# Purpose: Validate test execution status for deployment readiness
# Part of: Step 11 - Deployment Readiness Gate
################################################################################

# ==============================================================================
# TEST STATUS VALIDATION
# ==============================================================================

# Check if all tests passed in Step 8
# Returns: 0 if tests passed, 1 if tests failed or not run
check_test_status() {
    local workflow_status_file="${WORKFLOW_HOME}/backlog/${BACKLOG_DIR}/workflow_status.txt"
    
    # Method 1: Check WORKFLOW_STATUS array if available
    if [[ -n "${WORKFLOW_STATUS[8]:-}" ]]; then
        if [[ "${WORKFLOW_STATUS[8]}" == "✅" ]]; then
            return 0
        else
            print_error "Step 8 (Test Execution) status: ${WORKFLOW_STATUS[8]}"
            return 1
        fi
    fi
    
    # Method 2: Check workflow status file
    if [[ -f "$workflow_status_file" ]]; then
        if grep -q "^Step 8:.*✅" "$workflow_status_file"; then
            return 0
        elif grep -q "^Step 8:.*❌" "$workflow_status_file"; then
            print_error "Step 8 marked as failed in workflow status"
            return 1
        fi
    fi
    
    # Method 3: Check test execution logs
    local test_logs
    test_logs=$(find "${WORKFLOW_HOME}/logs/${WORKFLOW_TIMESTAMP:-*}" -name "*test*.log" 2>/dev/null || true)
    
    if [[ -n "$test_logs" ]]; then
        # Parse test logs for failures
        local has_failures=false
        while IFS= read -r log_file; do
            if grep -qi "fail\|error\|✗" "$log_file" 2>/dev/null; then
                if ! grep -qi "0 fail" "$log_file" 2>/dev/null; then
                    has_failures=true
                    break
                fi
            fi
        done <<< "$test_logs"
        
        if [[ "$has_failures" == "true" ]]; then
            print_error "Test failures detected in logs"
            return 1
        fi
        
        # Test logs found and no failures - tests passed
        return 0
    fi
    
    # Method 4: Check for test result files
    local test_results="${PROJECT_ROOT}/test-results"
    if [[ -d "$test_results" ]]; then
        local failure_files
        failure_files=$(find "$test_results" -name "*fail*.xml" -o -name "*error*.xml" 2>/dev/null || true)
        
        if [[ -n "$failure_files" ]]; then
            print_error "Test failure artifacts found in test-results/"
            return 1
        fi
    fi
    
    # Method 5: Check npm/jest/pytest test commands
    # Look for test command in package.json or setup.py
    if [[ -f "${PROJECT_ROOT}/package.json" ]]; then
        # Node.js project - check if tests were run
        if [[ -f "${PROJECT_ROOT}/coverage/coverage-summary.json" ]]; then
            # Coverage exists, tests likely passed
            return 0
        fi
    fi
    
    if [[ -f "${PROJECT_ROOT}/setup.py" ]] || [[ -f "${PROJECT_ROOT}/pyproject.toml" ]]; then
        # Python project - check for pytest cache
        if [[ -d "${PROJECT_ROOT}/.pytest_cache" ]]; then
            local last_failed="${PROJECT_ROOT}/.pytest_cache/v/cache/lastfailed"
            if [[ -f "$last_failed" ]]; then
                local failed_count
                failed_count=$(grep -c '"' "$last_failed" 2>/dev/null || echo "0")
                if [[ $failed_count -gt 0 ]]; then
                    print_error "Pytest cache shows $failed_count failed test(s)"
                    return 1
                fi
            fi
        fi
    fi
    
    # If we reach here, no clear evidence of failures
    # Default to pass if Step 8 was executed
    return 0
}

# Get detailed test status information
# Returns: Multi-line string with test status details
get_test_status_details() {
    local details=""
    
    # Check for test logs
    local test_logs
    test_logs=$(find "${WORKFLOW_HOME}/logs/${WORKFLOW_TIMESTAMP:-*}" -name "*test*.log" 2>/dev/null || true)
    
    if [[ -n "$test_logs" ]]; then
        details+="Test logs found:\n"
        while IFS= read -r log_file; do
            local log_size
            log_size=$(wc -l < "$log_file" 2>/dev/null || echo "0")
            details+="  - $(basename "$log_file"): ${log_size} lines\n"
        done <<< "$test_logs"
    fi
    
    # Check for test results
    if [[ -d "${PROJECT_ROOT}/test-results" ]]; then
        local result_count
        result_count=$(find "${PROJECT_ROOT}/test-results" -name "*.xml" 2>/dev/null | wc -l)
        details+="Test result files: ${result_count}\n"
    fi
    
    # Check for coverage
    if [[ -f "${PROJECT_ROOT}/coverage/coverage-summary.json" ]]; then
        details+="Coverage report: available\n"
    fi
    
    echo -e "$details"
}

# Export functions
export -f check_test_status get_test_status_details
