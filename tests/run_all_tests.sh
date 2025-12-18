#!/usr/bin/env bash
################################################################################
# Test Runner - AI Workflow Automation
################################################################################
# Description: Comprehensive test runner for all unit and integration tests
# Version: 1.0.0
# Date: 2025-12-18
################################################################################

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly UNIT_TEST_DIR="${SCRIPT_DIR}/unit"
readonly INTEGRATION_TEST_DIR="${SCRIPT_DIR}/integration"

# Test results
declare -a PASSED_TESTS=()
declare -a FAILED_TESTS=()
declare -a SKIPPED_TESTS=()

################################################################################
# Functions
################################################################################

print_header() {
    local title="$1"
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}${title}${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

print_section() {
    local title="$1"
    echo -e "\n${BLUE}▶ ${BOLD}${title}${RESET}"
    echo -e "${BLUE}$(printf '─%.0s' {1..70})${RESET}\n"
}

run_test_file() {
    local test_file="$1"
    local test_name="$(basename "${test_file}")"
    
    echo -e "${CYAN}Running:${RESET} ${test_name}"
    
    # Check if test file is executable
    if [[ ! -x "${test_file}" ]]; then
        chmod +x "${test_file}"
    fi
    
    # Run test and capture output
    local output
    local exit_code
    
    if output=$("${test_file}" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Check results
    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "  ${GREEN}✓ PASSED${RESET}"
        PASSED_TESTS+=("${test_name}")
    else
        echo -e "  ${RED}✗ FAILED${RESET} (exit code: ${exit_code})"
        echo -e "${YELLOW}Output:${RESET}"
        echo "${output}" | sed 's/^/    /'
        FAILED_TESTS+=("${test_name}")
    fi
    
    echo ""
}

run_test_suite() {
    local suite_name="$1"
    local test_dir="$2"
    
    print_section "${suite_name}"
    
    if [[ ! -d "${test_dir}" ]]; then
        echo -e "${YELLOW}⚠ Directory not found: ${test_dir}${RESET}"
        return 0
    fi
    
    local test_files=($(find "${test_dir}" -maxdepth 1 -name "test_*.sh" -type f | sort))
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No test files found in ${test_dir}${RESET}"
        return 0
    fi
    
    echo -e "Found ${#test_files[@]} test file(s)\n"
    
    for test_file in "${test_files[@]}"; do
        run_test_file "${test_file}"
    done
}

print_summary() {
    local total=$((${#PASSED_TESTS[@]} + ${#FAILED_TESTS[@]} + ${#SKIPPED_TESTS[@]}))
    
    print_header "Test Summary"
    
    echo -e "${BOLD}Results:${RESET}"
    echo -e "  Total Tests:  ${total}"
    echo -e "  ${GREEN}✓ Passed:${RESET}     ${#PASSED_TESTS[@]}"
    echo -e "  ${RED}✗ Failed:${RESET}     ${#FAILED_TESTS[@]}"
    
    if [[ ${#SKIPPED_TESTS[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}⊘ Skipped:${RESET}    ${#SKIPPED_TESTS[@]}"
    fi
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo -e "\n${RED}${BOLD}Failed Tests:${RESET}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${RESET} ${test}"
        done
    fi
    
    echo ""
    
    # Return exit code based on failures
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Run all tests for AI Workflow Automation

OPTIONS:
    -h, --help              Show this help message
    -u, --unit              Run only unit tests
    -i, --integration       Run only integration tests
    -v, --verbose           Verbose output
    -f, --fail-fast         Stop on first failure

EXAMPLES:
    # Run all tests
    ./run_all_tests.sh

    # Run only unit tests
    ./run_all_tests.sh --unit

    # Run only integration tests
    ./run_all_tests.sh --integration

    # Stop on first failure
    ./run_all_tests.sh --fail-fast

EOF
}

################################################################################
# Main Execution
################################################################################

main() {
    local run_unit=true
    local run_integration=true
    local fail_fast=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -u|--unit)
                run_integration=false
                shift
                ;;
            -i|--integration)
                run_unit=false
                shift
                ;;
            -f|--fail-fast)
                fail_fast=true
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${RESET}" >&2
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Change to project root
    cd "${PROJECT_ROOT}"
    
    print_header "AI Workflow Automation - Test Suite"
    
    echo -e "${BOLD}Configuration:${RESET}"
    echo -e "  Project Root:      ${PROJECT_ROOT}"
    echo -e "  Unit Tests:        ${UNIT_TEST_DIR}"
    echo -e "  Integration Tests: ${INTEGRATION_TEST_DIR}"
    
    # Run test suites
    if [[ "${run_unit}" == true ]]; then
        run_test_suite "Unit Tests" "${UNIT_TEST_DIR}"
        
        if [[ "${fail_fast}" == true ]] && [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
            print_summary
            exit 1
        fi
    fi
    
    if [[ "${run_integration}" == true ]]; then
        run_test_suite "Integration Tests" "${INTEGRATION_TEST_DIR}"
        
        if [[ "${fail_fast}" == true ]] && [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
            print_summary
            exit 1
        fi
    fi
    
    # Print summary and exit
    if print_summary; then
        echo -e "${GREEN}${BOLD}All tests passed!${RESET}\n"
        exit 0
    else
        echo -e "${RED}${BOLD}Some tests failed.${RESET}\n"
        exit 1
    fi
}

# Run main function
main "$@"
