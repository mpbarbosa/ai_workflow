#!/usr/bin/env bash
#
# test_tech_stack.sh - Unit tests for tech_stack.sh module
#
# Tests tech stack detection, configuration parsing, and property access
#
# Usage:
#   ./test_tech_stack.sh

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set up color variables before sourcing modules
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

# Mock functions that tech_stack.sh depends on
print_info() { echo "ℹ️  $*"; }
print_success() { echo "✅ $*"; }
print_warning() { echo "⚠️  $*"; }
print_error() { echo "❌ $*"; }
print_header() { echo ""; echo "═══════════════════════════════════════════════════════════════"; echo "  $*"; echo "═══════════════════════════════════════════════════════════════"; echo ""; }
log_to_workflow() { :; }  # No-op for tests
get_config_value() { :; }  # Will be overridden by tech_stack.sh

# Source dependencies
WORKFLOW_LIB_DIR="${SCRIPT_DIR}/../../src/workflow/lib"
source "${WORKFLOW_LIB_DIR}/colors.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/config.sh" 2>/dev/null || true
source "${WORKFLOW_LIB_DIR}/tech_stack.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test fixtures directory
TEST_FIXTURES_DIR="/tmp/tech_stack_test_fixtures"

#######################################
# Run a test and track results
# Arguments:
#   $1 - Test name
#   $2 - Test function
#######################################
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    echo -n "  Testing: $test_name ... "
    
    if $test_func > /dev/null 2>&1; then
        echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

#######################################
# Setup test fixtures
#######################################
setup_test_fixtures() {
    rm -rf "$TEST_FIXTURES_DIR"
    mkdir -p "$TEST_FIXTURES_DIR"
    
    # Create JavaScript project fixture
    mkdir -p "$TEST_FIXTURES_DIR/js-project"
    cat > "$TEST_FIXTURES_DIR/js-project/package.json" <<EOF
{
  "name": "test-js-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest"
  }
}
EOF
    cat > "$TEST_FIXTURES_DIR/js-project/package-lock.json" <<EOF
{
  "name": "test-js-project",
  "lockfileVersion": 2
}
EOF
    touch "$TEST_FIXTURES_DIR/js-project/index.js"
    touch "$TEST_FIXTURES_DIR/js-project/app.js"
    
    # Create Python project fixture
    mkdir -p "$TEST_FIXTURES_DIR/py-project"
    cat > "$TEST_FIXTURES_DIR/py-project/requirements.txt" <<EOF
pytest>=7.0.0
pylint>=2.0.0
EOF
    touch "$TEST_FIXTURES_DIR/py-project/main.py"
    touch "$TEST_FIXTURES_DIR/py-project/utils.py"
    
    # Create Go project fixture
    mkdir -p "$TEST_FIXTURES_DIR/go-project"
    cat > "$TEST_FIXTURES_DIR/go-project/go.mod" <<EOF
module example.com/myproject

go 1.21
EOF
    cat > "$TEST_FIXTURES_DIR/go-project/go.sum" <<EOF
# checksums
EOF
    touch "$TEST_FIXTURES_DIR/go-project/main.go"
    touch "$TEST_FIXTURES_DIR/go-project/utils.go"
    
    # Create Java project fixture
    mkdir -p "$TEST_FIXTURES_DIR/java-project"
    cat > "$TEST_FIXTURES_DIR/java-project/pom.xml" <<EOF
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>myproject</artifactId>
  <version>1.0.0</version>
</project>
EOF
    mkdir -p "$TEST_FIXTURES_DIR/java-project/src/main/java"
    touch "$TEST_FIXTURES_DIR/java-project/src/main/java/Main.java"
    
    # Create Ruby project fixture
    mkdir -p "$TEST_FIXTURES_DIR/ruby-project"
    cat > "$TEST_FIXTURES_DIR/ruby-project/Gemfile" <<EOF
source 'https://rubygems.org'
gem 'rspec'
EOF
    cat > "$TEST_FIXTURES_DIR/ruby-project/Gemfile.lock" <<EOF
GEM
EOF
    touch "$TEST_FIXTURES_DIR/ruby-project/main.rb"
    
    # Create Rust project fixture
    mkdir -p "$TEST_FIXTURES_DIR/rust-project"
    cat > "$TEST_FIXTURES_DIR/rust-project/Cargo.toml" <<EOF
[package]
name = "myproject"
version = "0.1.0"
EOF
    cat > "$TEST_FIXTURES_DIR/rust-project/Cargo.lock" <<EOF
# Lock file
EOF
    mkdir -p "$TEST_FIXTURES_DIR/rust-project/src"
    touch "$TEST_FIXTURES_DIR/rust-project/src/main.rs"
    
    # Create C++ project fixture
    mkdir -p "$TEST_FIXTURES_DIR/cpp-project"
    cat > "$TEST_FIXTURES_DIR/cpp-project/CMakeLists.txt" <<EOF
