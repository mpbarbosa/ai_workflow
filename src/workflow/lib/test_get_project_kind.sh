#!/usr/bin/env bash
set -uo pipefail  # Removed -e to allow test failures without script exit

################################################################################
# Test Suite for get_project_kind Function
# Purpose: Verify get_project_kind correctly reads from .workflow-config.yaml
# Version: 1.0.0
################################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the module (suppress errors from module initialization)
source "${SCRIPT_DIR}/project_kind_config.sh" 2>/dev/null || {
    echo "Error: Failed to source project_kind_config.sh"
    exit 1
}

# Check if function was loaded
if ! declare -f get_project_kind &>/dev/null; then
    echo "Error: get_project_kind function not found"
    exit 1
fi

source "${SCRIPT_DIR}/colors.sh" 2>/dev/null || true

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    ((TESTS_RUN++))
    echo ""
    echo "Running: ${test_name}"
    
    if $test_func; then
        ((TESTS_PASSED++))
        echo "  ✅ PASSED"
        return 0
    else
        ((TESTS_FAILED++))
        echo "  ❌ FAILED"
        return 1
    fi
}

################################################################################
# Test Cases
################################################################################

# Test 1: Get project kind from current directory
test_get_project_kind_current_dir() {
    local kind
    kind=$(get_project_kind ".")
    
    if [[ -z "${kind}" ]]; then
        echo "  Warning: No project kind found in current directory"
        return 0  # Not a failure if config doesn't exist
    fi
    
    echo "  Found: ${kind}"
    return 0
}

# Test 2: Get project kind from ai_workflow directory
test_get_project_kind_ai_workflow() {
    local project_root="${SCRIPT_DIR}/../../.."
    local kind
    kind=$(get_project_kind "${project_root}")
    
    if [[ "${kind}" == "shell_automation" ]]; then
        echo "  Correctly returned: ${kind}"
        return 0
    else
        echo "  Expected 'shell_automation', got '${kind}'"
        return 1
    fi
}

# Test 3: Test with non-existent directory
test_get_project_kind_nonexistent() {
    local kind
    kind=$(get_project_kind "/tmp/nonexistent_test_dir_12345")
    
    if [[ -z "${kind}" ]]; then
        echo "  Correctly returned empty string for non-existent directory"
        return 0
    else
        echo "  Expected empty string, got '${kind}'"
        return 1
    fi
}

# Test 4: Test with temporary config file
test_get_project_kind_temp_config() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Create test config
    cat > "${temp_dir}/.workflow-config.yaml" << 'EOCONFIG'
project:
  name: "Test Project"
  kind: "nodejs_api"

tech_stack:
  primary_language: "javascript"
EOCONFIG
    
    local kind
    kind=$(get_project_kind "${temp_dir}")
    
    # Cleanup
    rm -rf "${temp_dir}"
    
    if [[ "${kind}" == "nodejs_api" ]]; then
        echo "  Correctly parsed temporary config: ${kind}"
        return 0
    else
        echo "  Expected 'nodejs_api', got '${kind}'"
        return 1
    fi
}

# Test 5: Test with .yml extension
test_get_project_kind_yml_extension() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Create test config with .yml extension
    cat > "${temp_dir}/.workflow-config.yml" << 'EOCONFIG'
project:
  name: "Test Project"
  kind: "python_api"

tech_stack:
  primary_language: "python"
EOCONFIG
    
    local kind
    kind=$(get_project_kind "${temp_dir}")
    
    # Cleanup
    rm -rf "${temp_dir}"
    
    if [[ "${kind}" == "python_api" ]]; then
        echo "  Correctly parsed .yml config: ${kind}"
        return 0
    else
        echo "  Expected 'python_api', got '${kind}'"
        return 1
    fi
}

# Test 6: Test with missing kind field
test_get_project_kind_missing_field() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Create config without kind field
    cat > "${temp_dir}/.workflow-config.yaml" << 'EOCONFIG'
project:
  name: "Test Project"
  type: "test"

tech_stack:
  primary_language: "javascript"
EOCONFIG
    
    local kind
    kind=$(get_project_kind "${temp_dir}")
    
    # Cleanup
    rm -rf "${temp_dir}"
    
    if [[ -z "${kind}" ]]; then
        echo "  Correctly returned empty string for missing kind field"
        return 0
    else
        echo "  Expected empty string, got '${kind}'"
        return 1
    fi
}

# Test 7: Test with various project kinds
test_get_project_kind_all_kinds() {
    local kinds=(
        "shell_automation"
        "nodejs_api"
        "nodejs_cli"
        "nodejs_library"
        "static_website"
        "react_spa"
        "vue_spa"
        "python_api"
        "python_cli"
        "python_library"
        "documentation"
    )
    
    for kind in "${kinds[@]}"; do
        local temp_dir
        temp_dir=$(mktemp -d)
        
        cat > "${temp_dir}/.workflow-config.yaml" << EOCONFIG
project:
  name: "Test"
  kind: "${kind}"
tech_stack:
  primary_language: "test"
EOCONFIG
        
        local result
        result=$(get_project_kind "${temp_dir}")
        
        rm -rf "${temp_dir}"
        
        if [[ "${result}" != "${kind}" ]]; then
            echo "  Failed for kind: ${kind}, got: ${result}"
            return 1
        fi
    done
    
    echo "  All ${#kinds[@]} project kinds parsed correctly"
    return 0
}

################################################################################
# Main Test Runner
################################################################################

main() {
    echo "========================================"
    echo "get_project_kind() Test Suite"
    echo "========================================"
    
    # Run all tests
    run_test "Get project kind from current directory" test_get_project_kind_current_dir
    run_test "Get project kind from ai_workflow" test_get_project_kind_ai_workflow
    run_test "Test non-existent directory" test_get_project_kind_nonexistent
    run_test "Test with temporary config" test_get_project_kind_temp_config
    run_test "Test with .yml extension" test_get_project_kind_yml_extension
    run_test "Test with missing kind field" test_get_project_kind_missing_field
    run_test "Test all project kind values" test_get_project_kind_all_kinds
    
    # Print summary
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Tests Run:    ${TESTS_RUN}"
    echo "Tests Passed: ${TESTS_PASSED}"
    echo "Tests Failed: ${TESTS_FAILED}"
    echo ""
    
    if [[ ${TESTS_FAILED} -eq 0 ]]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
