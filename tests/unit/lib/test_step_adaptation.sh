#!/usr/bin/env bash
# Test Suite for Step Adaptation Module
#
# Tests the step adaptation functionality for project kind awareness
#
# Version: 1.0.0

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/project_kind_detection.sh" 2>/dev/null || true
source "${SCRIPT_DIR}/step_adaptation.sh"

# Test mode flag
export TEST_MODE=true

# Stub log functions if not defined
if ! declare -f log_info &>/dev/null; then
    log_info() { echo "[INFO] $*" >&2; }
fi
if ! declare -f log_warning &>/dev/null; then
    log_warning() { echo "[WARNING] $*" >&2; }
fi
if ! declare -f log_error &>/dev/null; then
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results array
declare -a TEST_RESULTS=()

#######################################
# Run a test case
# Arguments:
#   $1 - Test name
#   $2 - Test command
# Returns:
#   0 if test passed, 1 if failed
#######################################
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_RUN++)) || true
    
    if eval "${test_command}" &>/dev/null; then
        ((TESTS_PASSED++)) || true
        TEST_RESULTS+=("✓ PASS: ${test_name}")
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++)) || true
        TEST_RESULTS+=("✗ FAIL: ${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        return 0  # Don't fail the script
    fi
}

#######################################
# Test: Configuration file exists
#######################################
test_config_file_exists() {
    [[ -f "${STEP_RELEVANCE_CONFIG}" ]]
}

#######################################
# Test: Configuration validation passes
#######################################
test_config_validation() {
    validate_step_relevance 2>/dev/null
}

#######################################
# Test: Get step relevance for shell automation
#######################################
test_get_relevance_shell_automation() {
    PRIMARY_KIND="shell_script_automation"
    local relevance
    relevance=$(get_step_relevance "step_03_script_refs")
    [[ "${relevance}" == "required" ]]
}

#######################################
# Test: Get step relevance for Node.js API
#######################################
test_get_relevance_nodejs_api() {
    PRIMARY_KIND="nodejs_api"
    local relevance
    relevance=$(get_step_relevance "step_03_script_refs")
    [[ "${relevance}" == "skip" ]]
}

#######################################
# Test: Get step relevance for optional step
#######################################
test_get_relevance_optional() {
    PRIMARY_KIND="static_website"
    local relevance
    relevance=$(get_step_relevance "step_08_dependencies")
    [[ "${relevance}" == "optional" ]]
}

#######################################
# Test: Get step relevance with fallback to generic
#######################################
test_get_relevance_fallback() {
    PRIMARY_KIND="unknown_kind"
    local relevance
    relevance=$(get_step_relevance "step_00_analyze")
    [[ -n "${relevance}" ]]
}

#######################################
# Test: Should execute required step
#######################################
test_should_execute_required() {
    PRIMARY_KIND="shell_script_automation"
    should_execute_step "step_00_analyze"
}

#######################################
# Test: Should execute recommended step
#######################################
test_should_execute_recommended() {
    PRIMARY_KIND="shell_script_automation"
    unset SKIP_STEPS
    should_execute_step "step_04_directory"
}

#######################################
# Test: Should skip when user skips recommended
#######################################
test_should_skip_recommended_user() {
    PRIMARY_KIND="shell_script_automation"
    SKIP_STEPS=("step_04_directory")
    ! should_execute_step "step_04_directory"
}

#######################################
# Test: Should skip irrelevant step
#######################################
test_should_skip_irrelevant() {
    PRIMARY_KIND="nodejs_api"
    ! should_execute_step "step_03_script_refs"
}

#######################################
# Test: Should include optional when explicitly included
#######################################
test_should_include_optional() {
    PRIMARY_KIND="static_website"
    INCLUDE_STEPS=("step_07_test_exec")
    should_execute_step "step_07_test_exec"
}

#######################################
# Test: Should skip optional when not included
#######################################
test_should_skip_optional() {
    PRIMARY_KIND="static_website"
    unset INCLUDE_STEPS
    ! should_execute_step "step_07_test_exec"
}

#######################################
# Test: Get step adaptations for Node.js API
#######################################
test_get_adaptations_nodejs_api() {
    PRIMARY_KIND="nodejs_api"
    local adaptations
    adaptations=$(get_step_adaptations "step_05_test_review")
    [[ -n "${adaptations}" ]]
}

#######################################
# Test: Get adaptation value - minimum coverage
#######################################
test_get_adaptation_value() {
    PRIMARY_KIND="nodejs_api"
    local min_coverage
    min_coverage=$(get_adaptation_value "step_05_test_review" "minimum_coverage")
    [[ "${min_coverage}" == "80" ]]
}

#######################################
# Test: Get adaptation value with default
#######################################
test_get_adaptation_value_default() {
    PRIMARY_KIND="nodejs_api"
    local value
    value=$(get_adaptation_value "step_05_test_review" "nonexistent_key" "" "default_value")
    [[ "${value}" == "default_value" ]]
}

#######################################
# Test: List step adaptations
#######################################
test_list_adaptations() {
    PRIMARY_KIND="nodejs_api"
    local adaptations
    adaptations=$(list_step_adaptations "step_05_test_review")
    [[ -n "${adaptations}" ]]
}

#######################################
# Test: Get required steps
#######################################
test_get_required_steps() {
    PRIMARY_KIND="shell_script_automation"
    local required_steps
    required_steps=$(get_required_steps)
    [[ -n "${required_steps}" ]]
    echo "${required_steps}" | grep -q "step_00_analyze"
}