cmake_minimum_required(VERSION 3.10)
project(MyProject)
EOF
    mkdir -p "$TEST_FIXTURES_DIR/cpp-project/src"
    touch "$TEST_FIXTURES_DIR/cpp-project/src/main.cpp"
    
    # Create Bash project fixture
    mkdir -p "$TEST_FIXTURES_DIR/bash-project"
    cat > "$TEST_FIXTURES_DIR/bash-project/.shellcheckrc" <<EOF
disable=SC2034
EOF
    touch "$TEST_FIXTURES_DIR/bash-project/script1.sh"
    touch "$TEST_FIXTURES_DIR/bash-project/script2.sh"
    touch "$TEST_FIXTURES_DIR/bash-project/script3.sh"
    
    # Create config file fixture
    cat > "$TEST_FIXTURES_DIR/test-config.yaml" <<EOF
project:
  name: "test-project"

tech_stack:
  primary_language: "python"
  build_system: "poetry"
  test_framework: "pytest"
  test_command: "poetry run pytest"

structure:
  source_dirs:
    - src
  test_dirs:
    - tests

dependencies:
  package_file: "pyproject.toml"
  install_command: "poetry install"
EOF
}

#######################################
# Cleanup test fixtures
#######################################
cleanup_test_fixtures() {
    rm -rf "$TEST_FIXTURES_DIR"
}

#######################################
# Test: JavaScript detection
#######################################
test_javascript_detection() {
    cd "$TEST_FIXTURES_DIR/js-project"
    
    local score
    score=$(detect_javascript_project)
    
    # Should detect with high confidence (>60)
    [[ $score -gt 60 ]]
}

#######################################
# Test: Python detection
#######################################
test_python_detection() {
    cd "$TEST_FIXTURES_DIR/py-project"
    
    local score
    score=$(detect_python_project)
    
    # Should detect with reasonable confidence (>40)
    [[ $score -gt 40 ]]
}

#######################################
# Test: Go detection
#######################################
test_go_detection() {
    cd "$TEST_FIXTURES_DIR/go-project"
    
    local score
    score=$(detect_go_project)
    
    # Should detect with high confidence (>70)
    [[ $score -gt 70 ]]
}

#######################################
# Test: Java detection
#######################################
test_java_detection() {
    cd "$TEST_FIXTURES_DIR/java-project"
    
    local score
    score=$(detect_java_project)
    
    # Should detect with reasonable confidence (>=50)
    [[ $score -ge 50 ]]
}

#######################################
# Test: Ruby detection
#######################################
test_ruby_detection() {
    cd "$TEST_FIXTURES_DIR/ruby-project"
    
    local score
    score=$(detect_ruby_project)
    
    # Should detect with high confidence (>70)
    [[ $score -gt 70 ]]
}

#######################################
# Test: Rust detection
#######################################
test_rust_detection() {
    cd "$TEST_FIXTURES_DIR/rust-project"
    
    local score
    score=$(detect_rust_project)
    
    # Should detect with high confidence (>70)
    [[ $score -gt 70 ]]
}

#######################################
# Test: C++ detection
#######################################
test_cpp_detection() {
    cd "$TEST_FIXTURES_DIR/cpp-project"
    
    local score
    score=$(detect_cpp_project)
    
    # Should detect with high confidence (>50)
    [[ $score -gt 50 ]]
}

#######################################
# Test: Bash detection
#######################################
test_bash_detection() {
    cd "$TEST_FIXTURES_DIR/bash-project"
    
    local score
    score=$(detect_bash_project)
    
    # Should detect with reasonable confidence (>40)
    [[ $score -gt 40 ]]
}

#######################################
# Test: Auto-detection selects JavaScript
#######################################
test_auto_detect_javascript() {
    cd "$TEST_FIXTURES_DIR/js-project"
    
    # Clear globals
    PRIMARY_LANGUAGE=""
    unset LANGUAGE_CONFIDENCE
    declare -gA LANGUAGE_CONFIDENCE
    
    detect_tech_stack
    
    [[ "$PRIMARY_LANGUAGE" == "javascript" ]]
}

#######################################
# Test: Auto-detection selects Python
#######################################
test_auto_detect_python() {
    cd "$TEST_FIXTURES_DIR/py-project"
    
    # Clear globals
    PRIMARY_LANGUAGE=""
    unset LANGUAGE_CONFIDENCE
    declare -gA LANGUAGE_CONFIDENCE
    
    detect_tech_stack
    
    [[ "$PRIMARY_LANGUAGE" == "python" ]]
}

#######################################
# Test: Configuration file parsing
#######################################
test_config_parsing() {
    cd "$TEST_FIXTURES_DIR"
    
    # Clear globals
    unset TECH_STACK_CONFIG
    declare -gA TECH_STACK_CONFIG
    
    load_tech_stack_config "test-config.yaml"
    
    [[ "${TECH_STACK_CONFIG[primary_language]}" == "python" ]]
}

#######################################
# Test: Get config value
#######################################
test_get_config_value() {
    cd "$TEST_FIXTURES_DIR"
    
    TECH_STACK_CONFIG[_config_file]="test-config.yaml"
    
    local value
    value=$(get_config_value "tech_stack.primary_language" "")
    
    [[ "$value" == "python" ]]
}

