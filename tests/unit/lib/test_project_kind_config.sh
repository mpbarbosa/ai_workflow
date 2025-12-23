#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: Project Kind Configuration Module
# Purpose: Validate project_kind_config.sh functionality
# Version: 1.0.0
################################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the module to test
source "${SCRIPT_DIR}/project_kind_config.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# Test Framework Functions
################################################################################

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "${expected}" == "${actual}" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        echo "  Expected: ${expected}"
        echo "  Actual:   ${actual}"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -n "${value}" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        echo "  Value is empty"
        return 1
    fi
}

assert_true() {
    local command="$1"
    local message="${2:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "${command}"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        return 1
    fi
}

assert_false() {
    local command="$1"
    local message="${2:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "${command}"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        return 1
    fi
}

################################################################################
# Test Suites
################################################################################

test_configuration_loading() {
    echo ""
    echo "=== Testing Configuration Loading ==="
    
    # Test loading valid project kind
    assert_true "load_project_kind_config 'shell_script_automation'" \
        "Load shell_script_automation config"
    
    assert_true "load_project_kind_config 'nodejs_api'" \
        "Load nodejs_api config"
    
    # Test loading invalid project kind
    assert_false "load_project_kind_config 'nonexistent_kind'" \
        "Fail to load nonexistent project kind"
}

test_basic_metadata() {
    echo ""
    echo "=== Testing Basic Metadata ==="
    
    local name
    name=$(get_project_kind_name "shell_script_automation")
    assert_equals "Shell Script Automation" "${name}" \
        "Get shell_script_automation name"
    
    local desc
    desc=$(get_project_kind_description "nodejs_api")
    assert_not_empty "${desc}" \
        "Get nodejs_api description"
    
    local name_api
    name_api=$(get_project_kind_name "nodejs_api")
    assert_equals "Node.js API" "${name_api}" \
        "Get nodejs_api name"
}

test_validation_config() {
    echo ""
    echo "=== Testing Validation Configuration ==="
    
    # Test required files
    local required_files
    required_files=$(get_required_files "nodejs_api")
    assert_not_empty "${required_files}" \
        "Get required files for nodejs_api"
    
    # Test required directories
    local required_dirs
    required_dirs=$(get_required_directories "nodejs_api")
    assert_not_empty "${required_dirs}" \
        "Get required directories for nodejs_api"
    
    # Test file patterns
    local patterns
    patterns=$(get_file_patterns "shell_script_automation")
    assert_not_empty "${patterns}" \
        "Get file patterns for shell_script_automation"
}

test_testing_config() {
    echo ""
    echo "=== Testing Test Configuration ==="
    
    # Test framework
    local framework
    framework=$(get_test_framework "nodejs_api")
    assert_not_empty "${framework}" \
        "Get test framework for nodejs_api"
    
    # Test directory
    local test_dir
    test_dir=$(get_test_directory "python_app")
    assert_equals "tests" "${test_dir}" \
        "Get test directory for python_app"
    
    # Test command
    local test_cmd
    test_cmd=$(get_test_command "nodejs_api")
    assert_equals "npm test" "${test_cmd}" \
        "Get test command for nodejs_api"
    
    # Coverage requirements
    assert_true "is_coverage_required 'nodejs_api'" \
        "nodejs_api requires coverage"
    
    assert_false "is_coverage_required 'shell_script_automation'" \
        "shell_script_automation doesn't require coverage"
    
    # Coverage threshold
    local threshold
    threshold=$(get_coverage_threshold "nodejs_api")
    assert_equals "80" "${threshold}" \
        "Get coverage threshold for nodejs_api"
}

test_quality_config() {
    echo ""
    echo "=== Testing Quality Configuration ==="
    
    # Test enabled linters
    local linters
    linters=$(get_enabled_linters "nodejs_api")
    assert_not_empty "${linters}" \
        "Get enabled linters for nodejs_api"
    
    # Documentation requirements
    assert_true "is_documentation_required 'nodejs_api'" \
        "nodejs_api requires documentation"
    
    assert_true "is_readme_required 'static_website'" \
        "static_website requires README"
}

