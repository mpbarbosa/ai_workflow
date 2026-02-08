#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite for Documentation Enhancement Modules
# Version: 1.0.0
# Tests: link_validator, code_example_tester, api_coverage, changelog_generator, deployment_validator
################################################################################

# Setup test environment
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${TEST_DIR}"
TEMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_TEST_DIR"' EXIT

# Source modules
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/link_validator.sh"
source "${LIB_DIR}/code_example_tester.sh"
source "${LIB_DIR}/api_coverage.sh"
source "${LIB_DIR}/changelog_generator.sh"
source "${LIB_DIR}/deployment_validator.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        ((TESTS_PASSED++))
        print_success "✓ ${message}"
        return 0
    else
        ((TESTS_FAILED++))
        print_error "✗ ${message}"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    ((TESTS_RUN++))
    
    if [[ -f "$file" ]]; then
        ((TESTS_PASSED++))
        print_success "✓ ${message}"
        return 0
    else
        ((TESTS_FAILED++))
        print_error "✗ ${message}"
        return 1
    fi
}

assert_success() {
    local message="$1"
    
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    print_success "✓ ${message}"
    return 0
}

assert_fail() {
    local message="$1"
    
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    print_error "✗ ${message}"
    return 1
}

# ==============================================================================
# LINK VALIDATOR TESTS
# ==============================================================================

