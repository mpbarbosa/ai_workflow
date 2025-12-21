#!/bin/bash
################################################################################
# Module Testing Script
# Purpose: Verify all extracted modules are syntactically correct and functional
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

set -uo pipefail

# Set non-interactive mode to prevent blocking on stdin
export AUTO_MODE=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/../.."
LIB_DIR="${PROJECT_ROOT}/src/workflow/lib"
STEPS_DIR="${PROJECT_ROOT}/src/workflow/steps"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    print_info "Testing: $test_name"
    
    if eval "$test_command" &> /dev/null; then
        print_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_error "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ==============================================================================
# PHASE 1: SYNTAX VALIDATION
# ==============================================================================

print_header "Phase 1: Module Syntax Validation"

if [[ -d "$LIB_DIR" ]]; then
    print_info "Testing library modules in: $LIB_DIR"
    
    for lib_file in "$LIB_DIR"/*.sh; do
        if [[ -f "$lib_file" ]]; then
            filename=$(basename "$lib_file")
            run_test "Syntax check: $filename" "bash -n '$lib_file'"
        fi
    done
else
    print_error "Library directory not found: $LIB_DIR"
    exit 1
fi

if [[ -d "$STEPS_DIR" ]]; then
    print_info "Testing step modules in: $STEPS_DIR"
    
    for step_file in "$STEPS_DIR"/*.sh; do
        if [[ -f "$step_file" ]]; then
            filename=$(basename "$step_file")
            run_test "Syntax check: $filename" "bash -n '$step_file'"
        fi
    done
else
    print_info "Steps directory not found: $STEPS_DIR (expected - Phase 2 pending)"
fi

# ==============================================================================
# PHASE 2: MODULE SOURCING TESTS
# ==============================================================================

print_header "Phase 2: Module Sourcing Tests"

# Test 1: Source config module
run_test "Source config.sh" "source '$LIB_DIR/config.sh' && [[ -n \"\${SCRIPT_VERSION:-}\" ]]"

# Test 2: Source colors module
run_test "Source colors.sh" "source '$LIB_DIR/colors.sh' && [[ -n \"\${GREEN:-}\" ]]"

# Test 3: Source utils module (depends on colors)
run_test "Source utils.sh" "source '$LIB_DIR/colors.sh' && source '$LIB_DIR/utils.sh' && declare -F print_success > /dev/null"

# Test 4: Source git_cache module (depends on colors, utils, config)
run_test "Source git_cache.sh" "
    PROJECT_ROOT='/tmp' && \
    source '$LIB_DIR/colors.sh' && \
    source '$LIB_DIR/config.sh' && \
    source '$LIB_DIR/utils.sh' && \
    source '$LIB_DIR/git_cache.sh' && \
    declare -F init_git_cache > /dev/null
"

# Test 5: Source validation module
run_test "Source validation.sh" "
    PROJECT_ROOT='/tmp' && \
    source '$LIB_DIR/colors.sh' && \
    source '$LIB_DIR/config.sh' && \
    source '$LIB_DIR/utils.sh' && \
    source '$LIB_DIR/validation.sh' && \
    declare -F check_prerequisites > /dev/null
"

# Test 6: Source backlog module
run_test "Source backlog.sh" "
    PROJECT_ROOT='/tmp' && \
    source '$LIB_DIR/colors.sh' && \
    source '$LIB_DIR/config.sh' && \
    source '$LIB_DIR/utils.sh' && \
    source '$LIB_DIR/backlog.sh' && \
    declare -F create_workflow_summary > /dev/null
"

# Test 7: Source summary module
run_test "Source summary.sh" "
    source '$LIB_DIR/colors.sh' && \
    source '$LIB_DIR/summary.sh' && \
    declare -F determine_step_status > /dev/null
"

# Test 8: Source ai_helpers module
run_test "Source ai_helpers.sh" "
    source '$LIB_DIR/colors.sh' && \
    source '$LIB_DIR/utils.sh' && \
    source '$LIB_DIR/ai_helpers.sh' && \
    declare -F is_copilot_available > /dev/null
"

# ==============================================================================
# PHASE 3: FUNCTION AVAILABILITY TESTS
# ==============================================================================

print_header "Phase 3: Function Availability Tests"

# Create temporary test environment
export PROJECT_ROOT="/tmp/workflow_test_$$"
mkdir -p "$PROJECT_ROOT"

# Source all modules in correct order
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/git_cache.sh"
source "$LIB_DIR/validation.sh"
source "$LIB_DIR/backlog.sh"
source "$LIB_DIR/summary.sh"
source "$LIB_DIR/ai_helpers.sh"

# Test utility functions
run_test "Function: print_header" "declare -F print_header > /dev/null"
run_test "Function: print_success" "declare -F print_success > /dev/null"
run_test "Function: print_error" "declare -F print_error > /dev/null"
run_test "Function: print_warning" "declare -F print_warning > /dev/null"
run_test "Function: print_info" "declare -F print_info > /dev/null"
run_test "Function: print_step" "declare -F print_step > /dev/null"
run_test "Function: save_step_issues" "declare -F save_step_issues > /dev/null"
run_test "Function: save_step_summary" "declare -F save_step_summary > /dev/null"
run_test "Function: confirm_action" "declare -F confirm_action > /dev/null"
run_test "Function: cleanup" "declare -F cleanup > /dev/null"
run_test "Function: update_workflow_status" "declare -F update_workflow_status > /dev/null"
run_test "Function: show_progress" "declare -F show_progress > /dev/null"

# Test git cache functions
run_test "Function: init_git_cache" "declare -F init_git_cache > /dev/null"
run_test "Function: get_git_modified_count" "declare -F get_git_modified_count > /dev/null"
run_test "Function: get_git_current_branch" "declare -F get_git_current_branch > /dev/null"
run_test "Function: get_git_status_output" "declare -F get_git_status_output > /dev/null"
run_test "Function: is_deps_modified" "declare -F is_deps_modified > /dev/null"
run_test "Function: is_git_repo" "declare -F is_git_repo > /dev/null"

# Test validation functions
run_test "Function: check_prerequisites" "declare -F check_prerequisites > /dev/null"
run_test "Function: validate_dependencies" "declare -F validate_dependencies > /dev/null"

# Test backlog functions
run_test "Function: create_workflow_summary" "declare -F create_workflow_summary > /dev/null"

# Test summary functions
run_test "Function: determine_step_status" "declare -F determine_step_status > /dev/null"
run_test "Function: format_step_summary" "declare -F format_step_summary > /dev/null"
run_test "Function: create_progress_summary" "declare -F create_progress_summary > /dev/null"
run_test "Function: generate_step_stats" "declare -F generate_step_stats > /dev/null"
run_test "Function: aggregate_summaries" "declare -F aggregate_summaries > /dev/null"

# Test AI helper functions
run_test "Function: is_copilot_available" "declare -F is_copilot_available > /dev/null"
run_test "Function: validate_copilot_cli" "declare -F validate_copilot_cli > /dev/null"
run_test "Function: build_ai_prompt" "declare -F build_ai_prompt > /dev/null"
run_test "Function: build_doc_analysis_prompt" "declare -F build_doc_analysis_prompt > /dev/null"
run_test "Function: execute_copilot_prompt" "declare -F execute_copilot_prompt > /dev/null"
run_test "Function: trigger_ai_step" "declare -F trigger_ai_step > /dev/null"

# Cleanup
rm -rf "$PROJECT_ROOT"

# ==============================================================================
# PHASE 4: VARIABLE EXPORT TESTS
# ==============================================================================

print_header "Phase 4: Variable Export Tests"

run_test "Variable: SCRIPT_VERSION" "[[ -n \"\${SCRIPT_VERSION:-}\" ]]"
run_test "Variable: SCRIPT_NAME" "[[ -n \"\${SCRIPT_NAME:-}\" ]]"
run_test "Variable: PROJECT_ROOT" "[[ -n \"\${PROJECT_ROOT:-}\" ]]"
run_test "Variable: RED" "[[ -n \"\${RED:-}\" ]]"
run_test "Variable: GREEN" "[[ -n \"\${GREEN:-}\" ]]"
run_test "Variable: NC" "[[ -n \"\${NC:-}\" ]]"

# ==============================================================================
# FINAL REPORT
# ==============================================================================

print_header "Test Results Summary"

echo -e "${CYAN}Tests Run:${NC}     $TESTS_RUN"
echo -e "${GREEN}Tests Passed:${NC}  $TESTS_PASSED"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Tests Failed:${NC}  $TESTS_FAILED"
    echo ""
    print_error "Some tests failed. Please review the output above."
    exit 1
else
    echo -e "${GREEN}Tests Failed:${NC}  $TESTS_FAILED"
    echo ""
    print_success "All tests passed! Modules are ready for integration."
    exit 0
fi