test_dependencies_config() {
    echo ""
    echo "=== Testing Dependencies Configuration ==="
    
    # Package files
    local package_files
    package_files=$(get_package_files "nodejs_api")
    assert_not_empty "${package_files}" \
        "Get package files for nodejs_api"
    
    # Lock files
    local lock_files
    lock_files=$(get_lock_files "nodejs_api")
    assert_not_empty "${lock_files}" \
        "Get lock files for nodejs_api"
    
    # Validation requirements
    assert_true "is_dependency_validation_required 'nodejs_api'" \
        "nodejs_api requires dependency validation"
    
    assert_false "is_dependency_validation_required 'shell_script_automation'" \
        "shell_script_automation doesn't require dependency validation"
    
    # Security audit
    assert_true "is_security_audit_required 'nodejs_api'" \
        "nodejs_api requires security audit"
    
    local audit_cmd
    audit_cmd=$(get_audit_command "python_app")
    assert_equals "pip-audit" "${audit_cmd}" \
        "Get audit command for python_app"
}

test_build_config() {
    echo ""
    echo "=== Testing Build Configuration ==="
    
    # Build requirements
    assert_true "is_build_required 'react_spa'" \
        "react_spa requires build"
    
    assert_false "is_build_required 'shell_script_automation'" \
        "shell_script_automation doesn't require build"
    
    # Build command
    local build_cmd
    build_cmd=$(get_build_command "react_spa")
    assert_equals "npm run build" "${build_cmd}" \
        "Get build command for react_spa"
    
    # Build output directory
    local output_dir
    output_dir=$(get_build_output_directory "react_spa")
    assert_not_empty "${output_dir}" \
        "Get build output directory for react_spa"
}

test_deployment_config() {
    echo ""
    echo "=== Testing Deployment Configuration ==="
    
    # Deployment type
    local deploy_type
    deploy_type=$(get_deployment_type "nodejs_api")
    assert_equals "service" "${deploy_type}" \
        "Get deployment type for nodejs_api"
    
    local static_type
    static_type=$(get_deployment_type "static_website")
    assert_equals "static" "${static_type}" \
        "Get deployment type for static_website"
    
    # Artifact patterns
    local artifacts
    artifacts=$(get_artifact_patterns "shell_script_automation")
    assert_not_empty "${artifacts}" \
        "Get artifact patterns for shell_script_automation"
}

test_list_functions() {
    echo ""
    echo "=== Testing List Functions ==="
    
    # List all project kinds
    local kinds
    kinds=$(list_project_kinds)
    assert_not_empty "${kinds}" \
        "List all project kinds"
    
    # Verify specific kinds exist
    if [[ "${kinds}" == *"nodejs_api"* ]]; then
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} nodejs_api exists in list"
    else
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} nodejs_api missing from list"
    fi
}

test_generic_fallback() {
    echo ""
    echo "=== Testing Generic Fallback ==="
    
    # Generic project should have minimal requirements
    local required_files
    required_files=$(get_required_files "generic")
    assert_equals "" "${required_files}" \
        "Generic project has no required files"
    
    local test_cmd
    test_cmd=$(get_test_command "generic")
    assert_equals "" "${test_cmd}" \
        "Generic project has no test command"
    
    assert_false "is_coverage_required 'generic'" \
        "Generic project doesn't require coverage"
}

test_all_project_kinds() {
    echo ""
    echo "=== Testing All Project Kinds ==="
    
    local kinds
    kinds=$(list_project_kinds)
    
    for kind in ${kinds}; do
        local name
        name=$(get_project_kind_name "${kind}")
        assert_not_empty "${name}" \
            "Get name for ${kind}"
    done
}

################################################################################
# Main Test Runner
################################################################################

main() {
    echo "=========================================="
    echo "Project Kind Configuration Module Tests"
    echo "=========================================="
    
    # Check prerequisites
    if ! command -v yq &> /dev/null; then
        echo -e "${YELLOW}Warning: yq not found. Some tests may fail.${NC}"
    fi
    
    # Run all test suites
    test_configuration_loading
    test_basic_metadata
    test_validation_config
    test_testing_config
    test_quality_config
    test_dependencies_config
    test_build_config
    test_deployment_config
    test_list_functions
    test_generic_fallback
    test_all_project_kinds
    
    # Print summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests:  ${TESTS_RUN}"
    echo -e "${GREEN}Passed:       ${TESTS_PASSED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${RED}Failed:       ${TESTS_FAILED}${NC}"
        echo ""
        echo "Some tests failed!"
        exit 1
    else
        echo -e "${GREEN}Failed:       ${TESTS_FAILED}${NC}"
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
main "$@"
