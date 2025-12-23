#!/bin/bash
# Note: Using 'set -eo pipefail' (without -u) to allow test failures without exiting
set -eo pipefail

################################################################################
# Test Suite for Step 10→11 Dependency Enforcement
# Purpose: Verify mandatory Step 10 (Context Analysis) → Step 11 (Git Finalization) dependency
# Version: 1.0.0
# Created: 2025-12-23
#
# Tests FR-WF-1: Git Finalization Dependency on Context Analysis
# See: docs/workflow-automation/CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md
################################################################################

# Test framework setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TEST_NAME="Step 10→11 Dependency Enforcement Tests"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Source required modules
source "${PROJECT_ROOT}/src/workflow/lib/dependency_graph.sh" 2>/dev/null || {
    echo "Error: Cannot source dependency_graph.sh"
    exit 1
}

# Test utilities
print_test_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

print_test_section() {
    echo ""
    echo -e "${CYAN}$1${NC}"
    echo "----------------------------------------"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++)) || true
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++)) || true
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++)) || true
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected to NOT contain: $needle"
        echo "  Actual: $haystack"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"
    
    ((TESTS_TOTAL++)) || true
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: true"
        echo "  Actual:   $condition"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# ==============================================================================
# TEST SUITE 1: Dependency Definition Tests
# ==============================================================================

test_step11_depends_on_step10() {
    print_test_section "Test Suite 1: Dependency Definition"
    
    # Test that Step 11 depends on Step 10 in STEP_DEPENDENCIES array
    local step11_deps="${STEP_DEPENDENCIES[11]}"
    assert_equals "10" "$step11_deps" "Step 11 dependencies should be '10'"
    
    # Verify dependency is explicitly defined (not empty)
    if [[ -n "$step11_deps" ]]; then
        assert_true "true" "Step 11 has non-empty dependency definition"
    else
        assert_true "false" "Step 11 has non-empty dependency definition"
    fi
}

test_step11_isolated_in_parallel_groups() {
    # Test that Step 11 is in its own parallel group
    local found_step11_group=false
    local step11_group=""
    local step11_isolated=true
    
    for group in "${PARALLEL_GROUPS[@]}"; do
        if [[ "$group" == *"11"* ]]; then
            found_step11_group=true
            step11_group="$group"
            
            # Check if Step 11 is alone in this group
            if [[ "$group" != "11" ]]; then
                step11_isolated=false
            fi
            break
        fi
    done
    
    assert_true "$found_step11_group" "Step 11 is present in PARALLEL_GROUPS"
    assert_equals "11" "$step11_group" "Step 11 is in its own parallel group (isolated)"
    assert_true "$step11_isolated" "Step 11 is NOT combined with other steps in parallel execution"
}

test_step10_precedes_step11_in_groups() {
    # Find group indices for Step 10 and Step 11
    local step10_group_idx=-1
    local step11_group_idx=-1
    local idx=0
    
    for group in "${PARALLEL_GROUPS[@]}"; do
        if [[ "$group" == *"10"* ]]; then
            step10_group_idx=$idx
        fi
        if [[ "$group" == *"11"* ]]; then
            step11_group_idx=$idx
        fi
        ((idx++)) || true
    done
    
    # Step 10 should come before Step 11 in parallel groups
    if [[ $step10_group_idx -ge 0 ]] && [[ $step11_group_idx -ge 0 ]]; then
        if [[ $step10_group_idx -lt $step11_group_idx ]]; then
            assert_true "true" "Step 10 parallel group comes before Step 11 parallel group"
        else
            assert_true "false" "Step 10 parallel group comes before Step 11 parallel group"
        fi
    else
        assert_true "false" "Both Step 10 and Step 11 found in PARALLEL_GROUPS"
    fi
}

# ==============================================================================
# TEST SUITE 2: Dependency Logic Tests
# ==============================================================================

test_check_dependencies_step11_requires_step10() {
    print_test_section "Test Suite 2: Dependency Logic"
    
    # Test that Step 11 cannot run without Step 10
    # Completed steps: 0,1,2,3,4,5,6,7,8,9 (missing 10)
    local completed="0,1,2,3,4,5,6,7,8,9"
    
    if check_dependencies 11 "$completed"; then
        assert_true "false" "Step 11 should NOT be runnable without Step 10"
    else
        assert_true "true" "Step 11 is correctly blocked without Step 10"
    fi
}

