#!/bin/bash
# Don't use set -euo pipefail in test files to allow test failures
set -uo pipefail

################################################################################
# Test Suite: Third-Party File Exclusion Module
# Purpose: Validate third-party file exclusion functionality
# Requirements: CONSOLIDATED_FUNCTIONAL_REQUIREMENTS.md >> Third-Party File Exclusion
################################################################################

# Import test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
source "${PROJECT_ROOT}/src/workflow/lib/third_party_exclusion.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============================================================================
# TEST FRAMEWORK
# ==============================================================================

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
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected to contain: '$needle'"
        echo "  In: '$haystack'"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ -n "$value" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected non-empty value"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_true() {
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if eval "$1"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected condition to be true"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_false() {
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if ! eval "$1"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected condition to be false"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ==============================================================================
# TESTS: Standard Exclusion Patterns
# ==============================================================================

test_standard_exclusion_patterns() {
    echo ""
    echo "Testing: Standard Exclusion Patterns"
    echo "======================================"
    
    local patterns
    patterns=$(get_standard_exclusion_patterns)
    
    assert_contains "$patterns" "node_modules" "Should include node_modules"
    assert_contains "$patterns" "venv" "Should include venv"
    assert_contains "$patterns" "__pycache__" "Should include __pycache__"
    assert_contains "$patterns" "vendor" "Should include vendor"
    assert_contains "$patterns" "target" "Should include target"
    assert_contains "$patterns" "build" "Should include build"
    assert_contains "$patterns" "dist" "Should include dist"
    assert_contains "$patterns" ".git" "Should include .git"
    assert_contains "$patterns" "coverage" "Should include coverage"
}

test_exclusion_array() {
    echo ""
    echo "Testing: Exclusion Array Generation"
    echo "===================================="
    
    local exclusions
    exclusions=($(get_exclusion_array))
    
    assert_true "[[ ${#exclusions[@]} -gt 10 ]]" "Should have at least 10 exclusion patterns"
    
    # Check specific patterns exist
    local has_node_modules=false
    local has_venv=false
    for pattern in "${exclusions[@]}"; do
        [[ "$pattern" == "node_modules" ]] && has_node_modules=true
        [[ "$pattern" == "venv" ]] && has_venv=true
    done
    
    assert_true "$has_node_modules" "Array should contain node_modules"
    assert_true "$has_venv" "Array should contain venv"
}

# ==============================================================================
# TESTS: Language-Specific Exclusions
# ==============================================================================

test_language_specific_exclusions() {
    echo ""
    echo "Testing: Language-Specific Exclusions"
    echo "======================================"
    
    local js_exclusions
    js_exclusions=$(get_language_exclusions "javascript")
    assert_contains "$js_exclusions" "node_modules" "JavaScript should exclude node_modules"
    assert_contains "$js_exclusions" "dist" "JavaScript should exclude dist"
    
    local py_exclusions
    py_exclusions=$(get_language_exclusions "python")
    assert_contains "$py_exclusions" "venv" "Python should exclude venv"
    assert_contains "$py_exclusions" "__pycache__" "Python should exclude __pycache__"
    
    local go_exclusions
    go_exclusions=$(get_language_exclusions "go")
    assert_contains "$go_exclusions" "vendor" "Go should exclude vendor"
    
    local java_exclusions
    java_exclusions=$(get_language_exclusions "java")
    assert_contains "$java_exclusions" "target" "Java should exclude target"
    
    local rust_exclusions
    rust_exclusions=$(get_language_exclusions "rust")
    assert_contains "$rust_exclusions" "target" "Rust should exclude target"
}

# ==============================================================================
# TESTS: Path Validation
# ==============================================================================

test_is_excluded_path() {
    echo ""
    echo "Testing: Path Exclusion Detection"
    echo "=================================="
    
    # Test excluded paths
    assert_true "is_excluded_path '/project/node_modules/package/file.js'" \
        "Should detect node_modules path as excluded"
    
    assert_true "is_excluded_path '/project/src/venv/lib/python3.9/site-packages/module.py'" \
        "Should detect venv path as excluded"
    
    assert_true "is_excluded_path '/project/target/classes/Main.class'" \
        "Should detect target path as excluded"
    
    # Test non-excluded paths
    assert_false "is_excluded_path '/project/src/main.js'" \
        "Should not exclude normal source file"
    
    assert_false "is_excluded_path '/project/docs/README.md'" \
        "Should not exclude documentation file"
}

# ==============================================================================
# TESTS: File Discovery with Exclusions
# ==============================================================================

test_find_with_exclusions() {
    echo ""
    echo "Testing: Find with Exclusions"
    echo "=============================="
    
    # Create temporary test structure
    local test_dir
    test_dir=$(mktemp -d)
    
    mkdir -p "$test_dir"/{src,node_modules,venv}
    touch "$test_dir"/src/app.js
    touch "$test_dir"/node_modules/package.js
    touch "$test_dir"/venv/lib.py
    
    # Run find with exclusions
    local results
    results=$(find_with_exclusions "$test_dir" "*.js" 3)
    
    assert_contains "$results" "app.js" "Should find source file"
    assert_true "[[ ! '$results' =~ 'package.js' ]]" "Should not find node_modules file"
    
    # Cleanup
    rm -rf "$test_dir"
}

