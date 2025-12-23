#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: AI Helpers Phase 4 - Language-Specific Prompts
# Purpose: Validate language-aware prompt generation
# Version: 1.0.0
################################################################################

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR"

# Define minimal print functions for testing
print_info() { echo "ℹ️  $*"; }
print_success() { echo "✅ $*"; }
print_error() { echo "❌ $*"; }
print_warning() { echo "⚠️  $*"; }

# Source AI helpers module
if [[ -f "${SCRIPT_DIR}/ai_helpers.sh" ]]; then
    source "${SCRIPT_DIR}/ai_helpers.sh"
else
    echo "Error: ai_helpers.sh not found"
    exit 1
fi

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
# Test: Language-Specific Conventions Loading
################################################################################

test_get_python_conventions() {
    export PRIMARY_LANGUAGE="python"
    
    local conventions=$(get_language_documentation_conventions)
    
    if [[ "$conventions" == *"PEP 257"* ]] || [[ "$conventions" == *"type hints"* ]]; then
        return 0
    else
        print_error "Python conventions not found or invalid"
        return 1
    fi
}

test_get_javascript_conventions() {
    export PRIMARY_LANGUAGE="javascript"
    
    local conventions=$(get_language_documentation_conventions)
    
    if [[ "$conventions" == *"JSDoc"* ]] || [[ "$conventions" == *"async/await"* ]]; then
        return 0
    else
        print_error "JavaScript conventions not found or invalid"
        return 1
    fi
}

test_get_go_conventions() {
    export PRIMARY_LANGUAGE="go"
    
    local conventions=$(get_language_documentation_conventions)
    
    if [[ "$conventions" == *"godoc"* ]] || [[ -n "$conventions" ]]; then
        return 0
    else
        print_error "Go conventions not found"
        return 1
    fi
}

################################################################################
# Test: Language-Specific Quality Standards
################################################################################

test_get_python_quality_standards() {
    export PRIMARY_LANGUAGE="python"
    
    local standards=$(get_language_quality_standards)
    
    if [[ "$standards" == *"Focus Areas"* ]] || [[ "$standards" == *"Best Practices"* ]]; then
        return 0
    else
        print_error "Python quality standards not found"
        return 1
    fi
}

test_get_javascript_quality_standards() {
    export PRIMARY_LANGUAGE="javascript"
    
    local standards=$(get_language_quality_standards)
    
    if [[ "$standards" == *"Focus Areas"* ]] || [[ -n "$standards" ]]; then
        return 0
    else
        print_error "JavaScript quality standards not found"
        return 1
    fi
}

test_get_rust_quality_standards() {
    export PRIMARY_LANGUAGE="rust"
    
    local standards=$(get_language_quality_standards)
    
    if [[ "$standards" == *"Focus Areas"* ]] || [[ "$standards" == *"ownership"* ]] || [[ -n "$standards" ]]; then
        return 0
    else
        print_error "Rust quality standards not found"
        return 1
    fi
}

################################################################################
# Test: Language-Specific Testing Patterns
################################################################################

test_get_python_testing_patterns() {
    export PRIMARY_LANGUAGE="python"
    
    local patterns=$(get_language_testing_patterns)
    
    if [[ "$patterns" == *"pytest"* ]] || [[ "$patterns" == *"framework"* ]]; then
        return 0
    else
        print_error "Python testing patterns not found"
        return 1
    fi
}

test_get_javascript_testing_patterns() {
    export PRIMARY_LANGUAGE="javascript"
    
    local patterns=$(get_language_testing_patterns)
    
    if [[ "$patterns" == *"Jest"* ]] || [[ "$patterns" == *"framework"* ]]; then
        return 0
    else
        print_error "JavaScript testing patterns not found"
        return 1
    fi
}

test_get_go_testing_patterns() {
    export PRIMARY_LANGUAGE="go"
    
    local patterns=$(get_language_testing_patterns)
    
    if [[ "$patterns" == *"testing"* ]] || [[ "$patterns" == *"table-driven"* ]] || [[ -n "$patterns" ]]; then
        return 0
    else
        print_error "Go testing patterns not found"
        return 1
    fi
}

################################################################################
# Test: Language-Aware Prompt Generation
################################################################################

test_generate_language_aware_documentation_prompt() {
    export PRIMARY_LANGUAGE="python"
    export BUILD_SYSTEM="poetry"
    export TEST_FRAMEWORK="pytest"
    
    local base_prompt="Review and update documentation"
    local enhanced_prompt=$(generate_language_aware_prompt "$base_prompt" "documentation")
    
    if [[ "$enhanced_prompt" == *"python"* ]] && [[ "$enhanced_prompt" == *"poetry"* ]]; then
        return 0
    else
        print_error "Language-aware documentation prompt not generated correctly"
        return 1
    fi
}

test_generate_language_aware_quality_prompt() {
    export PRIMARY_LANGUAGE="javascript"
    export BUILD_SYSTEM="npm"
    export TEST_FRAMEWORK="jest"
    
    local base_prompt="Review code quality"
    local enhanced_prompt=$(generate_language_aware_prompt "$base_prompt" "quality")
    
    if [[ "$enhanced_prompt" == *"javascript"* ]] && [[ "$enhanced_prompt" == *"npm"* ]]; then
        return 0
    else
        print_error "Language-aware quality prompt not generated correctly"
        return 1
    fi
}

