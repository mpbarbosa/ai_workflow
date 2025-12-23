#!/bin/bash
################################################################################
# Test Suite for Step 14: UX Analysis
# Purpose: Test UI detection and UX analysis functionality
# Part of: Tests & Documentation Workflow Automation v2.4.0
# Created: December 23, 2025
################################################################################

# IMPORTANT: Don't use strict error handling in tests - we need to capture return codes
set +e
set -uo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WORKFLOW_LIB_DIR="${PROJECT_ROOT}/src/workflow/lib"
WORKFLOW_STEPS_DIR="${PROJECT_ROOT}/src/workflow/steps"

# Load color definitions
source "${WORKFLOW_LIB_DIR}/colors.sh"

# Disable strict error handling from sourced files
set +e

# Load required libraries for Step 14
source "${WORKFLOW_LIB_DIR}/utils.sh" 2>/dev/null || true

# Set test mode to prevent step script from enabling strict error handling
export TEST_MODE=1

# Define print functions if not available
if ! type -t print_info &>/dev/null; then
    print_info() { echo "ℹ️  $1"; }
fi
if ! type -t print_success &>/dev/null; then
    print_success() { echo -e "${GREEN}✅ $1${NC}"; }
fi
if ! type -t print_warning &>/dev/null; then
    print_warning() { echo -e "${YELLOW}⚠️  WARNING: $1${NC}"; }
fi
if ! type -t print_error &>/dev/null; then
    print_error() { echo -e "${RED}❌ ERROR: $1${NC}" >&2; }
fi

# Load Step 14
source "${WORKFLOW_STEPS_DIR}/step_14_ux_analysis.sh" 2>/dev/null || {
    echo "ERROR: Failed to load step_14_ux_analysis.sh"
    exit 1
}

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results
declare -a FAILED_TESTS

# ==============================================================================
# TEST HELPERS
# ==============================================================================

print_test_header() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "${expected}" == "${actual}" ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected: ${expected}"
        echo -e "  Actual:   ${actual}"
        return 1
    fi
}

assert_success() {
    local return_code="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ ${return_code} -eq 0 ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected: return code 0"
        echo -e "  Actual:   return code ${return_code}"
        return 1
    fi
}

assert_failure() {
    local return_code="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ ${return_code} -ne 0 ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++))
        FAILED_TESTS+=("${test_name}")
        echo -e "${RED}✗${NC} ${test_name}"
        echo -e "  Expected: non-zero return code"
        echo -e "  Actual:   return code 0"
        return 1
    fi
}

# ==============================================================================
# TEST FIXTURES
# ==============================================================================

setup_test_project() {
    local project_type="$1"
    local test_dir="${SCRIPT_DIR}/test_projects/${project_type}"
    
    # Clean up if exists
    rm -rf "$test_dir" 2>/dev/null || true
    mkdir -p "$test_dir"
    
    case "$project_type" in
        react_spa)
            mkdir -p "${test_dir}/src/components"
            cat > "${test_dir}/src/App.jsx" << 'EOF'
import React from 'react';

function App() {
  return (
    <div className="App">
      <h1>Hello World</h1>
      <img src="logo.png" />
    </div>
  );
}

export default App;
EOF
            cat > "${test_dir}/src/components/Button.jsx" << 'EOF'
export function Button({ onClick, children }) {
  return <button onClick={onClick}>{children}</button>;
}
EOF
            ;;
            
        static_website)
            cat > "${test_dir}/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Site</title>
</head>
<body>
    <h1>Welcome</h1>
    <img src="image.jpg">
    <form>
        <input type="text" name="email">
        <button>Submit</button>
    </form>
</body>
</html>
EOF
            mkdir -p "${test_dir}/css"
            cat > "${test_dir}/css/style.css" << 'EOF'
body { margin: 0; padding: 0; }
EOF
            ;;
            
        nodejs_api)
            mkdir -p "${test_dir}/src"
            cat > "${test_dir}/src/server.js" << 'EOF'
const express = require('express');
const app = express();

app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});

app.listen(3000);
EOF
            cat > "${test_dir}/package.json" << 'EOF'
{
  "name": "test-api",
  "version": "1.0.0",
  "main": "src/server.js"
}
EOF
            ;;
            
        shell_automation)
            mkdir -p "${test_dir}/src"
            cat > "${test_dir}/src/script.sh" << 'EOF'
#!/bin/bash
echo "Automation script"
EOF
            chmod +x "${test_dir}/src/script.sh"
            ;;
    esac
    
    echo "$test_dir"
}

cleanup_test_projects() {
    rm -rf "${SCRIPT_DIR}/test_projects" 2>/dev/null || true
}

# ==============================================================================
# UI DETECTION TESTS
# ==============================================================================