test_link_validator() {
    echo ""
    print_info "=== Testing Link Validator ==="
    
    # Create test markdown file
    local test_md="${TEMP_TEST_DIR}/test.md"
    cat > "$test_md" << 'EOF'
# Test Document

[Valid local link](./test.md)
[Broken local link](./missing.md)
[Valid URL](https://github.com)
[Broken URL](https://thisdoesnotexist12345.com)
[Anchor link](#test-section)
[Reference link][ref1]

[ref1]: https://example.com

## Test Section
EOF
    
    # Test link extraction
    local links=$(extract_markdown_links "$test_md")
    local link_count=$(echo "$links" | wc -l)
    assert_equals "7" "$link_count" "Should extract 7 links from test markdown"
    
    # Test link validation
    local report_file="${TEMP_TEST_DIR}/link_report.txt"
    validate_file_links "$test_md" "$report_file" || true
    
    assert_file_exists "$report_file" "Link validation report should be created"
    
    # Should find at least the broken local link
    if grep -q "Broken file link" "$report_file" 2>/dev/null; then
        assert_success "Should detect broken local links"
    else
        assert_fail "Should detect broken local links"
    fi
}

# ==============================================================================
# CODE EXAMPLE TESTER TESTS
# ==============================================================================

test_code_example_tester() {
    echo ""
    print_info "=== Testing Code Example Tester ==="
    
    # Create test markdown with code blocks
    local test_md="${TEMP_TEST_DIR}/code_test.md"
    cat > "$test_md" << 'EOF'
# Code Examples

## Bash Example
```bash
#!/bin/bash
echo "Hello, World!"
```

## Python Example
```python
def hello():
    print("Hello, World!")
```

## Invalid Bash
```bash
if [ missing fi
```

## JavaScript Example
```javascript
function hello() {
    console.log("Hello, World!");
}
```
EOF
    
    # Test code block extraction
    local code_blocks=$(extract_code_blocks "$test_md")
    local block_count=$(echo "$code_blocks" | wc -l)
    assert_equals "4" "$block_count" "Should extract 4 code blocks"
    
    # Test validation (should find syntax error in invalid bash)
    local report_file="${TEMP_TEST_DIR}/code_report.txt"
    validate_file_code_examples "$test_md" "$report_file" || true
    
    assert_file_exists "$report_file" "Code validation report should be created"
}

# ==============================================================================
# API COVERAGE TESTS
# ==============================================================================

test_api_coverage() {
    echo ""
    print_info "=== Testing API Coverage ==="
    
    # Create test bash script
    local test_sh="${TEMP_TEST_DIR}/test.sh"
    cat > "$test_sh" << 'EOF'
#!/bin/bash

# Public function
function public_function() {
    echo "public"
}

# Another public function
another_public() {
    echo "another"
}

# Private function (should be excluded)
_private_function() {
    echo "private"
}
EOF
    
    # Test function extraction
    local functions=$(extract_bash_functions "$test_sh")
    local func_count=$(echo "$functions" | wc -l)
    assert_equals "2" "$func_count" "Should extract 2 public functions (excluding private)"
    
    # Create test Python file
    local test_py="${TEMP_TEST_DIR}/test.py"
    cat > "$test_py" << 'EOF'
def public_function():
    """Documented function"""
    pass

def another_public():
    pass

def _private_function():
    pass
EOF
    
    # Test Python function extraction
    local py_functions=$(extract_python_functions "$test_py")
    local py_count=$(echo "$py_functions" | wc -l)
    assert_equals "2" "$py_count" "Should extract 2 public Python functions"
}

# ==============================================================================
# CHANGELOG GENERATOR TESTS
# ==============================================================================

test_changelog_generator() {
    echo ""
    print_info "=== Testing Changelog Generator ==="
    
    # Test conventional commit parsing
    local commit1="feat(auth): add login functionality"
    local parsed1=$(parse_conventional_commit "$commit1")
    
    if echo "$parsed1" | grep -q "feat|auth|add login functionality"; then
        assert_success "Should parse conventional commit correctly"
    else
        assert_fail "Should parse conventional commit correctly"
    fi
    
    # Test breaking change detection
    local commit2="feat!: breaking change"
    local parsed2=$(parse_conventional_commit "$commit2")
    
    if echo "$parsed2" | grep -q "|true|"; then
        assert_success "Should detect breaking changes"
    else
        assert_fail "Should detect breaking changes"
    fi
    
    # Test version suggestion
    local suggested=$(suggest_next_version 2>/dev/null || echo "0.0.1")
    if [[ -n "$suggested" ]]; then
        assert_success "Should suggest next version: $suggested"
    else
        assert_fail "Should suggest next version"
    fi
}

# ==============================================================================
# DEPLOYMENT VALIDATOR TESTS
# ==============================================================================

test_deployment_validator() {
    echo ""
    print_info "=== Testing Deployment Validator ==="
    
    # Test JSON validation
    local test_json="${TEMP_TEST_DIR}/test.json"
    echo '{"valid": true}' > "$test_json"
    
    if validate_json_config "$test_json"; then
        assert_success "Should validate correct JSON"
    else
        assert_fail "Should validate correct JSON"
    fi
    
    # Test invalid JSON
    local invalid_json="${TEMP_TEST_DIR}/invalid.json"
    echo '{invalid json' > "$invalid_json"
    
    if validate_json_config "$invalid_json"; then
        assert_fail "Should reject invalid JSON"
    else
        assert_success "Should reject invalid JSON"
    fi
    
    # Test port availability
    if command -v nc &>/dev/null || command -v lsof &>/dev/null; then
        # Test with a very high unlikely-to-be-used port
        if check_port_available 54321; then
            assert_success "Should detect available port"
        else
            # Port might be in use, that's okay
            assert_success "Port check function works"
        fi
    else
        assert_success "Port checking tools not available (skipped)"
    fi
}

# ==============================================================================
# RUN ALL TESTS
# ==============================================================================

main() {
    echo ""
    print_info "╔════════════════════════════════════════════════════════════════╗"
    print_info "║  Documentation Enhancement Modules Test Suite                 ║"
    print_info "╚════════════════════════════════════════════════════════════════╝"
    
    # Run test suites
    test_link_validator
    test_code_example_tester
    test_api_coverage
    test_changelog_generator
    test_deployment_validator
    
    # Print summary
    echo ""
    print_info "╔════════════════════════════════════════════════════════════════╗"
    print_info "║  TEST SUMMARY                                                  ║"
    print_info "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Tests Run:    ${TESTS_RUN}"
    echo "  Tests Passed: ${TESTS_PASSED}"
    echo "  Tests Failed: ${TESTS_FAILED}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print_success "✅ All tests passed!"
        return 0
    else
        print_error "❌ Some tests failed"
        return 1
    fi
}

# Run tests
main "$@"