test_generate_language_aware_testing_prompt() {
    export PRIMARY_LANGUAGE="go"
    export BUILD_SYSTEM="go mod"
    export TEST_FRAMEWORK="testing"
    
    local base_prompt="Review test coverage"
    local enhanced_prompt=$(generate_language_aware_prompt "$base_prompt" "testing")
    
    if [[ "$enhanced_prompt" == *"go"* ]] && [[ "$enhanced_prompt" == *"testing"* ]]; then
        return 0
    else
        print_error "Language-aware testing prompt not generated correctly"
        return 1
    fi
}

################################################################################
# Test: should_use_language_aware_prompts Function
################################################################################

test_should_use_prompts_with_language_set() {
    export PRIMARY_LANGUAGE="python"
    export USE_LANGUAGE_AWARE_PROMPTS="true"
    
    if should_use_language_aware_prompts; then
        return 0
    else
        print_error "Should use language-aware prompts when PRIMARY_LANGUAGE is set"
        return 1
    fi
}

test_should_not_use_prompts_without_language() {
    unset PRIMARY_LANGUAGE
    
    if should_use_language_aware_prompts; then
        print_error "Should not use language-aware prompts when PRIMARY_LANGUAGE is not set"
        return 1
    else
        return 0
    fi
}

test_should_not_use_prompts_when_disabled() {
    export PRIMARY_LANGUAGE="python"
    export USE_LANGUAGE_AWARE_PROMPTS="false"
    
    if should_use_language_aware_prompts; then
        print_error "Should not use language-aware prompts when explicitly disabled"
        return 1
    else
        return 0
    fi
}

################################################################################
# Test: All 8 Languages Supported
################################################################################

test_all_languages_have_conventions() {
    local languages=("javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
    local failed=0
    
    for lang in "${languages[@]}"; do
        export PRIMARY_LANGUAGE="$lang"
        local conventions=$(get_language_documentation_conventions)
        
        if [[ -z "$conventions" ]]; then
            print_error "No conventions found for $lang"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        print_error "$failed languages missing conventions"
        return 1
    fi
}

test_all_languages_have_quality_standards() {
    local languages=("javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
    local failed=0
    
    for lang in "${languages[@]}"; do
        export PRIMARY_LANGUAGE="$lang"
        local standards=$(get_language_quality_standards)
        
        if [[ -z "$standards" ]]; then
            print_error "No quality standards found for $lang"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        print_error "$failed languages missing quality standards"
        return 1
    fi
}

test_all_languages_have_testing_patterns() {
    local languages=("javascript" "python" "go" "java" "ruby" "rust" "cpp" "bash")
    local failed=0
    
    for lang in "${languages[@]}"; do
        export PRIMARY_LANGUAGE="$lang"
        local patterns=$(get_language_testing_patterns)
        
        if [[ -z "$patterns" ]]; then
            print_error "No testing patterns found for $lang"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        print_error "$failed languages missing testing patterns"
        return 1
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    print_info "=========================================="
    print_info "AI Helpers Phase 4 Integration Tests"
    print_info "=========================================="
    echo
    
    # Language conventions tests
    print_info "=== Language Documentation Conventions Tests ==="
    run_test "Python documentation conventions" test_get_python_conventions || true
    run_test "JavaScript documentation conventions" test_get_javascript_conventions || true
    run_test "Go documentation conventions" test_get_go_conventions || true
    echo
    
    # Quality standards tests
    print_info "=== Language Quality Standards Tests ==="
    run_test "Python quality standards" test_get_python_quality_standards || true
    run_test "JavaScript quality standards" test_get_javascript_quality_standards || true
    run_test "Rust quality standards" test_get_rust_quality_standards || true
    echo
    
    # Testing patterns tests
    print_info "=== Language Testing Patterns Tests ==="
    run_test "Python testing patterns" test_get_python_testing_patterns || true
    run_test "JavaScript testing patterns" test_get_javascript_testing_patterns || true
    run_test "Go testing patterns" test_get_go_testing_patterns || true
    echo
    
    # Language-aware prompt generation tests
    print_info "=== Language-Aware Prompt Generation Tests ==="
    run_test "Documentation prompt with language context" test_generate_language_aware_documentation_prompt || true
    run_test "Quality prompt with language context" test_generate_language_aware_quality_prompt || true
    run_test "Testing prompt with language context" test_generate_language_aware_testing_prompt || true
    echo
    
    # Feature flag tests
    print_info "=== Feature Flag Tests ==="
    run_test "Use prompts when language is set" test_should_use_prompts_with_language_set || true
    run_test "Don't use prompts without language" test_should_not_use_prompts_without_language || true
    run_test "Don't use prompts when disabled" test_should_not_use_prompts_when_disabled || true
    echo
    
    # Comprehensive language coverage tests
    print_info "=== Language Coverage Tests ==="
    run_test "All languages have conventions" test_all_languages_have_conventions || true
    run_test "All languages have quality standards" test_all_languages_have_quality_standards || true
    run_test "All languages have testing patterns" test_all_languages_have_testing_patterns || true
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