#######################################
# Test: Get skippable steps
#######################################
test_get_skippable_steps() {
    PRIMARY_KIND="nodejs_api"
    local skippable
    skippable=$(get_skippable_steps)
    [[ -n "${skippable}" ]]
    echo "${skippable}" | grep -q "step_03_script_refs"
}

#######################################
# Test: Relevance caching works
#######################################
test_relevance_caching() {
    PRIMARY_KIND="nodejs_api"
    # First call
    local relevance1
    relevance1=$(get_step_relevance "step_08_dependencies")
    # Second call (should be cached)
    local relevance2
    relevance2=$(get_step_relevance "step_08_dependencies")
    [[ "${relevance1}" == "${relevance2}" ]]
}

#######################################
# Test: Adaptations caching works
#######################################
test_adaptations_caching() {
    PRIMARY_KIND="nodejs_api"
    # First call
    local adapt1
    adapt1=$(get_step_adaptations "step_09_code_quality")
    # Second call (should be cached)
    local adapt2
    adapt2=$(get_step_adaptations "step_09_code_quality")
    [[ "${adapt1}" == "${adapt2}" ]]
}

#######################################
# Test: Python app dependencies check
#######################################
test_python_dependencies() {
    PRIMARY_KIND="python_app"
    local relevance
    relevance=$(get_step_relevance "step_08_dependencies")
    [[ "${relevance}" == "required" ]]
}

#######################################
# Test: React SPA code quality
#######################################
test_react_code_quality() {
    PRIMARY_KIND="react_spa"
    local relevance
    relevance=$(get_step_relevance "step_09_code_quality")
    [[ "${relevance}" == "required" ]]
}

#######################################
# Test: Static website test execution
#######################################
test_static_website_tests() {
    PRIMARY_KIND="static_website"
    local relevance
    relevance=$(get_step_relevance "step_06_test_gen")
    [[ "${relevance}" == "skip" ]]
}

#######################################
# Test: Generic project fallback
#######################################
test_generic_fallback() {
    PRIMARY_KIND="generic"
    local relevance
    relevance=$(get_step_relevance "step_00_analyze")
    [[ "${relevance}" == "required" ]]
}

#######################################
# Test: Display execution plan doesn't crash
#######################################
test_display_execution_plan() {
    PRIMARY_KIND="nodejs_api"
    display_execution_plan >/dev/null 2>&1
}

#######################################
# Main test runner
#######################################
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Step Adaptation Module - Test Suite                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Configuration tests
    echo "Testing Configuration..."
    run_test "Configuration file exists" "test_config_file_exists"
    run_test "Configuration validation" "test_config_validation"
    echo ""
    
    # Get relevance tests
    echo "Testing Step Relevance..."
    run_test "Get relevance for shell automation" "test_get_relevance_shell_automation"
    run_test "Get relevance for Node.js API" "test_get_relevance_nodejs_api"
    run_test "Get relevance for optional step" "test_get_relevance_optional"
    run_test "Get relevance with fallback" "test_get_relevance_fallback"
    echo ""
    
    # Should execute tests
    echo "Testing Step Execution Logic..."
    run_test "Should execute required step" "test_should_execute_required"
    run_test "Should execute recommended step" "test_should_execute_recommended"
    run_test "Should skip recommended when user skips" "test_should_skip_recommended_user"
    run_test "Should skip irrelevant step" "test_should_skip_irrelevant"
    run_test "Should include optional when explicitly included" "test_should_include_optional"
    run_test "Should skip optional when not included" "test_should_skip_optional"
    echo ""
    
    # Adaptations tests
    echo "Testing Step Adaptations..."
    run_test "Get adaptations for Node.js API" "test_get_adaptations_nodejs_api"
    run_test "Get adaptation value" "test_get_adaptation_value"
    run_test "Get adaptation value with default" "test_get_adaptation_value_default"
    run_test "List step adaptations" "test_list_adaptations"
    echo ""
    
    # Required/skippable steps tests
    echo "Testing Required/Skippable Steps..."
    run_test "Get required steps" "test_get_required_steps"
    run_test "Get skippable steps" "test_get_skippable_steps"
    echo ""
    
    # Caching tests
    echo "Testing Caching..."
    run_test "Relevance caching works" "test_relevance_caching"
    run_test "Adaptations caching works" "test_adaptations_caching"
    echo ""
    
    # Project kind specific tests
    echo "Testing Project Kind Specific Logic..."
    run_test "Python app dependencies" "test_python_dependencies"
    run_test "React SPA code quality" "test_react_code_quality"
    run_test "Static website test execution" "test_static_website_tests"
    run_test "Generic project fallback" "test_generic_fallback"
    echo ""
    
    # Display tests
    echo "Testing Display Functions..."
    run_test "Display execution plan" "test_display_execution_plan"
    echo ""
    
    # Summary
    echo "════════════════════════════════════════════════════════════"
    echo "Test Summary:"
    echo "  Total:  ${TESTS_RUN}"
    echo "  Passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo "  Failed: ${RED}${TESTS_FAILED}${NC}"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    if [[ ${TESTS_FAILED} -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo ""
        echo "Failed tests:"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ "${result}" =~ ^✗ ]]; then
                echo "  ${result}"
            fi
        done
        return 1
    fi
}

# Run tests
main "$@"