test_ui_detection() {
    print_test_header "UI Detection Tests"
    
    # Test 1: React SPA detection
    local react_dir=$(setup_test_project "react_spa")
    export PROJECT_KIND="react_spa"
    export TARGET_PROJECT_ROOT="$react_dir"
    export PROJECT_ROOT="$react_dir"
    
    has_ui_components
    assert_success $? "Detects UI in React SPA project"
    
    # Test 2: Static website detection
    local static_dir=$(setup_test_project "static_website")
    export PROJECT_KIND="static_website"
    export TARGET_PROJECT_ROOT="$static_dir"
    export PROJECT_ROOT="$static_dir"
    
    has_ui_components
    assert_success $? "Detects UI in static website project"
    
    # Test 3: API-only project (should not detect UI)
    local api_dir=$(setup_test_project "nodejs_api")
    export PROJECT_KIND="nodejs_api"
    export TARGET_PROJECT_ROOT="$api_dir"
    export PROJECT_ROOT="$api_dir"
    
    has_ui_components
    assert_failure $? "Does not detect UI in API-only project"
    
    # Test 4: Shell automation project (should not detect UI)
    local shell_dir=$(setup_test_project "shell_automation")
    export PROJECT_KIND="shell_automation"
    export TARGET_PROJECT_ROOT="$shell_dir"
    export PROJECT_ROOT="$shell_dir"
    
    has_ui_components
    assert_failure $? "Does not detect UI in shell automation project"
}

# ==============================================================================
# UI FILE DISCOVERY TESTS
# ==============================================================================

test_ui_file_discovery() {
    print_test_header "UI File Discovery Tests"
    
    # Test 1: Find JSX files in React project
    local react_dir=$(setup_test_project "react_spa")
    export TARGET_PROJECT_ROOT="$react_dir"
    export PROJECT_ROOT="$react_dir"
    
    local ui_files
    ui_files=$(find_ui_files)
    local file_count=$(echo "$ui_files" | grep -c "\.jsx$" || echo "0")
    
    [[ $file_count -ge 2 ]]
    assert_success $? "Finds JSX files in React project (found $file_count)"
    
    # Test 2: Find HTML and CSS in static website
    local static_dir=$(setup_test_project "static_website")
    export TARGET_PROJECT_ROOT="$static_dir"
    export PROJECT_ROOT="$static_dir"
    
    ui_files=$(find_ui_files)
    local html_count=$(echo "$ui_files" | grep -c "\.html$" || echo "0")
    local css_count=$(echo "$ui_files" | grep -c "\.css$" || echo "0")
    
    [[ $html_count -ge 1 && $css_count -ge 1 ]]
    assert_success $? "Finds HTML and CSS in static website"
    
    # Test 3: Empty result for API project
    local api_dir=$(setup_test_project "nodejs_api")
    export TARGET_PROJECT_ROOT="$api_dir"
    export PROJECT_ROOT="$api_dir"
    
    ui_files=$(find_ui_files)
    local ui_file_count=$(echo "$ui_files" | grep -v "^$" | wc -l || echo "0")
    
    [[ $ui_file_count -eq 0 ]]
    assert_success $? "Returns empty for API-only project"
}

# ==============================================================================
# STEP EXECUTION CONTROL TESTS
# ==============================================================================

test_step_execution_control() {
    print_test_header "Step Execution Control Tests"
    
    # Test 1: Should run for react_spa
    export PROJECT_KIND="react_spa"
    local react_dir=$(setup_test_project "react_spa")
    export TARGET_PROJECT_ROOT="$react_dir"
    export PROJECT_ROOT="$react_dir"
    
    should_run_ux_analysis_step
    assert_success $? "Should run for react_spa project"
    
    # Test 2: Should run for static_website
    export PROJECT_KIND="static_website"
    local static_dir=$(setup_test_project "static_website")
    export TARGET_PROJECT_ROOT="$static_dir"
    export PROJECT_ROOT="$static_dir"
    
    should_run_ux_analysis_step
    assert_success $? "Should run for static_website project"
    
    # Test 3: Should skip for shell_automation
    export PROJECT_KIND="shell_automation"
    local shell_dir=$(setup_test_project "shell_automation")
    export TARGET_PROJECT_ROOT="$shell_dir"
    export PROJECT_ROOT="$shell_dir"
    
    should_run_ux_analysis_step
    assert_failure $? "Should skip for shell_automation project"
    
    # Test 4: Should skip for nodejs_library
    export PROJECT_KIND="nodejs_library"
    should_run_ux_analysis_step
    assert_failure $? "Should skip for nodejs_library project"
}

# ==============================================================================
# AUTOMATED UX CHECKS TESTS
# ==============================================================================

test_automated_ux_checks() {
    print_test_header "Automated UX Checks Tests"
    
    # Setup static website with accessibility issues
    local static_dir=$(setup_test_project "static_website")
    export TARGET_PROJECT_ROOT="$static_dir"
    export PROJECT_ROOT="$static_dir"
    
    # Run automated checks
    local report_output
    report_output=$(perform_automated_ux_checks)
    
    # Test 1: Report contains expected sections
    echo "$report_output" | grep -q "UX Analysis Report"
    assert_success $? "Report contains title"
    
    # Test 2: Report identifies missing alt text
    echo "$report_output" | grep -q "alt"
    assert_success $? "Report mentions alt text"
    
    # Test 3: Report contains recommendations
    echo "$report_output" | grep -q "Recommendations"
    assert_success $? "Report contains recommendations section"
}

# ==============================================================================
# MAIN TEST RUNNER
# ==============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}Step 14: UX Analysis Test Suite${NC}                            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    # Create test projects directory
    mkdir -p "${SCRIPT_DIR}/test_projects"
    
    # Run test suites
    test_ui_detection
    test_ui_file_discovery
    test_step_execution_control
    test_automated_ux_checks
    
    # Cleanup
    cleanup_test_projects
    
    # Print summary
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Tests run:    ${TESTS_RUN}"
    echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo ""
        echo -e "${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  - ${test}"
        done
        echo ""
        exit 1
    else
        echo ""
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        exit 0
    fi
}

# Run tests
main "$@"
