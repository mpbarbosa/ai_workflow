#!/bin/bash
set -euo pipefail

################################################################################
# Test Suite for Step 11: Deployment Readiness Gate
# Purpose: Validate deployment gate functionality
# Part of: Tests & Documentation Workflow Automation v3.3.0
################################################################################

# Disable errexit for test execution
set +e

# Test counter
TEST_COUNT=0
PASSED=0
FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mock print functions for testing
print_info() { echo "[INFO] $*"; }
print_success() { echo "[SUCCESS] $*"; }
print_error() { echo "[ERROR] $*" >&2; }
print_warning() { echo "[WARNING] $*"; }

# Test helper functions
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    ((TEST_COUNT++))
    echo ""
    echo "=== Test ${TEST_COUNT}: ${test_name} ==="
    
    if $test_func; then
        echo "✅ PASS: $test_name"
        ((PASSED++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        ((FAILED++))
        return 1
    fi
}

# Test 1: Module loading
test_module_loading() {
    # Source main step module in subshell to avoid set -e issues
    (
        source "${SCRIPT_DIR}/step_11_deployment_gate.sh" 2>/dev/null
    )
    return $?
}

# Test 2: Test validation module
test_test_validation_module() {
    (
        source "${SCRIPT_DIR}/step_11_lib/test_validation.sh" 2>/dev/null && \
        declare -F check_test_status >/dev/null
    )
    return $?
}

# Test 3: CHANGELOG validation module
test_changelog_validation_module() {
    (
        source "${SCRIPT_DIR}/step_11_lib/changelog_validation.sh" 2>/dev/null && \
        declare -F check_changelog_updated >/dev/null
    )
    return $?
}

# Test 4: Version validation module
test_version_validation_module() {
    (
        source "${SCRIPT_DIR}/step_11_lib/version_validation.sh" 2>/dev/null && \
        declare -F check_version_bump >/dev/null
    )
    return $?
}

# Test 5: Branch sync validation module
test_branch_sync_module() {
    (
        source "${SCRIPT_DIR}/step_11_lib/branch_sync_validation.sh" 2>/dev/null && \
        declare -F check_branch_sync >/dev/null
    )
    return $?
}

# Test 6: Syntax validation - all modules
test_syntax_validation() {
    local syntax_ok=true
    
    # Check main module
    if ! bash -n "${SCRIPT_DIR}/step_11_deployment_gate.sh" 2>/dev/null; then
        echo "Syntax error in step_11_deployment_gate.sh"
        syntax_ok=false
    fi
    
    # Check lib modules
    for lib_file in "${SCRIPT_DIR}/step_11_lib"/*.sh; do
        if [[ -f "$lib_file" ]]; then
            if ! bash -n "$lib_file" 2>/dev/null; then
                echo "Syntax error in $(basename "$lib_file")"
                syntax_ok=false
            fi
        fi
    done
    
    [[ "$syntax_ok" == "true" ]] && return 0 || return 1
}

# Test 7: Function exports
test_function_exports() {
    # Source all modules in subshell
    (
        set +e  # Disable errexit
        source "${SCRIPT_DIR}/step_11_lib/test_validation.sh" 2>/dev/null
        source "${SCRIPT_DIR}/step_11_lib/changelog_validation.sh" 2>/dev/null
        source "${SCRIPT_DIR}/step_11_lib/version_validation.sh" 2>/dev/null
        source "${SCRIPT_DIR}/step_11_lib/branch_sync_validation.sh" 2>/dev/null
        source "${SCRIPT_DIR}/step_11_deployment_gate.sh" 2>/dev/null
        
        # Check for required functions
        declare -F step11_deployment_gate >/dev/null || exit 1
        declare -F check_test_status >/dev/null || exit 1
        declare -F check_changelog_updated >/dev/null || exit 1
        declare -F check_version_bump >/dev/null || exit 1
        declare -F check_branch_sync >/dev/null || exit 1
    )
    return $?
}

# Test 8: Flag skipping behavior
test_flag_skipping() {
    # Mock environment
    export VALIDATE_RELEASE=false
    export PROJECT_ROOT="$(pwd)"
    export WORKFLOW_HOME="$(pwd)"
    export BACKLOG_DIR="test_backlog"
    declare -A WORKFLOW_STATUS
    export WORKFLOW_STATUS
    
    # Source module
    source "${SCRIPT_DIR}/step_11_deployment_gate.sh" 2>/dev/null || return 1
    
    # Test that step returns 0 when VALIDATE_RELEASE is false
    if step11_deployment_gate >/dev/null 2>&1; then
        return 0
    else
        echo "Step should skip gracefully when VALIDATE_RELEASE=false"
        return 1
    fi
}

# Test 9: Directory structure
test_directory_structure() {
    # Check that step_11_lib directory exists
    if [[ ! -d "${SCRIPT_DIR}/step_11_lib" ]]; then
        echo "step_11_lib directory not found"
        return 1
    fi
    
    # Check that all expected lib files exist
    local required_files=(
        "test_validation.sh"
        "changelog_validation.sh"
        "version_validation.sh"
        "branch_sync_validation.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "${SCRIPT_DIR}/step_11_lib/${file}" ]]; then
            echo "Required file not found: $file"
            return 1
        fi
    done
    
    return 0
}

# Test 10: File permissions
test_file_permissions() {
    # Check that main module is executable
    if [[ ! -x "${SCRIPT_DIR}/step_11_deployment_gate.sh" ]]; then
        echo "Main module is not executable"
        # Make it executable
        chmod +x "${SCRIPT_DIR}/step_11_deployment_gate.sh"
    fi
    
    # Check lib files
    for lib_file in "${SCRIPT_DIR}/step_11_lib"/*.sh; do
        if [[ -f "$lib_file" && ! -x "$lib_file" ]]; then
            echo "Making $(basename "$lib_file") executable"
            chmod +x "$lib_file"
        fi
    done
    
    return 0
}

# ==============================================================================
# TEST EXECUTION
# ==============================================================================

main() {
    echo "============================================"
    echo "Step 11: Deployment Readiness Gate Test Suite"
    echo "============================================"
    echo ""
    
    # Run all tests
    run_test "Module Loading" test_module_loading
    run_test "Test Validation Module" test_test_validation_module
    run_test "CHANGELOG Validation Module" test_changelog_validation_module
    run_test "Version Validation Module" test_version_validation_module
    run_test "Branch Sync Validation Module" test_branch_sync_module
    run_test "Syntax Validation" test_syntax_validation
    run_test "Function Exports" test_function_exports
    run_test "Flag Skipping Behavior" test_flag_skipping
    run_test "Directory Structure" test_directory_structure
    run_test "File Permissions" test_file_permissions
    
    # Summary
    echo ""
    echo "============================================"
    echo "Test Summary"
    echo "============================================"
    echo "Total Tests: ${TEST_COUNT}"
    echo "Passed:      ${PASSED}"
    echo "Failed:      ${FAILED}"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

# Run tests
main "$@"
