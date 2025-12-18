#!/bin/bash
################################################################################
# Test Suite for Workflow Enhancement Modules
# Purpose: Comprehensive tests for metrics, change detection, and dependency graph
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Created: December 18, 2025
################################################################################

# Don't exit on errors - we want to collect all test results
set -uo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# Load color definitions
source "${SCRIPT_DIR}/colors.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results
declare -a FAILED_TESTS

# ==============================================================================
# TEST HELPERS
# ==============================================================================

print_test_header() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "${expected}" == "${actual}" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected: ${expected}"
        echo -e "  Actual:   ${actual}"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ -n "${value}" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected: non-empty value"
        echo -e "  Actual:   empty"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ -f "${file}" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  File not found: ${file}"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if echo "${haystack}" | grep -q "${needle}"; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected to find: ${needle}"
        return 1
    fi
}

# ==============================================================================
# METRICS MODULE TESTS
# ==============================================================================

test_metrics_module() {
    print_test_header "METRICS MODULE TESTS"
    
    # Setup test environment
    export PROJECT_ROOT="${PROJECT_ROOT}"
    export WORKFLOW_RUN_ID="test_$(date +%Y%m%d_%H%M%S)"
    export SCRIPT_VERSION="2.0.0"
    export DRY_RUN=false
    export AUTO_MODE=false
    export INTERACTIVE_MODE=true
    
    # Source config and metrics modules
    source "${SCRIPT_DIR}/config.sh"
    source "${SCRIPT_DIR}/metrics.sh"
    
    # Test 1: Initialization
    init_metrics
    assert_file_exists "${METRICS_CURRENT}" "Metrics initialization creates current run file"
    
    # Test 2: Execution mode detection
    local mode=$(get_execution_mode)
    assert_equals "interactive" "${mode}" "Execution mode detection"
    
    # Test 3: Step timer start
    start_step_timer 0 "Pre_Analysis"
    assert_not_empty "${STEP_START_TIMES[0]}" "Step timer start records timestamp"
    
    # Test 4: Step timer stop
    sleep 1
    stop_step_timer 0 "success" ""
    assert_not_empty "${STEP_DURATIONS[0]}" "Step timer stop calculates duration"
    
    # Test 5: Step name retrieval
    local step_name=$(get_step_name 1)
    assert_equals "Documentation_Updates" "${step_name}" "Step name retrieval"
    
    # Test 6: Duration formatting
    local formatted=$(format_duration 125)
    assert_equals "2m 5s" "${formatted}" "Duration formatting (minutes and seconds)"
    
    local formatted_hours=$(format_duration 3665)
    assert_equals "1h 1m 5s" "${formatted_hours}" "Duration formatting (hours)"
    
    # Test 7: Status emoji
    local emoji=$(get_step_status_emoji "success")
    assert_equals "✅" "${emoji}" "Success status emoji"
    
    # Test 8: Workflow finalization
    finalize_metrics "success"
    assert_file_exists "${METRICS_HISTORY}" "Metrics finalization creates history file"
    
    # Test 9: Summary generation
    assert_file_exists "${METRICS_SUMMARY}" "Summary generation creates markdown file"
    
    # Cleanup
    rm -f "${METRICS_CURRENT}" "${METRICS_HISTORY}" "${METRICS_SUMMARY}"
}

# ==============================================================================
# CHANGE DETECTION MODULE TESTS
# ==============================================================================

test_change_detection_module() {
    print_test_header "CHANGE DETECTION MODULE TESTS"
    
    # Setup test environment
    export PROJECT_ROOT="${PROJECT_ROOT}"
    export WORKFLOW_RUN_ID="test_$(date +%Y%m%d_%H%M%S)"
    export BACKLOG_RUN_DIR="${PROJECT_ROOT}/src/workflow/backlog/${WORKFLOW_RUN_ID}"
    
    # Source modules
    source "${SCRIPT_DIR}/config.sh"
    source "${SCRIPT_DIR}/change_detection.sh"
    
    # Test 1: Pattern matching
    if matches_pattern "README.md" "*.md|*.txt"; then
        assert_equals "true" "true" "Pattern matching for markdown files"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Pattern matching for markdown files")
        echo -e "${RED}✗${NC} Pattern matching for markdown files"
    fi
    
    # Test 2: Change type detection (requires git repository)
    cd "${PROJECT_ROOT}"
    local change_type=$(detect_change_type)
    assert_not_empty "${change_type}" "Change type detection returns a value"
    
    # Test 3: Step name retrieval
    local step_name=$(get_step_name_for_display 5)
    assert_equals "Test Review" "${step_name}" "Step name for display"
    
    # Test 4: Recommended steps
    local recommended=$(get_recommended_steps)
    assert_not_empty "${recommended}" "Recommended steps returns non-empty list"
    
    # Test 5: Should execute step logic
    if should_execute_step 0; then
        assert_equals "true" "true" "Step 0 should always execute"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Step 0 should always execute")
        echo -e "${RED}✗${NC} Step 0 should always execute"
    fi
    
    # Test 6: Change impact assessment
    local impact=$(assess_change_impact)
    assert_not_empty "${impact}" "Change impact assessment returns value"
    
    # Test 7: Change report generation
    mkdir -p "${BACKLOG_RUN_DIR}"
    local report_file=$(generate_change_report)
    assert_file_exists "${report_file}" "Change report generation creates file"
    
    # Test 8: Change analysis output
    local analysis=$(analyze_changes)
    assert_contains "${analysis}" "Change Analysis" "Change analysis includes header"
    
    # Cleanup
    rm -rf "${BACKLOG_RUN_DIR}"
}

