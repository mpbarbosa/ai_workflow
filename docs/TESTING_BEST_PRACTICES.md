# Testing Best Practices

**Version**: 1.0.0  
**Last Updated**: 2026-02-10  
**Coverage**: Unit, Integration, and End-to-End Testing

This guide provides comprehensive testing practices for the AI Workflow Automation system with 100% test coverage standards.

## Table of Contents

- [Overview](#overview)
- [Testing Philosophy](#testing-philosophy)
- [Test Types](#test-types)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [End-to-End Testing](#end-to-end-testing)
- [Test Organization](#test-organization)
- [Writing Effective Tests](#writing-effective-tests)
- [Test Utilities](#test-utilities)
- [Common Testing Patterns](#common-testing-patterns)
- [Performance Testing](#performance-testing)
- [Continuous Testing](#continuous-testing)
- [Troubleshooting Tests](#troubleshooting-tests)

---

## Overview

### Current Test Coverage

**AI Workflow Automation** maintains **100% test coverage** with:
- **37+ automated test suites**
- **200+ individual test cases**
- **Unit, integration, and E2E coverage**
- **Automated CI/CD test execution**
- **Performance regression testing**

### Test Execution

```bash
# Run all tests
./tests/run_all_tests.sh

# Run specific test categories
./tests/run_all_tests.sh --unit
./tests/run_all_tests.sh --integration
./tests/run_all_tests.sh --e2e

# Run specific module tests
./src/workflow/lib/test_ai_helpers.sh
./src/workflow/lib/test_change_detection.sh
./src/workflow/lib/test_metrics.sh
```

---

## Testing Philosophy

### Principles

1. **Test Behavior, Not Implementation**
   - Focus on what the code does, not how
   - Tests should survive refactoring
   - Public API is what matters

2. **Fast Feedback**
   - Unit tests run in milliseconds
   - Integration tests in seconds
   - Full suite completes in < 2 minutes

3. **Isolation**
   - Each test is independent
   - No shared state between tests
   - Tests can run in any order

4. **Readability**
   - Tests are documentation
   - Clear test names
   - Obvious assertions

5. **Maintainability**
   - DRY principle applies to tests
   - Use test utilities and helpers
   - Keep tests simple

### Test Pyramid

```
        /\
       /  \  E2E Tests (few)
      /----\
     /      \ Integration Tests (some)
    /--------\
   /          \ Unit Tests (many)
  /--------------\
```

**Distribution**:
- **70%** Unit tests - Fast, isolated, many
- **20%** Integration tests - Medium speed, component interaction
- **10%** E2E tests - Slower, full workflow validation

---

## Test Types

### 1. Unit Tests

**Purpose**: Test individual functions in isolation

**Characteristics**:
- No external dependencies
- Mock file system, network, etc.
- Run in < 100ms per test
- 100% code coverage goal

**Example**:
```bash
function test_trim_function() {
    local result
    result=$(trim "  hello  ")
    assert_equals "hello" "$result" "trim removes whitespace"
}
```

### 2. Integration Tests

**Purpose**: Test component interactions

**Characteristics**:
- Multiple modules working together
- Real file system (temp directories)
- Limited network (local only)
- Run in < 1 second per test

**Example**:
```bash
function test_change_detection_with_git() {
    # Setup
    setup_git_repo
    
    # Make changes
    echo "new line" >> README.md
    
    # Test detection
    local changes
    changes=$(detect_changes)
    
    assert_equals "1" "$changes" "Detects single file change"
    
    # Cleanup
    cleanup_git_repo
}
```

### 3. End-to-End Tests

**Purpose**: Test complete workflows

**Characteristics**:
- Full workflow execution
- Real project environment
- All components integrated
- Run in < 30 seconds per test

**Example**:
```bash
function test_docs_only_workflow() {
    # Setup test project
    create_test_project
    
    # Run workflow
    ./templates/workflows/docs-only.sh --auto
    
    # Verify results
    assert_file_exists "backlog/workflow_*/DOCUMENTATION_ANALYSIS.md"
    assert_file_contains "backlog/workflow_*/DOCUMENTATION_ANALYSIS.md" "Analysis complete"
    
    # Cleanup
    cleanup_test_project
}
```

---

## Unit Testing

### Test Structure

```bash
#!/usr/bin/env bash
# Test: test_module_name.sh
# Purpose: Unit tests for module_name.sh

set -euo pipefail

# Source module under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/module_name.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assertion functions
function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        echo "   Expected: $expected"
        echo "   Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    ((TESTS_RUN++))
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    ((TESTS_RUN++))
    
    if [[ "$condition" == "false" ]] || [[ "$condition" != "0" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    ((TESTS_RUN++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        echo "   Looking for: $needle"
        echo "   In: $haystack"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    ((TESTS_RUN++))
    
    if [[ -f "$file" ]]; then
        echo "✅ PASS: $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo "❌ FAIL: $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test setup/teardown
function setup() {
    export TEST_DIR="/tmp/test_$$"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
}

function teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test cases
function test_basic_functionality() {
    setup
    
    local result
    result=$(my_function "test_input")
    assert_equals "expected_output" "$result" "Basic functionality works"
    
    teardown
}

function test_error_handling() {
    setup
    
    if my_function "" 2>/dev/null; then
        echo "❌ FAIL: Should reject empty input"
        ((TESTS_FAILED++))
    else
        echo "✅ PASS: Correctly rejects empty input"
        ((TESTS_PASSED++))
    fi
    
    teardown
}

function test_edge_cases() {
    setup
    
    # Test special characters
    local result
    result=$(my_function "test-!@#$%")
    assert_contains "$result" "test" "Handles special characters"
    
    # Test long input
    local long_input
    long_input=$(printf 'a%.0s' {1..1000})
    result=$(my_function "$long_input")
    assert_true "$?" "Handles long input"
    
    teardown
}

# Run all tests
echo "========================================"
echo "Unit Tests: module_name.sh"
echo "========================================"
echo ""

test_basic_functionality
test_error_handling
test_edge_cases

# Report results
echo ""
echo "========================================"
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "Result:       ✅ ALL TESTS PASSED"
else
    echo "Result:       ❌ SOME TESTS FAILED"
fi
echo "========================================"

# Exit with appropriate code
[[ $TESTS_FAILED -eq 0 ]]
```

### Best Practices for Unit Tests

1. **One Assertion Per Test** (when possible)
   ```bash
   # ❌ Multiple unrelated assertions
   function test_everything() {
       assert_equals "a" "$(func1)"
       assert_equals "b" "$(func2)"
       assert_equals "c" "$(func3)"
   }
   
   # ✅ Separate focused tests
   function test_func1_returns_a() {
       assert_equals "a" "$(func1)"
   }
   
   function test_func2_returns_b() {
       assert_equals "b" "$(func2)"
   }
   ```

2. **Test Names Should Be Descriptive**
   ```bash
   # ❌ Vague
   function test1() { ... }
   function test_function() { ... }
   
   # ✅ Clear
   function test_trim_removes_leading_whitespace() { ... }
   function test_parse_config_handles_missing_file() { ... }
   ```

3. **Arrange-Act-Assert Pattern**
   ```bash
   function test_something() {
       # Arrange - Setup test data
       local input="test_value"
       local expected="expected_result"
       
       # Act - Execute function
       local actual
       actual=$(my_function "$input")
       
       # Assert - Verify result
       assert_equals "$expected" "$actual"
   }
   ```

4. **Use Test Fixtures**
   ```bash
   function create_test_config() {
       cat > test_config.yaml << 'EOF'
   project:
     name: test
   tech_stack:
     language: bash
   EOF
   }
   
   function test_config_loading() {
       setup
       create_test_config
       
       load_config "test_config.yaml"
       assert_equals "test" "$PROJECT_NAME"
       
       teardown
   }
   ```

---

## Integration Testing

### Test Structure

```bash
#!/usr/bin/env bash
# Integration Test: Multiple module interaction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/change_detection.sh"
source "${SCRIPT_DIR}/lib/git_automation.sh"
source "${SCRIPT_DIR}/lib/metrics.sh"

# Test environment
TEST_REPO="/tmp/test_repo_$$"

function setup_test_repo() {
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
}

function cleanup_test_repo() {
    cd /
    rm -rf "$TEST_REPO"
}

function test_change_detection_workflow() {
    echo "Test: Change detection workflow"
    
    setup_test_repo
    
    # Initialize metrics
    init_metrics
    
    # Make changes
    echo "New content" >> README.md
    echo "print('hello')" > script.py
    git add README.md script.py
    
    # Detect changes
    analyze_changes
    local doc_changes
    doc_changes=$(get_doc_changes)
    local code_changes
    code_changes=$(get_code_changes)
    
    # Verify
    if [[ $doc_changes -gt 0 ]] && [[ $code_changes -gt 0 ]]; then
        echo "✅ PASS: Detected both doc and code changes"
    else
        echo "❌ FAIL: Change detection failed"
        cleanup_test_repo
        return 1
    fi
    
    # Finalize metrics
    finalize_metrics
    
    # Verify metrics recorded
    if [[ -f "metrics/current_run.json" ]]; then
        echo "✅ PASS: Metrics recorded"
    else
        echo "❌ FAIL: Metrics not recorded"
        cleanup_test_repo
        return 1
    fi
    
    cleanup_test_repo
    echo "✅ Test completed successfully"
    return 0
}

function test_git_automation_integration() {
    echo "Test: Git automation integration"
    
    setup_test_repo
    
    # Create changes
    mkdir -p docs
    echo "# Documentation" > docs/guide.md
    
    # Auto-commit
    if auto_commit_changes "docs" "Update documentation"; then
        echo "✅ PASS: Auto-commit succeeded"
    else
        echo "❌ FAIL: Auto-commit failed"
        cleanup_test_repo
        return 1
    fi
    
    # Verify commit
    local commits
    commits=$(git log --oneline | wc -l)
    if [[ $commits -eq 2 ]]; then
        echo "✅ PASS: Commit created"
    else
        echo "❌ FAIL: Expected 2 commits, found $commits"
        cleanup_test_repo
        return 1
    fi
    
    cleanup_test_repo
    echo "✅ Test completed successfully"
    return 0
}

# Run tests
echo "========================================"
echo "Integration Tests"
echo "========================================"
echo ""

FAILED=0

test_change_detection_workflow || ((FAILED++))
echo ""
test_git_automation_integration || ((FAILED++))

echo ""
echo "========================================"
if [[ $FAILED -eq 0 ]]; then
    echo "Result: ✅ ALL TESTS PASSED"
else
    echo "Result: ❌ $FAILED TEST(S) FAILED"
fi
echo "========================================"

exit $FAILED
```

### Best Practices for Integration Tests

1. **Isolate Test Environment**
   ```bash
   # Create isolated temp directory
   TEST_DIR="/tmp/test_$$_$(date +%s)"
   mkdir -p "$TEST_DIR"
   cd "$TEST_DIR"
   
   # Always cleanup
   trap 'cd / && rm -rf "$TEST_DIR"' EXIT
   ```

2. **Mock External Dependencies**
   ```bash
   # Mock GitHub CLI
   function gh() {
       echo "mocked response"
   }
   export -f gh
   ```

3. **Test Real Interactions**
   ```bash
   # Don't mock everything - test real module interaction
   source lib/module_a.sh
   source lib/module_b.sh
   
   # Test A → B interaction
   result_a=$(module_a_function)
   result_b=$(module_b_function "$result_a")
   ```

---

## End-to-End Testing

### Test Structure

```bash
#!/usr/bin/env bash
# E2E Test: Complete workflow execution

set -euo pipefail

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_PROJECT="/tmp/e2e_test_$$"

function setup_test_project() {
    echo "Setting up test project..."
    
    mkdir -p "$TEST_PROJECT"
    cd "$TEST_PROJECT"
    
    # Initialize git
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create project structure
    mkdir -p src docs tests
    
    # Add files
    cat > README.md << 'EOF'
# Test Project

A test project for workflow validation.
EOF
    
    cat > src/main.sh << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF
    
    cat > tests/test_main.sh << 'EOF'
#!/bin/bash
source src/main.sh
# Test code here
EOF
    
    chmod +x src/main.sh tests/test_main.sh
    
    # Initial commit
    git add .
    git commit -m "Initial project setup"
    
    echo "✅ Test project created"
}

function run_workflow() {
    local template="$1"
    echo "Running workflow: $template"
    
    cd "$TEST_PROJECT"
    
    if "${WORKFLOW_DIR}/templates/workflows/${template}.sh" --auto; then
        echo "✅ Workflow completed"
        return 0
    else
        echo "❌ Workflow failed"
        return 1
    fi
}

function verify_artifacts() {
    echo "Verifying workflow artifacts..."
    
    local errors=0
    
    # Check logs
    if ! ls logs/workflow_* >/dev/null 2>&1; then
        echo "❌ No log directory found"
        ((errors++))
    else
        echo "✅ Logs created"
    fi
    
    # Check backlog
    if ! ls backlog/workflow_* >/dev/null 2>&1; then
        echo "❌ No backlog directory found"
        ((errors++))
    else
        echo "✅ Backlog created"
    fi
    
    # Check health check
    if ! ls backlog/workflow_*/WORKFLOW_HEALTH_CHECK.md >/dev/null 2>&1; then
        echo "❌ Health check not found"
        ((errors++))
    else
        echo "✅ Health check created"
    fi
    
    return $errors
}

function cleanup_test_project() {
    cd /
    rm -rf "$TEST_PROJECT"
    echo "✅ Cleanup completed"
}

function test_docs_only_workflow() {
    echo ""
    echo "========================================"
    echo "E2E Test: Docs-Only Workflow"
    echo "========================================"
    
    setup_test_project
    
    # Make documentation change
    cd "$TEST_PROJECT"
    echo "## New Section" >> README.md
    git add README.md
    git commit -m "Update README"
    
    # Run workflow
    if ! run_workflow "docs-only"; then
        cleanup_test_project
        return 1
    fi
    
    # Verify
    if ! verify_artifacts; then
        cleanup_test_project
        return 1
    fi
    
    cleanup_test_project
    echo "✅ Test passed"
    return 0
}

function test_full_workflow() {
    echo ""
    echo "========================================"
    echo "E2E Test: Full Workflow"
    echo "========================================"
    
    setup_test_project
    
    # Make various changes
    cd "$TEST_PROJECT"
    echo "## Updates" >> README.md
    echo "echo 'updated'" >> src/main.sh
    echo "# More tests" >> tests/test_main.sh
    
    git add .
    git commit -m "Multiple updates"
    
    # Run full workflow with optimizations
    cd "$TEST_PROJECT"
    if ! "${WORKFLOW_DIR}/src/workflow/execute_tests_docs_workflow.sh" \
        --smart-execution \
        --parallel \
        --auto; then
        cleanup_test_project
        return 1
    fi
    
    # Verify
    if ! verify_artifacts; then
        cleanup_test_project
        return 1
    fi
    
    cleanup_test_project
    echo "✅ Test passed"
    return 0
}

# Run tests
echo "========================================"
echo "End-to-End Tests"
echo "========================================"

FAILED=0

test_docs_only_workflow || ((FAILED++))
test_full_workflow || ((FAILED++))

echo ""
echo "========================================"
if [[ $FAILED -eq 0 ]]; then
    echo "Result: ✅ ALL E2E TESTS PASSED"
else
    echo "Result: ❌ $FAILED E2E TEST(S) FAILED"
fi
echo "========================================"

exit $FAILED
```

---

## Test Organization

### Directory Structure

```
tests/
├── run_all_tests.sh              # Master test runner
├── unit/                         # Unit tests
│   ├── test_utils.sh
│   ├── test_config.sh
│   └── ...
├── integration/                  # Integration tests
│   ├── test_change_detection.sh
│   ├── test_ai_workflow.sh
│   └── ...
├── e2e/                         # End-to-end tests
│   ├── test_docs_workflow.sh
│   ├── test_full_workflow.sh
│   └── ...
├── fixtures/                    # Test data
│   ├── sample_config.yaml
│   ├── sample_project/
│   └── ...
└── helpers/                     # Test utilities
    ├── assertions.sh
    ├── mocks.sh
    └── ...
```

### Test Runner

```bash
#!/usr/bin/env bash
# Master test runner: tests/run_all_tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse options
RUN_UNIT=false
RUN_INTEGRATION=false
RUN_E2E=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --unit) RUN_UNIT=true; shift ;;
        --integration) RUN_INTEGRATION=true; shift ;;
        --e2e) RUN_E2E=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --all) RUN_UNIT=true; RUN_INTEGRATION=true; RUN_E2E=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Default: run all
if [[ "$RUN_UNIT" == "false" ]] && \
   [[ "$RUN_INTEGRATION" == "false" ]] && \
   [[ "$RUN_E2E" == "false" ]]; then
    RUN_UNIT=true
    RUN_INTEGRATION=true
    RUN_E2E=true
fi

# Results
TOTAL_PASSED=0
TOTAL_FAILED=0

function run_test_suite() {
    local suite_dir="$1"
    local suite_name="$2"
    
    echo ""
    echo "========================================"
    echo "Running $suite_name Tests"
    echo "========================================"
    
    local passed=0
    local failed=0
    
    for test_file in "$suite_dir"/test_*.sh; do
        [[ -f "$test_file" ]] || continue
        
        echo ""
        echo "Running: $(basename "$test_file")"
        
        if [[ "$VERBOSE" == "true" ]]; then
            if bash "$test_file"; then
                ((passed++))
            else
                ((failed++))
            fi
        else
            if bash "$test_file" > /dev/null 2>&1; then
                echo "✅ PASSED"
                ((passed++))
            else
                echo "❌ FAILED"
                ((failed++))
            fi
        fi
    done
    
    echo ""
    echo "$suite_name Results: $passed passed, $failed failed"
    
    ((TOTAL_PASSED += passed))
    ((TOTAL_FAILED += failed))
}

# Run test suites
[[ "$RUN_UNIT" == "true" ]] && run_test_suite "${SCRIPT_DIR}/unit" "Unit"
[[ "$RUN_INTEGRATION" == "true" ]] && run_test_suite "${SCRIPT_DIR}/integration" "Integration"
[[ "$RUN_E2E" == "true" ]] && run_test_suite "${SCRIPT_DIR}/e2e" "End-to-End"

# Final report
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total passed: $TOTAL_PASSED"
echo "Total failed: $TOTAL_FAILED"
echo ""

if [[ $TOTAL_FAILED -eq 0 ]]; then
    echo "✅ ALL TESTS PASSED"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    exit 1
fi
```

---

## Writing Effective Tests

### Test Naming

```bash
# Format: test_<what>_<condition>_<expected>

# Good examples
test_trim_with_whitespace_removes_spaces()
test_parse_config_missing_file_returns_error()
test_detect_changes_no_commits_returns_zero()
test_ai_call_empty_prompt_fails()

# Bad examples
test1()
test_function()
test_works()
```

### Test Data

```bash
# Use meaningful test data
# ❌ Generic
test_data="abc123"

# ✅ Descriptive
test_username="john_doe"
test_email="john@example.com"
test_config_file="valid_config.yaml"
```

### Error Messages

```bash
# ❌ Unclear
assert_equals "$expected" "$actual"

# ✅ Clear
assert_equals "$expected" "$actual" \
    "User profile should contain email address"
```

---

## Test Utilities

### Common Assertion Library

Create `tests/helpers/assertions.sh`:

```bash
#!/usr/bin/env bash
# Reusable assertion functions

function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $message"
        return 0
    else
        echo "❌ FAIL: $message"
        echo "   Expected: $expected"
        echo "   Actual:   $actual"
        return 1
    fi
}

function assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✅ PASS: $message"
        return 0
    else
        echo "❌ FAIL: $message"
        return 1
    fi
}

function assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        echo "✅ PASS: $message"
        return 0
    else
        echo "❌ FAIL: $message (file: $file)"
        return 1
    fi
}

function assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    if eval "$command" >/dev/null 2>&1; then
        echo "✅ PASS: $message"
        return 0
    else
        echo "❌ FAIL: $message (command: $command)"
        return 1
    fi
}

export -f assert_equals assert_contains assert_file_exists assert_command_succeeds
```

### Mock Functions

Create `tests/helpers/mocks.sh`:

```bash
#!/usr/bin/env bash
# Mock external dependencies

# Mock GitHub CLI
function mock_gh_copilot() {
    function gh() {
        if [[ "$1" == "copilot" ]]; then
            echo "Mocked Copilot response"
            return 0
        fi
    }
    export -f gh
}

# Mock git commands
function mock_git() {
    function git() {
        case "$1" in
            status) echo "nothing to commit" ;;
            diff) echo "" ;;
            log) echo "abc123 Initial commit" ;;
            *) command git "$@" ;;
        esac
    }
    export -f git
}

# Reset mocks
function reset_mocks() {
    unset -f gh git
}

export -f mock_gh_copilot mock_git reset_mocks
```

---

## Common Testing Patterns

### Pattern 1: Parameterized Tests

```bash
function test_multiple_inputs() {
    local test_cases=(
        "input1:expected1"
        "input2:expected2"
        "input3:expected3"
    )
    
    for test_case in "${test_cases[@]}"; do
        IFS=: read -r input expected <<< "$test_case"
        local actual
        actual=$(my_function "$input")
        assert_equals "$expected" "$actual" "Test with input: $input"
    done
}
```

### Pattern 2: Table-Driven Tests

```bash
function test_validation_rules() {
    # Define test table
    declare -A tests=(
        ["valid-name"]="true"
        ["invalid name"]="false"
        [""]="false"
        ["123"]="false"
    )
    
    for input in "${!tests[@]}"; do
        local expected="${tests[$input]}"
        
        if validate_name "$input"; then
            local actual="true"
        else
            local actual="false"
        fi
        
        assert_equals "$expected" "$actual" "validate_name('$input')"
    done
}
```

### Pattern 3: Golden Files

```bash
function test_output_format() {
    local actual_output="/tmp/actual.txt"
    local expected_output="tests/fixtures/expected_output.txt"
    
    # Generate output
    my_function > "$actual_output"
    
    # Compare with golden file
    if diff "$expected_output" "$actual_output"; then
        echo "✅ Output matches expected format"
        return 0
    else
        echo "❌ Output differs from expected"
        return 1
    fi
}
```

---

## Performance Testing

### Benchmark Tests

```bash
function benchmark_function() {
    local iterations=1000
    local start
    local end
    local duration
    
    start=$(date +%s%N)
    
    for ((i=0; i<iterations; i++)); do
        my_function "test_input" >/dev/null
    done
    
    end=$(date +%s%N)
    duration=$(( (end - start) / 1000000 ))  # Convert to milliseconds
    
    local avg_ms=$((duration / iterations))
    
    echo "Benchmark: $iterations iterations in ${duration}ms (avg: ${avg_ms}ms)"
    
    # Assert performance requirement
    if [[ $avg_ms -lt 10 ]]; then
        echo "✅ Performance meets requirement (< 10ms)"
        return 0
    else
        echo "❌ Performance regression (> 10ms)"
        return 1
    fi
}
```

### Memory Profiling

```bash
function profile_memory() {
    local before
    local after
    local used
    
    # Get memory before
    before=$(ps -o rss= -p $$)
    
    # Run function
    my_function_that_uses_memory
    
    # Get memory after
    after=$(ps -o rss= -p $$)
    used=$((after - before))
    
    echo "Memory used: ${used}KB"
    
    # Assert memory limit
    if [[ $used -lt 10240 ]]; then  # 10MB
        echo "✅ Memory usage acceptable"
        return 0
    else
        echo "❌ Memory usage too high"
        return 1
    fi
}
```

---

## Continuous Testing

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Run fast tests before committing

echo "Running pre-commit tests..."

# Run unit tests only (fast)
if ./tests/run_all_tests.sh --unit --quiet; then
    echo "✅ Tests passed"
    exit 0
else
    echo "❌ Tests failed - commit aborted"
    echo "Run './tests/run_all_tests.sh --unit' to see details"
    exit 1
fi
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup
        run: |
          git submodule update --init --recursive
      
      - name: Run Tests
        run: ./tests/run_all_tests.sh
      
      - name: Upload Coverage
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/
```

---

## Troubleshooting Tests

### Common Issues

1. **Test Failures in CI but Pass Locally**
   - Check environment differences
   - Verify test isolation
   - Check for timing issues

2. **Flaky Tests**
   - Add retries for external dependencies
   - Increase timeouts
   - Mock unstable dependencies

3. **Slow Tests**
   - Profile to find bottlenecks
   - Parallelize where possible
   - Use test doubles

---

## Resources

- [Module Development Guide](MODULE_DEVELOPMENT_GUIDE.md)
- [Architecture Overview](ARCHITECTURE_OVERVIEW.md)
- [Contributing Guide](../CONTRIBUTING.md)

---

**Last Updated**: 2026-02-10  
**Version**: 1.0.0  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
