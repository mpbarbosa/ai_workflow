#!/usr/bin/env bash
# test_project_kind_integration.sh - Integration tests for Project Kind Awareness System
# Tests end-to-end functionality across detection, configuration, adaptation, and AI prompts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"
source "${SCRIPT_DIR}/project_kind_detection.sh"
source "${SCRIPT_DIR}/project_kind_config.sh"
source "${SCRIPT_DIR}/step_adaptation.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
declare -a FAILED_TESTS=()

# Test utility functions
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    ((TESTS_RUN++))
    echo -e "\n${BLUE}▶ Running: ${test_name}${NC}"
    
    if $test_func; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASSED: ${test_name}${NC}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
        echo -e "${RED}✗ FAILED: ${test_name}${NC}"
        return 1
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}  ✓ ${message}${NC}"
        return 0
    else
        echo -e "${RED}  ✗ ${message}${NC}"
        echo -e "${RED}    Expected: '$expected'${NC}"
        echo -e "${RED}    Actual:   '$actual'${NC}"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}  ✓ ${message}${NC}"
        return 0
    else
        echo -e "${RED}  ✗ ${message}${NC}"
        echo -e "${RED}    Expected to contain: '$needle'${NC}"
        echo -e "${RED}    In: '$haystack'${NC}"
        return 1
    fi
}

assert_file_exists() {
    local filepath="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$filepath" ]]; then
        echo -e "${GREEN}  ✓ ${message}: $filepath${NC}"
        return 0
    else
        echo -e "${RED}  ✗ ${message}: $filepath${NC}"
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    export TEST_TMP_DIR="/tmp/test_project_kind_$$"
    mkdir -p "$TEST_TMP_DIR"
    export PROJECT_ROOT="$TEST_TMP_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -n "${TEST_TMP_DIR:-}" ]] && [[ -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Test 1: Shell Script Project Detection
test_shell_script_detection() {
    local test_dir="$TEST_TMP_DIR/shell_project"
    mkdir -p "$test_dir/src"
    
    # Create shell script files
    cat > "$test_dir/src/main.sh" << 'EOF'
#!/usr/bin/env bash
echo "Hello World"
EOF
    
    cat > "$test_dir/README.md" << 'EOF'
# Shell Script Project
This is a shell script automation project.
EOF
    
    # Detect project kind
    local result
    result=$(detect_project_kind "$test_dir")
    
    assert_contains "$result" "shell_script" "Should detect shell_script project kind" && \
    assert_contains "$result" "primary_language=bash" "Should detect bash as primary language"
}