test_check_dependencies_step11_can_run_with_step10() {
    # Test that Step 11 CAN run when Step 10 is completed
    # Completed steps: 0,1,2,3,4,5,6,7,8,9,10 (including 10)
    local completed="0,1,2,3,4,5,6,7,8,9,10"
    
    if check_dependencies 11 "$completed"; then
        assert_true "true" "Step 11 can run when Step 10 is completed"
    else
        assert_true "false" "Step 11 can run when Step 10 is completed"
    fi
}

test_step10_dependencies_subset_of_step11() {
    # All dependencies of Step 10 should be satisfied before Step 11 can run
    local step10_deps="${STEP_DEPENDENCIES[10]}"
    local step11_deps="${STEP_DEPENDENCIES[11]}"
    
    # Convert to arrays
    IFS=',' read -ra deps10 <<< "$step10_deps"
    IFS=',' read -ra deps11 <<< "$step11_deps"
    
    # Since Step 11 depends on Step 10, and Step 10 depends on 1,2,3,4,7,8,9,
    # Step 11 implicitly depends on all of Step 10's dependencies
    assert_contains "${step10_deps}" "1" "Step 10 depends on Step 1 (transitively required by Step 11)"
    assert_contains "${step10_deps}" "7" "Step 10 depends on Step 7 (transitively required by Step 11)"
}

# ==============================================================================
# TEST SUITE 3: Execution Order Tests
# ==============================================================================

test_get_next_runnable_steps_excludes_step11_without_step10() {
    print_test_section "Test Suite 3: Execution Order"
    
    # When steps 0-9 are completed but not 10, Step 11 should not be runnable
    local completed="0,1,2,3,4,5,6,7,8,9"
    local runnable=$(get_next_runnable_steps "$completed")
    
    assert_contains "$runnable" "10" "Step 10 should be runnable after steps 0-9"
    assert_not_contains "$runnable" "11" "Step 11 should NOT be runnable without Step 10"
}

test_get_next_runnable_steps_includes_step11_with_step10() {
    # When steps 0-10 are completed, Step 11 should be runnable
    local completed="0,1,2,3,4,5,6,7,8,9,10"
    local runnable=$(get_next_runnable_steps "$completed")
    
    assert_contains "$runnable" "11" "Step 11 should be runnable after Step 10"
}

test_step11_is_last_core_step() {
    # Step 11 should be the last "core" step before optional steps (12, 13, 14)
    # It should not have any required steps after it
    # Steps 12, 13, 14 are considered optional/supplementary
    
    # Check that Steps 12, 13, 14 don't depend on Step 11
    local step12_deps="${STEP_DEPENDENCIES[12]:-}"
    local step13_deps="${STEP_DEPENDENCIES[13]:-}"
    local step14_deps="${STEP_DEPENDENCIES[14]:-}"
    
    local has_step11_dep=false
    
    if [[ "$step12_deps" == *"11"* ]] || [[ "$step13_deps" == *"11"* ]] || [[ "$step14_deps" == *"11"* ]]; then
        has_step11_dep=true
    fi
    
    if [[ "$has_step11_dep" == false ]]; then
        assert_true "true" "No optional steps (12, 13, 14) depend on Step 11 (confirming it's terminal)"
    else
        assert_true "false" "No optional steps (12, 13, 14) depend on Step 11 (confirming it's terminal)"
    fi
}

test_no_steps_depend_on_step11() {
    # No step should depend on Step 11 (it's terminal)
    local found_dependency=false
    
    for step in "${!STEP_DEPENDENCIES[@]}"; do
        local deps="${STEP_DEPENDENCIES[$step]}"
        if [[ "$deps" == *"11"* ]]; then
            found_dependency=true
            break
        fi
    done
    
    if [[ "$found_dependency" == false ]]; then
        assert_true "true" "No steps depend on Step 11 (terminal step)"
    else
        assert_true "false" "No steps depend on Step 11 (terminal step)"
    fi
}

