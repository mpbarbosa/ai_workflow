#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 01 Refactoring Validation Tests
# Purpose: Verify backward compatibility and module integration
# Version: 1.0.0
################################################################################

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper functions
print_test_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

print_test_result() {
    local test_name="$1"
    local result="$2"
    
    ((TESTS_RUN++)) || true
    
    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++)) || true
    else
        echo -e "${RED}✗${NC} $test_name"
        ((TESTS_FAILED++)) || true
    fi
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP1_DIR="${SCRIPT_DIR}/steps"

# Mock functions for testing (replace print functions)
print_section() { echo "[SECTION] $*"; }
print_info() { echo "[INFO] $*"; }
print_success() { echo "[SUCCESS] $*"; }
print_warning() { echo "[WARNING] $*"; }
print_error() { echo "[ERROR] $*"; }
prompt_for_continuation() { return 0; }

export -f print_section print_info print_success print_warning print_error prompt_for_continuation

# ==============================================================================
# TEST SUITE 1: MODULE LOADING
# ==============================================================================

test_module_loading() {
    print_test_header "Module Loading Tests"
    
    # Test 1: Main step script loads
    if source "${STEP1_DIR}/step_01_documentation.sh" 2>/dev/null; then
        print_test_result "Main step script loads" "PASS"
    else
        print_test_result "Main step script loads" "FAIL"
        return 1
    fi
    
    # Test 2: Cache module functions available
    if declare -F init_step1_cache >/dev/null 2>&1; then
        print_test_result "Cache module loaded" "PASS"
    else
        print_test_result "Cache module loaded" "FAIL"
    fi
    
    # Test 3: File operations module functions available
    if declare -F determine_doc_folder_step1 >/dev/null 2>&1; then
        print_test_result "File operations module loaded" "PASS"
    else
        print_test_result "File operations module loaded" "FAIL"
    fi
    
    # Test 4: Validation module functions available
    if declare -F validate_documentation_file_counts_step1 >/dev/null 2>&1; then
        print_test_result "Validation module loaded" "PASS"
    else
        print_test_result "Validation module loaded" "FAIL"
    fi
    
    # Test 5: AI integration module functions available
    if declare -F check_copilot_available_step1 >/dev/null 2>&1; then
        print_test_result "AI integration module loaded" "PASS"
    else
        print_test_result "AI integration module loaded" "FAIL"
    fi
}

# ==============================================================================
# TEST SUITE 2: BACKWARD COMPATIBILITY
# ==============================================================================

test_backward_compatibility() {
    print_test_header "Backward Compatibility Tests"
    
    # Source the main script
    source "${STEP1_DIR}/step_01_documentation.sh" 2>/dev/null || true
    
    # Test backward compat aliases exist
    local aliases=(
        "init_performance_cache"
        "get_or_cache"
        "get_cached_git_diff"
        "batch_file_check"
        "determine_doc_folder"
        "save_ai_generated_docs"
        "validate_documentation_file_counts"
        "validate_submodule_cross_references"
        "check_copilot_available"
        "build_documentation_prompt"
        "execute_ai_documentation_analysis"
    )
    
    for alias in "${aliases[@]}"; do
        if declare -F "$alias" >/dev/null 2>&1; then
            print_test_result "Backward compat alias: $alias" "PASS"
        else
            print_test_result "Backward compat alias: $alias" "FAIL"
        fi
    done
}

# ==============================================================================
# TEST SUITE 3: VERSION INFORMATION
# ==============================================================================

test_version_info() {
    print_test_header "Version Information Tests"
    
    source "${STEP1_DIR}/step_01_documentation.sh" 2>/dev/null || true
    
    # Test version constants exist
    if [[ -n "${STEP1_VERSION:-}" ]]; then
        print_test_result "STEP1_VERSION defined: $STEP1_VERSION" "PASS"
    else
        print_test_result "STEP1_VERSION defined" "FAIL"
    fi
    
    # Test version function
    if step1_get_version --format=simple >/dev/null 2>&1; then
        print_test_result "step1_get_version function works" "PASS"
    else
        print_test_result "step1_get_version function works" "FAIL"
    fi
    
    # Test version is 2.0.0
    local version
    version=$(step1_get_version --format=simple)
    if [[ "$version" == "2.0.0" ]]; then
        print_test_result "Version is 2.0.0" "PASS"
    else
        print_test_result "Version is 2.0.0 (got: $version)" "FAIL"
    fi
}

