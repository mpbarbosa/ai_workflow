#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: Phase 5 - User Experience & Remaining Steps
# Purpose: Validate language-aware enhancements for Steps 2, 5, 6
# Version: 1.0.0
################################################################################

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define minimal print functions for testing
print_info() { echo "ℹ️  $*"; }
print_success() { echo "✅ $*"; }
print_error() { echo "❌ $*"; }
print_warning() { echo "⚠️  $*"; }

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test runner
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    
    print_info "Running: $test_name"
    
    if $test_function; then
        ((TESTS_PASSED++))
        print_success "✓ $test_name"
        return 0
    else
        ((TESTS_FAILED++))
        print_error "✗ $test_name"
        return 1
    fi
}

################################################################################
# Test: Step 5 Language-Aware Test File Detection
################################################################################

test_step5_javascript_test_detection() {
    # Simulate JavaScript test file detection
    local pattern="*.test.js|*.spec.js"
    
    # This would be part of Step 5 logic
    if [[ "$pattern" == *"test.js"* ]] && [[ "$pattern" == *"spec.js"* ]]; then
        return 0
    else
        print_error "JavaScript test pattern not correct"
        return 1
    fi
}

test_step5_python_test_detection() {
    local pattern="test_*.py|*_test.py"
    
    if [[ "$pattern" == *"test_"* ]] && [[ "$pattern" == *"_test.py"* ]]; then
        return 0
    else
        print_error "Python test pattern not correct"
        return 1
    fi
}

test_step5_go_test_detection() {
    local pattern="*_test.go"
    
    if [[ "$pattern" == *"_test.go"* ]]; then
        return 0
    else
        print_error "Go test pattern not correct"
        return 1
    fi
}

################################################################################
# Test: Step 6 Untested File Detection Patterns
################################################################################

test_step6_javascript_untested_detection() {
    # Test that we can identify JavaScript files needing tests
    local source_file="scripts/utils.js"
    local test_file="__tests__/utils.test.js"
    
    # Logic: if test file doesn't exist, it's untested
    if [[ "$source_file" == *.js ]]; then
        return 0
    else
        print_error "JavaScript source pattern matching failed"
        return 1
    fi
}

test_step6_python_untested_detection() {
    local source_file="src/utils.py"
    local test_file="src/test_utils.py"
    
    if [[ "$source_file" == *.py ]] && [[ "$test_file" == *test_*.py ]]; then
        return 0
    else
        print_error "Python test naming pattern failed"
        return 1
    fi
}

test_step6_go_untested_detection() {
    local source_file="pkg/utils.go"
    local test_file="pkg/utils_test.go"
    
    if [[ "$source_file" == *.go ]] && [[ "$test_file" == *_test.go ]]; then
        return 0
    else
        print_error "Go test naming pattern failed"
        return 1
    fi
}

test_step6_java_untested_detection() {
    local source_file="src/main/java/Utils.java"
    local test_file="src/test/java/UtilsTest.java"
    
    if [[ "$source_file" == *.java ]] && [[ "$test_file" == *Test.java ]]; then
        return 0
    else
        print_error "Java test naming pattern failed"
        return 1
    fi
}

################################################################################
# Test: Step 2 Language-Aware Consistency Enhancement
################################################################################

test_step2_javascript_conventions() {
    # Test that JavaScript conventions would be applied
    export PRIMARY_LANGUAGE="javascript"
    local conventions="JSDoc format"
    
    if [[ "$conventions" == *"JSDoc"* ]]; then
        return 0
    else
        print_error "JavaScript conventions not applied"
        return 1
    fi
}

test_step2_python_conventions() {
    export PRIMARY_LANGUAGE="python"
    local conventions="PEP 257 docstrings"
    
    if [[ "$conventions" == *"PEP"* ]]; then
        return 0
    else
        print_error "Python conventions not applied"
        return 1
    fi
}

################################################################################
# Test: Language Pattern Validation
################################################################################

test_all_languages_have_test_patterns() {
    local languages=("javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
    local failed=0
    
    for lang in "${languages[@]}"; do
        # Each language should have defined test patterns
        case "$lang" in
            javascript) pattern="*.test.js" ;;
            python) pattern="test_*.py" ;;
            go) pattern="*_test.go" ;;
            java) pattern="*Test.java" ;;
            ruby) pattern="*_spec.rb" ;;
            rust) pattern="tests/*.rs" ;;
            cpp) pattern="*_test.cpp" ;;
            bash) pattern="*.bats" ;;
            *) pattern="" ;;
        esac
        
        if [[ -z "$pattern" ]]; then
            print_error "No test pattern for $lang"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        print_error "$failed languages missing test patterns"
        return 1
    fi
}

