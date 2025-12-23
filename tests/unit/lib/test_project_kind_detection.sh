#!/usr/bin/env bash
# Test Suite for Project Kind Detection Module
# Version: 1.0.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/project_kind_detection.sh"
source "${SCRIPT_DIR}/colors.sh" 2>/dev/null || true

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

#######################################
# Test helper functions
#######################################
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    ((TESTS_RUN++))
    echo -n "Testing: $test_name... "
    
    if $test_func; then
        echo "✓ PASS"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAIL"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        echo "  Message: $message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String not found}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        echo "  Message: $message"
        return 1
    fi
}

assert_json_valid() {
    local json="$1"
    
    if echo "$json" | python3 -m json.tool &>/dev/null; then
        return 0
    else
        echo "  Invalid JSON: $json"
        return 1
    fi
}

#######################################
# Test Cases
#######################################

test_detect_current_project() {
    local result
    result=$(detect_project_kind "$SCRIPT_DIR/..")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind"' || return 1
    assert_contains "$result" '"confidence"' || return 1
    assert_contains "$result" '"shell_automation"' "Should detect shell_automation" || return 1
    
    return 0
}

test_detect_shell_automation() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create shell automation project structure
    mkdir -p "$temp_dir/src/workflow"
    mkdir -p "$temp_dir/lib"
    mkdir -p "$temp_dir/scripts"
    touch "$temp_dir/lib/utils.sh"
    touch "$temp_dir/scripts/deploy.sh"
    touch "$temp_dir/src/workflow/main.sh"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "shell_automation"' || return 1
    
    return 0
}

test_detect_nodejs_api() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create Node.js API project structure
    mkdir -p "$temp_dir/src/routes"
    mkdir -p "$temp_dir/src/controllers"
    mkdir -p "$temp_dir/src/models"
    cat > "$temp_dir/package.json" <<'EOF'
{
  "name": "test-api",
  "version": "1.0.0",
  "main": "server.js"
}
EOF
    touch "$temp_dir/server.js"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "nodejs_api"' || return 1
    
    return 0
}

test_detect_static_website() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create static website structure
    mkdir -p "$temp_dir/css"
    mkdir -p "$temp_dir/js"
    mkdir -p "$temp_dir/images"
    touch "$temp_dir/index.html"
    touch "$temp_dir/css/styles.css"
    touch "$temp_dir/js/main.js"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "static_website"' || return 1
    
    return 0
}

test_detect_react_spa() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create React SPA structure
    mkdir -p "$temp_dir/src"
    mkdir -p "$temp_dir/public"
    cat > "$temp_dir/package.json" <<'EOF'
{
  "name": "test-react-app",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0"
  }
}
EOF
    touch "$temp_dir/src/App.jsx"
    touch "$temp_dir/public/index.html"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "react_spa"' || return 1
    
    return 0
}

test_detect_documentation() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create documentation project structure
    mkdir -p "$temp_dir/docs"
    touch "$temp_dir/README.md"
    touch "$temp_dir/CONTRIBUTING.md"
    touch "$temp_dir/docs/guide.md"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "documentation"' || return 1
    
    return 0
}

test_get_project_kind_config() {
    local config
    config=$(get_project_kind_config "shell_automation")
    
    assert_json_valid "$config" || return 1
    assert_contains "$config" '"skip_build":"true"' || return 1
    assert_contains "$config" '"skip_install":"true"' || return 1
    
    return 0
}

test_get_project_kind_config_key() {
    local value
    value=$(get_project_kind_config "nodejs_api" "skip_build")
    
    assert_equals "false" "$value" || return 1
    
    return 0
}

test_validate_project_kind_success() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create shell automation project
    mkdir -p "$temp_dir/src/workflow"
    mkdir -p "$temp_dir/lib"
    touch "$temp_dir/lib/utils.sh"
    
    local result
    result=$(validate_project_kind "shell_automation" "$temp_dir" 30)
    
    assert_contains "$result" "validated" || return 1
    
    return 0
}

test_validate_project_kind_failure() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create Node.js project
    mkdir -p "$temp_dir/src"
    cat > "$temp_dir/package.json" <<'EOF'
{
  "name": "test"
}
EOF
    
    local result
    result=$(validate_project_kind "shell_automation" "$temp_dir" 50 2>&1) || true
    
    assert_contains "$result" "mismatch" || return 1
    
    return 0
}

test_list_supported_project_kinds() {
    local result
    result=$(list_supported_project_kinds)
    
    assert_json_valid "$result" || return 1
    assert_contains "$result" '"kind": "shell_automation"' || return 1
    assert_contains "$result" '"kind": "nodejs_api"' || return 1
    assert_contains "$result" '"kind": "static_website"' || return 1
    
    return 0
}

test_get_project_kind_description() {
    local desc
    desc=$(get_project_kind_description "shell_automation")
    
    assert_contains "$desc" "Shell Script" || return 1
    assert_contains "$desc" "Automation" || return 1
    
    return 0
}

test_confidence_calculation() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create partial match (only some patterns)
    mkdir -p "$temp_dir/src/workflow"
    touch "$temp_dir/lib/utils.sh"
    
    local result
    result=$(detect_project_kind "$temp_dir")
    local confidence
    confidence=$(echo "$result" | grep -oP '"confidence":\s*\K[0-9]+')
    
    # Should have some confidence but not 100%
    [[ $confidence -gt 0 ]] || return 1
    [[ $confidence -lt 100 ]] || return 1
    
    return 0
}

test_unknown_project_kind() {
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" RETURN
    
    # Create empty directory
    
    local result
    result=$(detect_project_kind "$temp_dir")
    
    assert_json_valid "$result" || return 1
    # Should still return valid JSON with unknown kind
    assert_contains "$result" '"kind"' || return 1
    
    return 0
}

test_invalid_directory() {
    local result
    result=$(detect_project_kind "/nonexistent/directory/path" 2>&1)
    
    assert_contains "$result" "error" || return 1
    
    return 0
}

test_workflow_config_all_kinds() {
    local kinds=("shell_automation" "nodejs_api" "static_website" "documentation")
    
    for kind in "${kinds[@]}"; do
        local config
        config=$(get_project_kind_config "$kind")
        assert_json_valid "$config" || return 1
    done
    
    return 0
}

#######################################
# Main test execution
#######################################
main() {
    echo "=========================================="
    echo "Project Kind Detection Module Test Suite"
    echo "=========================================="
    echo ""
    
    # Run all tests
    run_test "Detect current project (ai_workflow)" test_detect_current_project
    run_test "Detect shell automation project" test_detect_shell_automation
    run_test "Detect Node.js API project" test_detect_nodejs_api
    run_test "Detect static website project" test_detect_static_website
    run_test "Detect React SPA project" test_detect_react_spa
    run_test "Detect documentation project" test_detect_documentation
    run_test "Get project kind config (full)" test_get_project_kind_config
    run_test "Get project kind config (single key)" test_get_project_kind_config_key
    run_test "Validate project kind (success)" test_validate_project_kind_success
    run_test "Validate project kind (failure)" test_validate_project_kind_failure
    run_test "List supported project kinds" test_list_supported_project_kinds
    run_test "Get project kind description" test_get_project_kind_description
    run_test "Confidence calculation" test_confidence_calculation
    run_test "Unknown project kind handling" test_unknown_project_kind
    run_test "Invalid directory handling" test_invalid_directory
    run_test "Workflow config for all kinds" test_workflow_config_all_kinds
    
    # Summary
    echo ""
    echo "=========================================="
    echo "Test Results"
    echo "=========================================="
    echo "Total Tests: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "=========================================="
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
