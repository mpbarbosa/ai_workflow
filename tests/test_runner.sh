#!/bin/bash
set -euo pipefail

################################################################################
# Test Runner - Automated Test Execution Harness
# Purpose: Execute all test suites and generate consolidated reports
# Usage: ./tests/test_runner.sh [--unit|--integration|--all] [--verbose]
################################################################################

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Default options
TEST_TYPE="all"
VERBOSE=false
CONTINUE_ON_FAILURE=false
GENERATE_REPORT=true

# Test results
declare -a PASSED_TESTS=()
declare -a FAILED_TESTS=()
declare -a SKIPPED_TESTS=()

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Usage message
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --unit              Run only unit tests
    --integration       Run only integration tests
    --all               Run all tests (default)
    --verbose, -v       Enable verbose output
    --continue          Continue on test failure
    --no-report         Skip report generation
    -h, --help          Show this help message

EXAMPLES:
    # Run all tests
    $0

    # Run only unit tests with verbose output
    $0 --unit --verbose

    # Run all tests and continue on failures
    $0 --continue

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --unit)
                TEST_TYPE="unit"
                shift
                ;;
            --integration)
                TEST_TYPE="integration"
                shift
                ;;
            --all)
                TEST_TYPE="all"
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --continue)
                CONTINUE_ON_FAILURE=true
                shift
                ;;
            --no-report)
                GENERATE_REPORT=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Print functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Run a single test file
run_test() {
    local test_file="$1"
    local test_name="$(basename "${test_file}" .sh)"
    
    if [[ ! -x "${test_file}" ]]; then
        chmod +x "${test_file}"
    fi
    
    echo -e "\n${BLUE}Running: ${test_name}${NC}"
    
    if [[ "${VERBOSE}" == true ]]; then
        if bash "${test_file}"; then
            print_success "${test_name} passed"
            PASSED_TESTS+=("${test_name}")
            return 0
        else
            print_error "${test_name} failed"
            FAILED_TESTS+=("${test_name}")
            return 1
        fi
    else
        local output
        if output=$(bash "${test_file}" 2>&1); then
            print_success "${test_name} passed"
            PASSED_TESTS+=("${test_name}")
            return 0
        else
            print_error "${test_name} failed"
            FAILED_TESTS+=("${test_name}")
            if [[ -n "${output}" ]]; then
                echo "${output}" | sed 's/^/  /'
            fi
            return 1
        fi
    fi
}

# Run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"
    
    local unit_test_dir="${SCRIPT_DIR}/unit"
    if [[ ! -d "${unit_test_dir}" ]]; then
        print_warning "Unit test directory not found: ${unit_test_dir}"
        return 0
    fi
    
    local test_files=($(find "${unit_test_dir}" -name "test_*.sh" -type f | sort))
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        print_warning "No unit tests found in ${unit_test_dir}"
        return 0
    fi
    
    print_info "Found ${#test_files[@]} unit test(s)"
    
    for test_file in "${test_files[@]}"; do
        if ! run_test "${test_file}"; then
            if [[ "${CONTINUE_ON_FAILURE}" == false ]]; then
                return 1
            fi
        fi
    done
    
    return 0
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"
    
    local integration_test_dir="${SCRIPT_DIR}/integration"
    if [[ ! -d "${integration_test_dir}" ]]; then
        print_warning "Integration test directory not found: ${integration_test_dir}"
        return 0
    fi
    
    local test_files=($(find "${integration_test_dir}" -name "test_*.sh" -type f | sort))
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        print_warning "No integration tests found in ${integration_test_dir}"
        return 0
    fi
    
    print_info "Found ${#test_files[@]} integration test(s)"
    
    for test_file in "${test_files[@]}"; do
        if ! run_test "${test_file}"; then
            if [[ "${CONTINUE_ON_FAILURE}" == false ]]; then
                return 1
            fi
        fi
    done
    
    return 0
}

# Generate test report
generate_report() {
    local total=$((${#PASSED_TESTS[@]} + ${#FAILED_TESTS[@]} + ${#SKIPPED_TESTS[@]}))
    local pass_rate=0
    
    if [[ ${total} -gt 0 ]]; then
        pass_rate=$(( (${#PASSED_TESTS[@]} * 100) / total ))
    fi
    
    print_header "Test Results Summary"
    
    echo "Total Tests:   ${total}"
    echo -e "${GREEN}Passed:        ${#PASSED_TESTS[@]}${NC}"
    echo -e "${RED}Failed:        ${#FAILED_TESTS[@]}${NC}"
    echo -e "${YELLOW}Skipped:       ${#SKIPPED_TESTS[@]}${NC}"
    echo "Pass Rate:     ${pass_rate}%"
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo -e "\n${RED}Failed Tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - ${test}"
        done
    fi
    
    # Save report to file
    if [[ "${GENERATE_REPORT}" == true ]]; then
        local report_dir="${PROJECT_ROOT}/test-results"
        mkdir -p "${report_dir}"
        local report_file="${report_dir}/test_report_$(date +%Y%m%d_%H%M%S).txt"
        
        {
            echo "================================================================================"
            echo "TEST EXECUTION REPORT"
            echo "================================================================================"
            echo "Date:          $(date '+%Y-%m-%d %H:%M:%S')"
            echo "Test Type:     ${TEST_TYPE}"
            echo "Total Tests:   ${total}"
            echo "Passed:        ${#PASSED_TESTS[@]}"
            echo "Failed:        ${#FAILED_TESTS[@]}"
            echo "Skipped:       ${#SKIPPED_TESTS[@]}"
            echo "Pass Rate:     ${pass_rate}%"
            echo ""
            
            if [[ ${#PASSED_TESTS[@]} -gt 0 ]]; then
                echo "Passed Tests:"
                for test in "${PASSED_TESTS[@]}"; do
                    echo "  ✓ ${test}"
                done
                echo ""
            fi
            
            if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
                echo "Failed Tests:"
                for test in "${FAILED_TESTS[@]}"; do
                    echo "  ✗ ${test}"
                done
                echo ""
            fi
            
            if [[ ${#SKIPPED_TESTS[@]} -gt 0 ]]; then
                echo "Skipped Tests:"
                for test in "${SKIPPED_TESTS[@]}"; do
                    echo "  ○ ${test}"
                done
            fi
        } > "${report_file}"
        
        print_info "Report saved to: ${report_file}"
    fi
}

# Main execution
main() {
    parse_args "$@"
    
    print_header "Test Runner - AI Workflow Automation"
    print_info "Test Type: ${TEST_TYPE}"
    print_info "Project Root: ${PROJECT_ROOT}"
    
    local all_passed=true
    
    case "${TEST_TYPE}" in
        unit)
            if ! run_unit_tests; then
                all_passed=false
            fi
            ;;
        integration)
            if ! run_integration_tests; then
                all_passed=false
            fi
            ;;
        all)
            if ! run_unit_tests; then
                all_passed=false
            fi
            if ! run_integration_tests; then
                all_passed=false
            fi
            ;;
    esac
    
    generate_report
    
    if [[ "${all_passed}" == true ]] && [[ ${#FAILED_TESTS[@]} -eq 0 ]]; then
        print_success "\nAll tests passed!"
        exit 0
    else
        print_error "\nSome tests failed!"
        exit 1
    fi
}

main "$@"