# ==============================================================================
# TESTS: File Filtering
# ==============================================================================

test_filter_excluded_files() {
    echo ""
    echo "Testing: File Filtering"
    echo "======================="
    
    # Create test input
    local test_input
    test_input=$(cat << 'EOF'
/project/src/main.js
/project/node_modules/lib/package.js
/project/venv/lib/python3.9/site.py
/project/docs/README.md
/project/target/classes/Main.class
EOF
)
    
    local filtered
    filtered=$(echo "$test_input" | filter_excluded_files)
    
    assert_contains "$filtered" "main.js" "Should include source file"
    assert_contains "$filtered" "README.md" "Should include documentation"
    assert_true "[[ ! '$filtered' =~ 'package.js' ]]" "Should exclude node_modules"
    assert_true "[[ ! '$filtered' =~ 'site.py' ]]" "Should exclude venv"
    assert_true "[[ ! '$filtered' =~ 'Main.class' ]]" "Should exclude target"
}

# ==============================================================================
# TESTS: Reporting Helpers
# ==============================================================================

test_exclusion_summary() {
    echo ""
    echo "Testing: Exclusion Summary"
    echo "=========================="
    
    local summary
    summary=$(get_exclusion_summary)
    
    assert_not_empty "$summary" "Summary should not be empty"
    assert_contains "$summary" "node_modules" "Summary should mention node_modules"
    assert_contains "$summary" "venv" "Summary should mention venv"
}

test_ai_exclusion_context() {
    echo ""
    echo "Testing: AI Exclusion Context"
    echo "=============================="
    
    local context
    context=$(get_ai_exclusion_context)
    
    assert_not_empty "$context" "Context should not be empty"
    assert_contains "$context" "excludes" "Context should mention exclusions"
}

# ==============================================================================
# TESTS: Count Operations
# ==============================================================================

test_count_excluded_dirs() {
    echo ""
    echo "Testing: Count Excluded Directories"
    echo "===================================="
    
    # Create temporary test structure
    local test_dir
    test_dir=$(mktemp -d)
    
    mkdir -p "$test_dir"/{node_modules,venv,src}
    
    local count
    count=$(count_excluded_dirs "$test_dir")
    
    assert_true "[[ $count -ge 2 ]]" "Should count at least 2 excluded directories (node_modules, venv)"
    
    # Cleanup
    rm -rf "$test_dir"
}

# ==============================================================================
# TESTS: Integration with Performance Module
# ==============================================================================

test_fast_find_safe() {
    echo ""
    echo "Testing: Fast Find Safe (Compatibility)"
    echo "========================================"
    
    # Create temporary test structure
    local test_dir
    test_dir=$(mktemp -d)
    
    mkdir -p "$test_dir"/{src,node_modules}
    touch "$test_dir"/src/test.sh
    touch "$test_dir"/node_modules/package.sh
    
    local results
    results=$(fast_find_safe "$test_dir" "*.sh" 3)
    
    assert_contains "$results" "test.sh" "Should find source shell script"
    assert_true "[[ ! '$results' =~ 'package.sh' ]]" "Should not find node_modules script"
    
    # Cleanup
    rm -rf "$test_dir"
}

# ==============================================================================
# TESTS: Functional Requirements Coverage
# ==============================================================================

test_functional_requirements_coverage() {
    echo ""
    echo "Testing: Functional Requirements Coverage"
    echo "=========================================="
    
    # FR: All file discovery operations MUST use exclusion patterns
    assert_true "declare -f find_with_exclusions &>/dev/null" \
        "FR: find_with_exclusions function exists"
    
    # FR: Step-specific exclusions supported
    assert_true "declare -f get_language_exclusions &>/dev/null" \
        "FR: Language-specific exclusions supported"
    
    # FR: AI prompt context includes exclusions
    assert_true "declare -f get_ai_exclusion_context &>/dev/null" \
        "FR: AI context function exists"
    
    # FR: Configuration support for exclusions
    assert_true "declare -f get_tech_stack_exclusions &>/dev/null" \
        "FR: Tech stack integration exists"
    
    # FR: Performance impact measured
    assert_true "declare -f count_excluded_dirs &>/dev/null" \
        "FR: Directory counting function exists"
}

# ==============================================================================
# TEST EXECUTION
# ==============================================================================

main() {
    echo "=============================================="
    echo "Third-Party File Exclusion Module Test Suite"
    echo "=============================================="
    
    # Run all test suites
    test_standard_exclusion_patterns
    test_exclusion_array
    test_language_specific_exclusions
    test_is_excluded_path
    test_find_with_exclusions
    test_filter_excluded_files
    test_exclusion_summary
    test_ai_exclusion_context
    test_count_excluded_dirs
    test_fast_find_safe
    test_functional_requirements_coverage
    
    # Print summary
    echo ""
    echo "=============================================="
    echo "Test Summary"
    echo "=============================================="
    echo "Tests Run:    $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo "=============================================="
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
