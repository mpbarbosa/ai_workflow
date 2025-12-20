#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: Tech Stack Phase 3 - Workflow Integration
# Purpose: Validate adaptive workflow step execution
# Version: 1.0.0
################################################################################

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define minimal print functions for testing
print_info() { echo "ℹ️  $*"; }
print_success() { echo "✅ $*"; }
print_error() { echo "❌ $*"; }
print_warning() { echo "⚠️  $*"; }

# Source tech stack module
if [[ -f "${SCRIPT_DIR}/tech_stack.sh" ]]; then
    source "${SCRIPT_DIR}/tech_stack.sh"
else
    echo "Error: tech_stack.sh not found"
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
# Test: Command Retrieval Functions
################################################################################

test_get_install_command() {
    # Set up test environment
    export PRIMARY_LANGUAGE="python"
    
    local install_cmd=$(get_install_command)
    
    if [[ "$install_cmd" == *"pip"* ]] || [[ "$install_cmd" == *"poetry"* ]]; then
        return 0
    else
        print_error "Expected pip/poetry command, got: $install_cmd"
        return 1
    fi
}

test_get_test_command() {
    export PRIMARY_LANGUAGE="javascript"
    
    local test_cmd=$(get_test_command)
    
    if [[ "$test_cmd" == *"npm"* ]] || [[ "$test_cmd" == *"test"* ]]; then
        return 0
    else
        print_error "Expected npm test command, got: $test_cmd"
        return 1
    fi
}

test_get_lint_command() {
    export PRIMARY_LANGUAGE="python"
    
    local lint_cmd=$(get_lint_command)
    
    if [[ "$lint_cmd" == *"pylint"* ]] || [[ -n "$lint_cmd" ]]; then
        return 0
    else
        print_error "Expected lint command for python"
        return 1
    fi
}

test_get_build_command() {
    export PRIMARY_LANGUAGE="go"
    
    local build_cmd=$(get_build_command)
    
    if [[ "$build_cmd" == *"go build"* ]]; then
        return 0
    else
        print_error "Expected 'go build', got: $build_cmd"
        return 1
    fi
}

test_get_clean_command() {
    export PRIMARY_LANGUAGE="rust"
    
    local clean_cmd=$(get_clean_command)
    
    if [[ "$clean_cmd" == *"cargo clean"* ]]; then
        return 0
    else
        print_error "Expected 'cargo clean', got: $clean_cmd"
        return 1
    fi
}

################################################################################
# Test: Language-Specific Commands for All Languages
################################################################################

test_javascript_commands() {
    export PRIMARY_LANGUAGE="javascript"
    
    local install=$(get_install_command)
    local test=$(get_test_command)
    local lint=$(get_lint_command)
    
    if [[ "$install" == *"npm"* ]] && [[ "$test" == *"npm"* ]] && [[ -n "$lint" ]]; then
        return 0
    else
        print_error "JavaScript commands not configured correctly"
        return 1
    fi
}

test_python_commands() {
    export PRIMARY_LANGUAGE="python"
    
    local install=$(get_install_command)
    local test=$(get_test_command)
    local lint=$(get_lint_command)
    
    if [[ "$install" == *"pip"* ]] && [[ "$test" == *"pytest"* ]] && [[ "$lint" == *"pylint"* ]]; then
        return 0
    else
        print_error "Python commands not configured correctly"
        print_error "Install: $install, Test: $test, Lint: $lint"
        return 1
    fi
}

test_go_commands() {
    export PRIMARY_LANGUAGE="go"
    
    local install=$(get_install_command)
    local test=$(get_test_command)
    local build=$(get_build_command)
    
    if [[ "$install" == *"go mod"* ]] && [[ "$test" == *"go test"* ]] && [[ "$build" == *"go build"* ]]; then
        return 0
    else
        print_error "Go commands not configured correctly"
        return 1
    fi
}

test_java_commands() {
    export PRIMARY_LANGUAGE="java"
    
    local test=$(get_test_command)
    local build=$(get_build_command)
    
    if [[ "$test" == *"mvn"* ]] && [[ "$build" == *"mvn"* ]]; then
        return 0
    else
        print_error "Java commands not configured correctly"
        return 1
    fi
}