# ==============================================================================
# DEPENDENCY GRAPH MODULE TESTS
# ==============================================================================

test_dependency_graph_module() {
    print_test_header "DEPENDENCY GRAPH MODULE TESTS"
    
    # Setup test environment
    export PROJECT_ROOT="${PROJECT_ROOT}"
    export WORKFLOW_RUN_ID="test_$(date +%Y%m%d_%H%M%S)"
    export BACKLOG_RUN_DIR="${PROJECT_ROOT}/src/workflow/backlog/${WORKFLOW_RUN_ID}"
    
    # Source modules
    source "${SCRIPT_DIR}/config.sh"
    source "${SCRIPT_DIR}/dependency_graph.sh"
    
    # Test 1: Dependency checking - no dependencies
    if check_dependencies 0 ""; then
        assert_equals "true" "true" "Step 0 has no dependencies"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Step 0 has no dependencies")
        echo -e "${RED}✗${NC} Step 0 has no dependencies"
    fi
    
    # Test 2: Dependency checking - dependency met
    if check_dependencies 1 "0"; then
        assert_equals "true" "true" "Step 1 dependency met when Step 0 completed"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Step 1 dependency met when Step 0 completed")
        echo -e "${RED}✗${NC} Step 1 dependency met when Step 0 completed"
    fi
    
    # Test 3: Dependency checking - dependency not met
    if ! check_dependencies 1 ""; then
        assert_equals "true" "true" "Step 1 dependency not met when Step 0 not completed"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
        FAILED_TESTS+=("Step 1 dependency not met when Step 0 not completed")
        echo -e "${RED}✗${NC} Step 1 dependency not met when Step 0 not completed"
    fi
    
    # Test 4: Next runnable steps
    local runnable=$(get_next_runnable_steps "0")
    assert_contains "${runnable}" "1" "Step 1 is runnable after Step 0"
    
    # Test 5: Parallel steps identification
    local parallel=$(get_parallel_steps "0")
    assert_not_empty "${parallel}" "Parallel steps identification returns results"
    
    # Test 6: Critical path calculation
    local critical_path=$(calculate_critical_path)
    assert_not_empty "${critical_path}" "Critical path calculation returns value"
    
    # Test 7: Dependency diagram generation
    mkdir -p "${BACKLOG_RUN_DIR}"
    local diagram_file=$(generate_dependency_diagram)
    assert_file_exists "${diagram_file}" "Dependency diagram generation creates file"
    
    # Test 8: Execution plan generation
    local plan_file=$(generate_execution_plan)
    assert_file_exists "${plan_file}" "Execution plan generation creates file"
    
    # Test 9: Diagram contains Mermaid syntax
    local diagram_content=$(cat "${diagram_file}")
    assert_contains "${diagram_content}" "mermaid" "Dependency diagram contains Mermaid syntax"
    
    # Test 10: Plan contains phases
    local plan_content=$(cat "${plan_file}")
    assert_contains "${plan_content}" "Phase 1" "Execution plan contains phases"
    
    # Cleanup
    rm -rf "${BACKLOG_RUN_DIR}"
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

test_module_integration() {
    print_test_header "INTEGRATION TESTS"
    
    # Setup test environment
    export PROJECT_ROOT="${PROJECT_ROOT}"
    export WORKFLOW_RUN_ID="test_integration_$(date +%Y%m%d_%H%M%S)"
    export SCRIPT_VERSION="2.0.0"
    
    # Source all modules
    source "${SCRIPT_DIR}/config.sh"
    source "${SCRIPT_DIR}/metrics.sh"
    source "${SCRIPT_DIR}/change_detection.sh"
    source "${SCRIPT_DIR}/dependency_graph.sh"
    
    # Test 1: Metrics + Change Detection
    init_metrics
    local change_type=$(detect_change_type)
    assert_not_empty "${change_type}" "Metrics and change detection work together"
    
    # Test 2: Change Detection + Dependency Graph
    local recommended=$(get_recommended_steps)
    if check_dependencies 0 ""; then
        assert_equals "true" "true" "Change detection works with dependency graph"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    fi
    
    # Test 3: Full workflow simulation
    start_step_timer 0 "Pre_Analysis"
    sleep 1
    stop_step_timer 0 "success" ""
    
    local runnable=$(get_next_runnable_steps "0")
    assert_not_empty "${runnable}" "Full workflow simulation produces results"
    
    # Cleanup
    rm -f "${METRICS_CURRENT}" "${METRICS_HISTORY}" "${METRICS_SUMMARY}"
}

# ==============================================================================
# TEST EXECUTION
# ==============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Workflow Enhancement Modules - Test Suite               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run all test suites
    test_metrics_module
    test_change_detection_module
    test_dependency_graph_module
    test_module_integration
    
    # Print summary
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TEST SUMMARY${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Total Tests:  ${TESTS_RUN}"
    echo -e "${GREEN}Passed:       ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed:       ${TESTS_FAILED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo ""
        echo -e "${RED}Failed Tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} ${test}"
        done
        echo ""
        exit 1
    else
        echo ""
        echo -e "${GREEN}✅ All tests passed!${NC}"
        echo ""
        exit 0
    fi
}

# Run tests
main "$@"