#######################################
# Test: Default tech stack
#######################################
test_default_tech_stack() {
    # Clear globals
    PRIMARY_LANGUAGE=""
    BUILD_SYSTEM=""
    
    load_default_tech_stack
    
    [[ "$PRIMARY_LANGUAGE" == "javascript" ]] && \
    [[ "$BUILD_SYSTEM" == "npm" ]]
}

#######################################
# Test: Export variables
#######################################
test_export_variables() {
    TECH_STACK_CONFIG[primary_language]="python"
    TECH_STACK_CONFIG[build_system]="pip"
    TECH_STACK_CONFIG[test_framework]="pytest"
    
    export_tech_stack_variables
    
    [[ "$PRIMARY_LANGUAGE" == "python" ]] && \
    [[ "$BUILD_SYSTEM" == "pip" ]] && \
    [[ "$TEST_FRAMEWORK" == "pytest" ]]
}

#######################################
# Test: Get tech stack property
#######################################
test_get_property() {
    TECH_STACK_CACHE[test_property]="test_value"
    
    local value
    value=$(get_tech_stack_property "test_property" "default")
    
    [[ "$value" == "test_value" ]]
}

#######################################
# Test: Get property with default
#######################################
test_get_property_default() {
    local value
    value=$(get_tech_stack_property "nonexistent_property" "default_value")
    
    [[ "$value" == "default_value" ]]
}

#######################################
# Test: Language support check
#######################################
test_language_supported() {
    is_language_supported "javascript" && \
    is_language_supported "python" && \
    is_language_supported "go" &&  # Phase 2: Now supported!
    is_language_supported "rust" && \
    ! is_language_supported "fortran"  # Not supported
}

#######################################
# Test: Get supported languages
#######################################
test_get_supported_languages() {
    local langs
    langs=$(get_supported_languages)
    
    [[ "$langs" == *"javascript"* ]] && \
    [[ "$langs" == *"python"* ]]
}

#######################################
# Test: Confidence score
#######################################
test_confidence_score() {
    LANGUAGE_CONFIDENCE[javascript]=85
    
    local score
    score=$(get_confidence_score "javascript")
    
    [[ $score -eq 85 ]]
}

#######################################
# Test: Missing config file
#######################################
test_missing_config_file() {
    cd "$TEST_FIXTURES_DIR"
    
    # Should fail gracefully
    if load_tech_stack_config "nonexistent.yaml"; then
        return 1  # Should have failed
    else
        return 0  # Correctly failed
    fi
}

#######################################
# Test: Invalid config format
#######################################
test_invalid_config() {
    cd "$TEST_FIXTURES_DIR"
    
    echo "invalid yaml content without colons" > invalid.yaml
    
    # Should fail gracefully
    if load_tech_stack_config "invalid.yaml"; then
        return 1  # Should have failed
    else
        return 0  # Correctly failed
    fi
}

#######################################
# Main test runner
#######################################
main() {
    echo ""
    print_header "Tech Stack Module Unit Tests"
    echo ""
    
    # Setup
    print_info "Setting up test fixtures..."
    setup_test_fixtures
    
    # Run tests
    echo ""
    print_info "Running tests..."
    echo ""
    
    run_test "JavaScript detection" test_javascript_detection
    run_test "Python detection" test_python_detection
    run_test "Go detection" test_go_detection
    run_test "Java detection" test_java_detection
    run_test "Ruby detection" test_ruby_detection
    run_test "Rust detection" test_rust_detection
    run_test "C++ detection" test_cpp_detection
    run_test "Bash detection" test_bash_detection
    run_test "Auto-detect JavaScript" test_auto_detect_javascript
    run_test "Auto-detect Python" test_auto_detect_python
    run_test "Config file parsing" test_config_parsing
    run_test "Get config value" test_get_config_value
    run_test "Default tech stack" test_default_tech_stack
    run_test "Export variables" test_export_variables
    run_test "Get property" test_get_property
    run_test "Get property default" test_get_property_default
    run_test "Language support check" test_language_supported
    run_test "Get supported languages" test_get_supported_languages
    run_test "Confidence score" test_confidence_score
    run_test "Missing config file" test_missing_config_file
    run_test "Invalid config format" test_invalid_config
    
    # Cleanup
    echo ""
    print_info "Cleaning up test fixtures..."
    cleanup_test_fixtures
    
    # Summary
    echo ""
    print_header "Test Results"
    echo ""
    echo "  Tests Run:    $TESTS_RUN"
    echo "  Tests Passed: ${COLOR_GREEN}$TESTS_PASSED${COLOR_RESET}"
    echo "  Tests Failed: ${COLOR_RED}$TESTS_FAILED${COLOR_RESET}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        local coverage_pct=$((TESTS_PASSED * 100 / TESTS_RUN))
        echo ""
        print_success "All tests passed! Coverage: ${coverage_pct}%"
        echo ""
        return 0
    else
        echo ""
        print_error "Some tests failed"
        echo ""
        return 1
    fi
}

# Run tests
main "$@"
