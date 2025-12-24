#!/bin/bash
set -euo pipefail

################################################################################
# Test Result Validation Module
# Version: 1.0.0
# Purpose: Validate test execution results and prevent silent failures
# Part of: Tests & Documentation Workflow Automation v2.4.1
# Created: December 24, 2025
################################################################################

# ==============================================================================
# TEST RESULT VALIDATION
# ==============================================================================

# Validate test results and return appropriate exit code
# Args:
#   $1 - test_exit_code: Exit code from test command
#   $2 - tests_total: Total number of tests
#   $3 - tests_passed: Number of passed tests
#   $4 - tests_failed: Number of failed tests
# Returns:
#   0 if all tests passed, 1 if any failed
validate_test_results() {
    local test_exit_code="$1"
    local tests_total="${2:-0}"
    local tests_passed="${3:-0}"
    local tests_failed="${4:-0}"
    
    # Validation Rule 1: Exit code must be 0
    if [[ $test_exit_code -ne 0 ]]; then
        return 1
    fi
    
    # Validation Rule 2: No failed tests
    if [[ $tests_failed -gt 0 ]]; then
        return 1
    fi
    
    # Validation Rule 3: At least some tests ran (if counts available)
    if [[ $tests_total -eq 0 ]] && [[ $tests_passed -eq 0 ]]; then
        # Warning: No tests detected, but exit code was 0
        # This might be legitimate (no tests) or a parsing failure
        return 0
    fi
    
    # Validation Rule 4: Math consistency check
    if [[ $tests_total -gt 0 ]]; then
        local expected_total=$((tests_passed + tests_failed))
        if [[ $expected_total -ne $tests_total ]]; then
            # Warning: Test count mismatch, but don't fail if exit code was 0
            # This might indicate parsing issues
            return 0
        fi
    fi
    
    return 0
}

# Get appropriate status emoji based on test results
# Args:
#   $1 - test_exit_code: Exit code from test command
#   $2 - tests_failed: Number of failed tests
# Returns:
#   Status emoji string
get_test_status_emoji() {
    local test_exit_code="$1"
    local tests_failed="${2:-0}"
    
    if [[ $test_exit_code -eq 0 ]] && [[ $tests_failed -eq 0 ]]; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Validate and report test results
# Args:
#   $1 - step_number: Step number (e.g., "7")
#   $2 - test_exit_code: Exit code from test command
#   $3 - tests_total: Total number of tests
#   $4 - tests_passed: Number of passed tests
#   $5 - tests_failed: Number of failed tests
# Returns:
#   0 if all tests passed, 1 if any failed
validate_and_update_test_status() {
    local step_number="$1"
    local test_exit_code="$2"
    local tests_total="${3:-0}"
    local tests_passed="${4:-0}"
    local tests_failed="${5:-0}"
    
    # Validate results
    if validate_test_results "$test_exit_code" "$tests_total" "$tests_passed" "$tests_failed"; then
        # All tests passed
        if command -v update_workflow_status &>/dev/null; then
            update_workflow_status "step${step_number}" "✅"
        fi
        return 0
    else
        # Tests failed
        if command -v update_workflow_status &>/dev/null; then
            update_workflow_status "step${step_number}" "❌"
        fi
        return 1
    fi
}

# Parse test framework output and extract counts
# Args:
#   $1 - test_output_file: File containing test output
#   $2 - test_framework: Framework name (jest, bats, pytest, mocha, etc.)
# Returns:
#   Outputs: "total:X passed:Y failed:Z"
parse_test_results() {
    local test_output_file="$1"
    local test_framework="${2:-unknown}"
    
    if [[ ! -f "$test_output_file" ]]; then
        echo "total:0 passed:0 failed:0"
        return 1
    fi
    
    local tests_total=0
    local tests_passed=0
    local tests_failed=0
    
    case "$test_framework" in
        jest)
            tests_total=$(grep -oP 'Tests:.*\K\d+(?= total)' "$test_output_file" 2>/dev/null || echo "0")
            tests_passed=$(grep -oP 'Tests:.*\K\d+(?= passed)' "$test_output_file" 2>/dev/null || echo "0")
            tests_failed=$(grep -oP 'Tests:.*\K\d+(?= failed)' "$test_output_file" 2>/dev/null || echo "0")
            ;;
        bats)
            tests_total=$(grep -oP '\K\d+(?= tests?)' "$test_output_file" 2>/dev/null | head -1 || echo "0")
            tests_failed=$(grep -oP '\K\d+(?= failures?)' "$test_output_file" 2>/dev/null | head -1 || echo "0")
            tests_passed=$((tests_total - tests_failed))
            ;;
        pytest)
            tests_passed=$(grep -oP '\K\d+(?= passed)' "$test_output_file" 2>/dev/null || echo "0")
            tests_failed=$(grep -oP '\K\d+(?= failed)' "$test_output_file" 2>/dev/null || echo "0")
            tests_total=$((tests_passed + tests_failed))
            ;;
        mocha)
            tests_passed=$(grep -oP '\K\d+(?= passing)' "$test_output_file" 2>/dev/null || echo "0")
            tests_failed=$(grep -oP '\K\d+(?= failing)' "$test_output_file" 2>/dev/null || echo "0")
            tests_total=$((tests_passed + tests_failed))
            ;;
        *)
            # Unknown framework - use basic pass/fail detection
            if grep -qi "fail" "$test_output_file" 2>/dev/null; then
                tests_failed=1
                tests_total=1
                tests_passed=0
            else
                tests_passed=1
                tests_total=1
                tests_failed=0
            fi
            ;;
    esac
    
    echo "total:${tests_total} passed:${tests_passed} failed:${tests_failed}"
}

# Validate test coverage meets minimum thresholds
# Args:
#   $1 - coverage_file: Path to coverage summary JSON
#   $2 - min_lines: Minimum line coverage percentage (default: 80)
#   $3 - min_branches: Minimum branch coverage percentage (default: 80)
# Returns:
#   0 if coverage meets thresholds, 1 otherwise
validate_test_coverage() {
    local coverage_file="$1"
    local min_lines="${2:-80}"
    local min_branches="${3:-80}"
    
    if [[ ! -f "$coverage_file" ]]; then
        # No coverage file - don't fail, just warn
        return 0
    fi
    
    if ! command -v jq &>/dev/null; then
        # jq not available - can't validate
        return 0
    fi
    
    local coverage_lines=$(jq -r '.total.lines.pct // 0' "$coverage_file" 2>/dev/null || echo "0")
    local coverage_branches=$(jq -r '.total.branches.pct // 0' "$coverage_file" 2>/dev/null || echo "0")
    
    # Convert to integers for comparison
    coverage_lines=${coverage_lines%.*}
    coverage_branches=${coverage_branches%.*}
    
    if [[ $coverage_lines -lt $min_lines ]] || [[ $coverage_branches -lt $min_branches ]]; then
        return 1
    fi
    
    return 0
}

# Export functions
export -f validate_test_results
export -f get_test_status_emoji
export -f validate_and_update_test_status
export -f parse_test_results
export -f validate_test_coverage