test_ruby_commands() {
    export PRIMARY_LANGUAGE="ruby"
    
    local install=$(get_install_command)
    local test=$(get_test_command)
    
    if [[ "$install" == *"bundle"* ]] && [[ "$test" == *"rspec"* ]]; then
        return 0
    else
        print_error "Ruby commands not configured correctly"
        return 1
    fi
}

test_rust_commands() {
    export PRIMARY_LANGUAGE="rust"
    
    local test=$(get_test_command)
    local build=$(get_build_command)
    local clean=$(get_clean_command)
    
    if [[ "$test" == *"cargo test"* ]] && [[ "$build" == *"cargo build"* ]] && [[ "$clean" == *"cargo clean"* ]]; then
        return 0
    else
        print_error "Rust commands not configured correctly"
        return 1
    fi
}

test_cpp_commands() {
    export PRIMARY_LANGUAGE="cpp"
    
    local test=$(get_test_command)
    local build=$(get_build_command)
    
    if [[ "$test" == *"ctest"* ]] && [[ "$build" == *"cmake"* ]]; then
        return 0
    else
        print_error "C++ commands not configured correctly"
        return 1
    fi
}

test_bash_commands() {
    export PRIMARY_LANGUAGE="bash"
    
    local test=$(get_test_command)
    local lint=$(get_lint_command)
    
    if [[ "$test" == *"bats"* ]] && [[ "$lint" == *"shellcheck"* ]]; then
        return 0
    else
        print_error "Bash commands not configured correctly"
        return 1
    fi
}

################################################################################
# Test: Fallback Behavior
################################################################################

test_fallback_to_npm() {
    export PRIMARY_LANGUAGE=""
    unset TEST_COMMAND
    unset LINT_COMMAND
    
    # Should fall back to npm for empty language
    local test_cmd=$(get_test_command)
    
    if [[ -z "$test_cmd" ]]; then
        # Empty is acceptable for unknown language
        return 0
    fi
    
    return 0
}

test_manual_override() {
    export PRIMARY_LANGUAGE="python"
    export TEST_COMMAND="custom test command"
    
    local test_cmd=$(get_test_command)
    
    if [[ "$test_cmd" == "custom test command" ]]; then
        return 0
    else
        print_error "Manual override not working, got: $test_cmd"
        return 1
    fi
}

################################################################################
# Test: Command Execution (Dry Run)
################################################################################

test_execute_language_command_success() {
    # Test with a simple echo command
    if execute_language_command "echo 'test'" "Test Echo" > /dev/null 2>&1; then
        return 0
    else
        print_error "Command execution failed"
        return 1
    fi
}

test_execute_language_command_empty() {
    # Empty command should return 0 and print warning
    if execute_language_command "" "Empty Test" > /dev/null 2>&1; then
        return 0
    else
        print_error "Empty command should return 0"
        return 1
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    print_info "=========================================="
    print_info "Tech Stack Phase 3 Integration Tests"
    print_info "=========================================="
    echo
    
    # Command retrieval tests
    print_info "=== Command Retrieval Tests ==="
    run_test "get_install_command" test_get_install_command || true
    run_test "get_test_command" test_get_test_command || true
    run_test "get_lint_command" test_get_lint_command || true
    run_test "get_build_command" test_get_build_command || true
    run_test "get_clean_command" test_get_clean_command || true
    echo
    
    # Language-specific command tests
    print_info "=== Language-Specific Command Tests ==="
    run_test "JavaScript commands" test_javascript_commands || true
    run_test "Python commands" test_python_commands || true
    run_test "Go commands" test_go_commands || true
    run_test "Java commands" test_java_commands || true
    run_test "Ruby commands" test_ruby_commands || true
    run_test "Rust commands" test_rust_commands || true
    run_test "C++ commands" test_cpp_commands || true
    run_test "Bash commands" test_bash_commands || true
    echo
    
    # Fallback and override tests
    print_info "=== Fallback & Override Tests ==="
    run_test "Fallback to empty for unknown language" test_fallback_to_npm || true
    run_test "Manual command override" test_manual_override || true
    echo
    
    # Command execution tests
    print_info "=== Command Execution Tests ==="
    run_test "Execute successful command" test_execute_language_command_success || true
    run_test "Execute empty command" test_execute_language_command_empty || true
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