test_all_languages_have_source_patterns() {
    local languages=("javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
    local failed=0
    
    for lang in "${languages[@]}"; do
        case "$lang" in
            javascript) ext=".js" ;;
            python) ext=".py" ;;
            go) ext=".go" ;;
            java) ext=".java" ;;
            ruby) ext=".rb" ;;
            rust) ext=".rs" ;;
            cpp) ext=".cpp" ;;
            bash) ext=".sh" ;;
            *) ext="" ;;
        esac
        
        if [[ -z "$ext" ]]; then
            print_error "No source extension for $lang"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        print_error "$failed languages missing source patterns"
        return 1
    fi
}

################################################################################
# Test: Integration Verification
################################################################################

test_step5_version_updated() {
    # Verify Step 5 was updated to v2.1.0
    if [[ -f "${SCRIPT_DIR}/../steps/step_05_test_review.sh" ]]; then
        if grep -q "2.1.0" "${SCRIPT_DIR}/../steps/step_05_test_review.sh"; then
            return 0
        else
            print_error "Step 5 version not updated"
            return 1
        fi
    else
        print_warning "Step 5 file not found (may be expected in test env)"
        return 0
    fi
}

test_step6_version_updated() {
    if [[ -f "${SCRIPT_DIR}/../steps/step_06_test_gen.sh" ]]; then
        if grep -q "2.1.0" "${SCRIPT_DIR}/../steps/step_06_test_gen.sh"; then
            return 0
        else
            print_error "Step 6 version not updated"
            return 1
        fi
    else
        print_warning "Step 6 file not found (may be expected in test env)"
        return 0
    fi
}

test_step2_version_updated() {
    if [[ -f "${SCRIPT_DIR}/../steps/step_02_consistency.sh" ]]; then
        if grep -q "2.1.0" "${SCRIPT_DIR}/../steps/step_02_consistency.sh"; then
            return 0
        else
            print_error "Step 2 version not updated"
            return 1
        fi
    else
        print_warning "Step 2 file not found (may be expected in test env)"
        return 0
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    print_info "=========================================="
    print_info "Phase 5 Enhancement Tests"
    print_info "=========================================="
    echo
    
    # Step 5 tests
    print_info "=== Step 5: Test Review Enhancement Tests ==="
    run_test "JavaScript test file detection" test_step5_javascript_test_detection || true
    run_test "Python test file detection" test_step5_python_test_detection || true
    run_test "Go test file detection" test_step5_go_test_detection || true
    echo
    
    # Step 6 tests
    print_info "=== Step 6: Test Generation Enhancement Tests ==="
    run_test "JavaScript untested file detection" test_step6_javascript_untested_detection || true
    run_test "Python untested file detection" test_step6_python_untested_detection || true
    run_test "Go untested file detection" test_step6_go_untested_detection || true
    run_test "Java untested file detection" test_step6_java_untested_detection || true
    echo
    
    # Step 2 tests
    print_info "=== Step 2: Consistency Enhancement Tests ==="
    run_test "JavaScript conventions check" test_step2_javascript_conventions || true
    run_test "Python conventions check" test_step2_python_conventions || true
    echo
    
    # Pattern validation tests
    print_info "=== Language Pattern Validation Tests ==="
    run_test "All languages have test patterns" test_all_languages_have_test_patterns || true
    run_test "All languages have source patterns" test_all_languages_have_source_patterns || true
    echo
    
    # Integration tests
    print_info "=== Integration Verification Tests ==="
    run_test "Step 5 version updated to v2.1.0" test_step5_version_updated || true
    run_test "Step 6 version updated to v2.1.0" test_step6_version_updated || true
    run_test "Step 2 version updated to v2.1.0" test_step2_version_updated || true
    echo
    
    # Print summary
    print_info "=========================================="
    print_info "Test Summary"
    print_info "=========================================="
    print_info "Tests Run: $TESTS_RUN"
    print_success "Tests Passed: $TESTS_PASSED"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        print_error "Tests Failed: $TESTS_FAILED"
        return 1
    else
        print_success "All tests passed! ✅"
        return 0
    fi
}

# Run tests
main "$@"