# ==============================================================================
# TEST SUITE 4: FUNCTION AVAILABILITY
# ==============================================================================

test_function_availability() {
    print_test_header "Function Availability Tests"
    
    source "${STEP1_DIR}/step_01_documentation.sh" 2>/dev/null || true
    
    # Core functions
    local functions=(
        "step1_update_documentation"
        "test_documentation_consistency"
        "parallel_file_analysis"
    )
    
    for func in "${functions[@]}"; do
        if declare -F "$func" >/dev/null 2>&1; then
            print_test_result "Function exists: $func" "PASS"
        else
            print_test_result "Function exists: $func" "FAIL"
        fi
    done
}

# ==============================================================================
# TEST SUITE 5: MODULE FILE STRUCTURE
# ==============================================================================

test_file_structure() {
    print_test_header "File Structure Tests"
    
    # Check main file exists
    if [[ -f "${STEP1_DIR}/step_01_documentation.sh" ]]; then
        print_test_result "Main step file exists" "PASS"
    else
        print_test_result "Main step file exists" "FAIL"
    fi
    
    # Check sub-module directory exists
    if [[ -d "${STEP1_DIR}/step_01_lib" ]]; then
        print_test_result "Sub-module directory exists" "PASS"
    else
        print_test_result "Sub-module directory exists" "FAIL"
    fi
    
    # Check all sub-modules exist
    local modules=(
        "cache.sh"
        "file_operations.sh"
        "validation.sh"
        "ai_integration.sh"
    )
    
    for module in "${modules[@]}"; do
        if [[ -f "${STEP1_DIR}/step_01_lib/${module}" ]]; then
            print_test_result "Sub-module exists: $module" "PASS"
        else
            print_test_result "Sub-module exists: $module" "FAIL"
        fi
    done
}

# ==============================================================================
# TEST SUITE 6: LINE COUNT VALIDATION
# ==============================================================================

test_line_counts() {
    print_test_header "Line Count Validation (Target: All modules < 350 lines)"
    
    local main_lines
    main_lines=$(wc -l < "${STEP1_DIR}/step_01_documentation.sh")
    
    if [[ $main_lines -lt 400 ]]; then
        print_test_result "Main orchestrator < 400 lines ($main_lines)" "PASS"
    else
        print_test_result "Main orchestrator < 400 lines ($main_lines)" "FAIL"
    fi
    
    # Check sub-modules
    local modules=("cache.sh" "file_operations.sh" "validation.sh" "ai_integration.sh")
    
    for module in "${modules[@]}"; do
        local lines
        lines=$(wc -l < "${STEP1_DIR}/step_01_lib/${module}")
        
        if [[ $lines -lt 350 ]]; then
            print_test_result "$module < 350 lines ($lines)" "PASS"
        else
            print_test_result "$module < 350 lines ($lines)" "FAIL"
        fi
    done
}

# ==============================================================================
# MAIN TEST EXECUTION
# ==============================================================================

main() {
    echo -e "${YELLOW}Step 01 Refactoring Validation Tests${NC}"
    echo "======================================"
    
    # Run all test suites
    test_file_structure
    test_module_loading
    test_backward_compatibility
    test_version_info
    test_function_availability
    test_line_counts
    
    # Print summary
    echo -e "\n${YELLOW}=== Test Summary ===${NC}"
    echo "Tests Run:    $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
        echo ""
        echo -e "${RED}❌ VALIDATION FAILED${NC}"
        return 1
    else
        echo "Tests Failed: 0"
        echo ""
        echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
        return 0
    fi
}

# Run tests
main "$@"
