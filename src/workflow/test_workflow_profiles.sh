#!/usr/bin/env bash
#
# Test suite for workflow_profiles.sh
#
# Tests profile detection, step skipping, and time estimation
#

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source the module
source "$LIB_DIR/workflow_profiles.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#######################################
# Test helper functions
#######################################
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_contains() {
    local substring="$1"
    local string="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$string" == *"$substring"* ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected substring: $substring"
        echo "  In string: $string"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_success() {
    local test_name="$1"
    
    ((TESTS_RUN++))
    
    echo -e "${GREEN}✓${NC} $test_name"
    ((TESTS_PASSED++))
}

#######################################
# Test: Pattern matching
#######################################
test_pattern_matching() {
    echo ""
    echo "Testing pattern matching..."
    
    # Test documentation patterns
    matches_pattern "README.md" "*.md|docs/"
    assert_equals "0" "$?" "Should match README.md against *.md pattern"
    
    matches_pattern "docs/guide.md" "*.md|docs/"
    assert_equals "0" "$?" "Should match docs/guide.md"
    
    matches_pattern "src/main.sh" "*.md|docs/"
    assert_equals "1" "$?" "Should not match src/main.sh against docs pattern"
    
    # Test code patterns
    matches_pattern "src/lib/config.sh" "src/**/*.sh|*.sh|lib/*.sh"
    assert_equals "0" "$?" "Should match src/lib/config.sh"
    
    matches_pattern "test.sh" "src/**/*.sh|*.sh|lib/*.sh"
    assert_equals "0" "$?" "Should match test.sh against *.sh"
}

#######################################
# Test: Profile data retrieval
#######################################
test_profile_data() {
    echo ""
    echo "Testing profile data retrieval..."
    
    # Test docs_only profile
    local desc skip focus time
    desc=$(get_profile_description "docs_only")
    assert_contains "Documentation" "$desc" "docs_only description"
    
    skip=$(get_skip_steps "docs_only")
    assert_equals "7,8" "$skip" "docs_only skip steps"
    
    focus=$(get_focus_steps "docs_only")
    assert_equals "2,4,10" "$focus" "docs_only focus steps"
    
    time=$(get_estimated_time "docs_only")
    assert_contains "minutes" "$time" "docs_only estimated time"
    
    # Test code_changes profile
    skip=$(get_skip_steps "code_changes")
    assert_equals "2" "$skip" "code_changes skip steps"
    
    focus=$(get_focus_steps "code_changes")
    assert_equals "7,8,9,13" "$focus" "code_changes focus steps"
    
    # Test full_validation profile
    skip=$(get_skip_steps "full_validation")
    assert_equals "none" "$skip" "full_validation skip steps"
}

#######################################
# Test: Step skipping logic
#######################################
test_step_skipping() {
    echo ""
    echo "Testing step skipping logic..."
    
    # Set profile to docs_only (skips steps 7,8)
    WORKFLOW_PROFILE="docs_only"
    
    should_skip_step "7"
    assert_equals "0" "$?" "Should skip step 7 in docs_only profile"
    
    should_skip_step "8"
    assert_equals "0" "$?" "Should skip step 8 in docs_only profile"
    
    should_skip_step "2"
    assert_equals "1" "$?" "Should not skip step 2 in docs_only profile"
    
    # Set profile to full_validation (skips none)
    WORKFLOW_PROFILE="full_validation"
    
    should_skip_step "7"
    assert_equals "1" "$?" "Should not skip any steps in full_validation"
}

#######################################
# Test: Time savings calculation
#######################################
test_time_savings() {
    echo ""
    echo "Testing time savings calculation..."
    
    local savings
    
    savings=$(calculate_savings "docs_only")
    assert_equals "60%" "$savings" "docs_only savings"
    
    savings=$(calculate_savings "code_changes")
    assert_equals "20%" "$savings" "code_changes savings"
    
    savings=$(calculate_savings "test_changes")
    assert_equals "35%" "$savings" "test_changes savings"
    
    savings=$(calculate_savings "infrastructure")
    assert_equals "0%" "$savings" "infrastructure savings (needs full validation)"
    
    savings=$(calculate_savings "full_validation")
    assert_equals "0%" "$savings" "full_validation savings"
}

#######################################
# Test: Profile detection (mocked)
#######################################
test_profile_detection() {
    echo ""
    echo "Testing profile detection..."
    
    # Test manual override
    WORKFLOW_PROFILE="docs_only"
    detect_workflow_profile
    assert_equals "docs_only" "$WORKFLOW_PROFILE" "Should keep manually set profile"
    
    # Test skip detection
    WORKFLOW_PROFILE=""
    SKIP_PROFILE_DETECTION="true"
    detect_workflow_profile
    assert_equals "full_validation" "$WORKFLOW_PROFILE" "Should use full_validation when detection disabled"
    
    # Reset
    SKIP_PROFILE_DETECTION="false"
    WORKFLOW_PROFILE=""
}

#######################################
# Test: Display functions
#######################################
test_display_functions() {
    echo ""
    echo "Testing display functions..."
    
    # Test display_profile_info
    local output
    output=$(display_profile_info "docs_only" 2>&1)
    assert_contains "WORKFLOW PROFILE" "$output" "display_profile_info shows profile name"
    assert_contains "Documentation" "$output" "display_profile_info shows description"
    
    # Test list_profiles
    output=$(list_profiles 2>&1)
    assert_contains "docs_only" "$output" "list_profiles shows docs_only"
    assert_contains "code_changes" "$output" "list_profiles shows code_changes"
    assert_contains "full_validation" "$output" "list_profiles shows full_validation"
}

#######################################
# Test: All profiles defined
#######################################
test_all_profiles_defined() {
    echo ""
    echo "Testing all profiles are properly defined..."
    
    local profiles=("docs_only" "code_changes" "test_changes" "infrastructure" "full_validation")
    
    for profile in "${profiles[@]}"; do
        local desc
        desc=$(get_profile_description "$profile" 2>/dev/null)
        if [[ -n "$desc" ]]; then
            assert_success "Profile '$profile' is defined"
        else
            echo -e "${RED}✗${NC} Profile '$profile' is not defined"
            ((TESTS_FAILED++))
        fi
    done
}

#######################################
# Main test execution
#######################################
main() {
    echo "=========================================="
    echo "  Workflow Profiles Test Suite"
    echo "=========================================="
    
    test_pattern_matching
    test_profile_data
    test_step_skipping
    test_time_savings
    test_profile_detection
    test_display_functions
    test_all_profiles_defined
    
    echo ""
    echo "=========================================="
    echo "  Test Results"
    echo "=========================================="
    echo "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
        echo ""
        echo -e "${RED}FAILED${NC}"
        exit 1
    else
        echo "Tests failed: 0"
        echo ""
        echo -e "${GREEN}ALL TESTS PASSED${NC}"
        exit 0
    fi
}

# Run tests
main "$@"