# ==============================================================================
# TEST SUITE 4: Documentation Tests
# ==============================================================================

test_documentation_contains_requirement() {
    print_test_section "Test Suite 4: Documentation Verification"
    
    local doc_file="${PROJECT_ROOT}/docs/workflow-automation/CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md"
    
    if [[ -f "$doc_file" ]]; then
        local doc_content=$(cat "$doc_file")
        
        assert_contains "$doc_content" "FR-WF-1" "Documentation contains FR-WF-1 requirement"
        assert_contains "$doc_content" "Git Finalization Dependency on Context Analysis" \
            "Documentation mentions dependency title"
        assert_contains "$doc_content" "Step 11" "Documentation mentions Step 11"
        assert_contains "$doc_content" "Step 10" "Documentation mentions Step 10"
        assert_contains "$doc_content" "MANDATORY" "Documentation marks requirement as MANDATORY"
    else
        echo -e "${YELLOW}⚠${NC} SKIP: Documentation file not found at $doc_file"
        ((TESTS_TOTAL++)) || true
    fi
}

test_dependency_graph_has_comments() {
    local dep_graph_file="${PROJECT_ROOT}/src/workflow/lib/dependency_graph.sh"
    
    if [[ -f "$dep_graph_file" ]]; then
        local graph_content=$(cat "$dep_graph_file")
        
        assert_contains "$graph_content" "MANDATORY" "dependency_graph.sh contains MANDATORY notation"
        assert_contains "$graph_content" "CRITICAL" "dependency_graph.sh contains CRITICAL notation"
        assert_contains "$graph_content" "[11]=\"10\"" "dependency_graph.sh defines Step 11 dependency"
    else
        echo -e "${YELLOW}⚠${NC} SKIP: dependency_graph.sh not found"
        ((TESTS_TOTAL++)) || true
    fi
}

# ==============================================================================
# TEST SUITE 5: Critical Path Tests
# ==============================================================================

test_critical_path_includes_step10_and_step11() {
    print_test_section "Test Suite 5: Critical Path Analysis"
    
    # The critical path should include Step 10 → Step 11 at the end
    # Critical path is typically: 0 → 5 → 6 → 7 → 10 → 11
    
    # Verify Step 10 is in critical path (depends on Step 7)
    local step10_deps="${STEP_DEPENDENCIES[10]}"
    assert_contains "$step10_deps" "7" "Step 10 depends on Step 7 (part of critical path)"
    
    # Verify Step 11 is in critical path (depends on Step 10)
    local step11_deps="${STEP_DEPENDENCIES[11]}"
    assert_equals "10" "$step11_deps" "Step 11 depends only on Step 10 (final critical path step)"
}

# ==============================================================================
# TEST EXECUTION
# ==============================================================================

main() {
    print_test_header "$TEST_NAME"
    echo "Testing mandatory Step 10 → Step 11 dependency enforcement"
    echo "Reference: FR-WF-1 in CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md"
    echo ""
    
    # Run all test suites
    test_step11_depends_on_step10
    test_step11_isolated_in_parallel_groups
    test_step10_precedes_step11_in_groups
    
    test_check_dependencies_step11_requires_step10
    test_check_dependencies_step11_can_run_with_step10
    test_step10_dependencies_subset_of_step11
    
    test_get_next_runnable_steps_excludes_step11_without_step10
    test_get_next_runnable_steps_includes_step11_with_step10
    test_step11_is_last_core_step
    test_no_steps_depend_on_step11
    
    test_documentation_contains_requirement
    test_dependency_graph_has_comments
    
    test_critical_path_includes_step10_and_step11
    
    # Print summary
    print_test_header "TEST SUMMARY"
    echo "Total Tests:  $TESTS_TOTAL"
    echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        echo ""
        echo "✅ Step 10 → Step 11 dependency is correctly enforced"
        echo "✅ Step 11 is correctly isolated as the final step"
        echo "✅ Documentation and implementation are aligned"
        return 0
    else
        echo ""
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo "⚠️  Please review failed tests and fix implementation"
        return 1
    fi
}

# Run tests
main
exit $?