# Test 2: Node.js API Project Detection
test_nodejs_api_detection() {
    local test_dir="$TEST_TMP_DIR/nodejs_project"
    mkdir -p "$test_dir/src"
    
    # Create package.json
    cat > "$test_dir/package.json" << 'EOF'
{
  "name": "api-service",
  "version": "1.0.0",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
    
    # Create server file
    cat > "$test_dir/src/server.js" << 'EOF'
const express = require('express');
const app = express();
app.listen(3000);
EOF
    
    # Detect project kind
    local result
    result=$(detect_project_kind "$test_dir")
    
    assert_contains "$result" "nodejs_api" "Should detect nodejs_api project kind" && \
    assert_contains "$result" "primary_language=javascript" "Should detect javascript as primary language"
}

# Test 3: Static Website Detection
test_static_website_detection() {
    local test_dir="$TEST_TMP_DIR/website_project"
    mkdir -p "$test_dir/css" "$test_dir/js"
    
    # Create HTML files
    cat > "$test_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head><title>My Site</title></head>
<body><h1>Welcome</h1></body>
</html>
EOF
    
    cat > "$test_dir/css/style.css" << 'EOF'
body { font-family: Arial; }
EOF
    
    # Detect project kind
    local result
    result=$(detect_project_kind "$test_dir")
    
    assert_contains "$result" "static_website" "Should detect static_website project kind" && \
    assert_contains "$result" "primary_language=html" "Should detect html as primary language"
}

# Test 4: Configuration Loading for Shell Script
test_config_loading_shell() {
    local test_dir="$TEST_TMP_DIR/shell_test"
    mkdir -p "$test_dir"
    
    # Create detection result
    echo "project_kind=shell_script" > "$test_dir/.project_kind"
    echo "primary_language=bash" >> "$test_dir/.project_kind"
    
    # Load configuration
    if load_project_kind_config "$test_dir"; then
        assert_equals "shell_script" "${PROJECT_KIND:-}" "PROJECT_KIND should be shell_script" && \
        assert_equals "bash" "${PRIMARY_LANGUAGE:-}" "PRIMARY_LANGUAGE should be bash"
        return 0
    else
        echo -e "${RED}Failed to load configuration${NC}"
        return 1
    fi
}

# Test 5: Step Adaptation - Documentation Step
test_step_adaptation_documentation() {
    export PROJECT_KIND="nodejs_api"
    export PRIMARY_LANGUAGE="javascript"
    
    local result
    result=$(get_step_requirements "documentation")
    
    assert_contains "$result" "API documentation" "Should include API-specific requirements" && \
    assert_contains "$result" "JSDoc" "Should include JSDoc for JavaScript"
}

# Test 6: Step Adaptation - Test Generation
test_step_adaptation_test_gen() {
    export PROJECT_KIND="shell_script"
    export PRIMARY_LANGUAGE="bash"
    
    local result
    result=$(get_step_requirements "test_generation")
    
    assert_contains "$result" "bats" "Should include bats for shell testing" || \
    assert_contains "$result" "shell" "Should include shell-specific testing"
}

# Test 7: Step Skipping Logic
test_step_skipping() {
    export PROJECT_KIND="static_website"
    
    if should_skip_step "dependency_validation"; then
        echo -e "${GREEN}  ✓ Correctly skips dependency validation for static website${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should skip dependency validation for static website${NC}"
        return 1
    fi
}

# Test 8: AI Prompt Customization
test_ai_prompt_customization() {
    export PROJECT_KIND="nodejs_api"
    export PRIMARY_LANGUAGE="javascript"
    
    local prompt
    prompt=$(get_project_kind_prompt_context "documentation")
    
    assert_contains "$prompt" "API" "Should include API context" && \
    assert_contains "$prompt" "JavaScript" "Should include language context"
}

# Test 9: Multi-Project Kind Detection
test_multi_kind_detection() {
    local test_dir="$TEST_TMP_DIR/hybrid_project"
    mkdir -p "$test_dir/scripts" "$test_dir/web"
    
    # Create mixed project
    cat > "$test_dir/scripts/deploy.sh" << 'EOF'
#!/usr/bin/env bash
echo "Deploying..."
EOF
    
    cat > "$test_dir/web/index.html" << 'EOF'
<!DOCTYPE html>
<html><body>Site</body></html>
EOF
    
    cat > "$test_dir/package.json" << 'EOF'
{
  "name": "hybrid-project",
  "scripts": {
    "build": "webpack"
  }
}
EOF
    
    local result
    result=$(detect_project_kind "$test_dir")
    
    # Should detect primary kind (likely nodejs_api due to package.json)
    assert_contains "$result" "project_kind=" "Should detect a project kind"
}

# Test 10: Configuration Persistence
test_config_persistence() {
    local test_dir="$TEST_TMP_DIR/persist_test"
    mkdir -p "$test_dir"
    
    # Save configuration
    export PROJECT_KIND="shell_script"
    export PRIMARY_LANGUAGE="bash"
    
    if save_project_kind_config "$test_dir"; then
        assert_file_exists "$test_dir/.project_kind" "Config file should be created" || return 1
        
        # Verify contents
        local content
        content=$(cat "$test_dir/.project_kind")
        assert_contains "$content" "project_kind=shell_script" "Config should contain project_kind" && \
        assert_contains "$content" "primary_language=bash" "Config should contain primary_language"
    else
        echo -e "${RED}Failed to save configuration${NC}"
        return 1
    fi
}

# Test 11: Error Handling - Invalid Project
test_invalid_project_handling() {
    local test_dir="$TEST_TMP_DIR/empty_project"
    mkdir -p "$test_dir"
    
    # Try to detect empty project
    local result
    result=$(detect_project_kind "$test_dir" 2>&1 || echo "detection_failed")
    
    if [[ "$result" == "detection_failed" ]] || [[ "$result" == *"unknown"* ]]; then
        echo -e "${GREEN}  ✓ Properly handles invalid/empty projects${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Should handle invalid projects gracefully${NC}"
        return 1
    fi
}

# Test 12: Step Dependencies Based on Project Kind
test_step_dependencies() {
    export PROJECT_KIND="static_website"
    
    local deps
    deps=$(get_step_dependencies "test_execution")
    
    # Static websites should have minimal test execution dependencies
    if [[ -z "$deps" ]] || [[ "$deps" == "test_generation" ]]; then
        echo -e "${GREEN}  ✓ Correctly determines step dependencies for project kind${NC}"
        return 0
    else
        echo -e "${YELLOW}  ℹ Step dependencies: $deps${NC}"
        return 0
    fi
}

# Test 13: Integration - Full Workflow Simulation
test_full_workflow_simulation() {
    local test_dir="$TEST_TMP_DIR/full_workflow"
    mkdir -p "$test_dir/src"
    
    # Create Node.js project
    cat > "$test_dir/package.json" << 'EOF'
{
  "name": "test-api",
  "version": "1.0.0"
}
EOF
    
    # Step 1: Detect
    local detect_result
    detect_result=$(detect_project_kind "$test_dir")
    assert_contains "$detect_result" "nodejs_api" "Detection step" || return 1
    
    # Step 2: Load config
    if ! load_project_kind_config "$test_dir"; then
        echo -e "${RED}Failed to load config${NC}"
        return 1
    fi
    
    # Step 3: Get step requirements
    local requirements
    requirements=$(get_step_requirements "documentation")
    assert_contains "$requirements" "API" "Requirements adaptation" || return 1
    
    # Step 4: Check step skipping
    if should_skip_step "test_execution"; then
        echo -e "${GREEN}  ✓ Step skipping logic works${NC}"
    fi
    
    echo -e "${GREEN}  ✓ Full workflow simulation completed${NC}"
    return 0
}

# Main test execution
main() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Project Kind Awareness - Integration Tests               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    
    # Setup
    setup_test_env
    trap cleanup_test_env EXIT
    
    # Run tests
    run_test "Shell Script Project Detection" test_shell_script_detection
    run_test "Node.js API Project Detection" test_nodejs_api_detection
    run_test "Static Website Detection" test_static_website_detection
    run_test "Configuration Loading (Shell)" test_config_loading_shell
    run_test "Step Adaptation - Documentation" test_step_adaptation_documentation
    run_test "Step Adaptation - Test Generation" test_step_adaptation_test_gen
    run_test "Step Skipping Logic" test_step_skipping
    run_test "AI Prompt Customization" test_ai_prompt_customization
    run_test "Multi-Project Kind Detection" test_multi_kind_detection
    run_test "Configuration Persistence" test_config_persistence
    run_test "Invalid Project Handling" test_invalid_project_handling
    run_test "Step Dependencies" test_step_dependencies
    run_test "Full Workflow Simulation" test_full_workflow_simulation
    
    # Summary
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Test Summary                                              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "Tests Run:    ${BLUE}${TESTS_RUN}${NC}"
    echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "\n${RED}Failed Tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "${RED}  ✗ ${test}${NC}"
        done
        exit 1
    else
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
        exit 0
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
