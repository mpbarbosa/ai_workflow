#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Suite: Project Kind-Aware AI Prompts
# Purpose: Validate project kind prompt loading and generation
################################################################################

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "${LIB_DIR}/.." && pwd)"
export SCRIPT_DIR

source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/ai_helpers.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    if [[ -n "$value" ]]; then
        print_success "✓ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "✗ $test_name - Expected non-empty value"
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
        print_success "✓ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "✗ $test_name - Expected to contain '$needle'"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    if [[ "$expected" == "$actual" ]]; then
        print_success "✓ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_error "✗ $test_name - Expected '$expected', got '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

################################################################################
# Test: Load Project Kind Prompts
################################################################################

test_load_shell_automation_prompts() {
    print_section "Test: Load Shell Automation Prompts"
    
    local role=$(get_project_kind_prompt "shell_automation" "documentation_specialist" "role" 2>&1)
    assert_not_empty "$role" "Shell automation doc specialist role loaded" || true
    assert_contains "$role" "DevOps" "Role mentions DevOps" || true
    
    local task_context=$(get_project_kind_prompt "shell_automation" "test_engineer" "task_context")
    assert_not_empty "$task_context" "Shell automation test context loaded"
    assert_contains "$task_context" "BATS" "Context mentions BATS framework"
    
    local approach=$(get_project_kind_prompt "shell_automation" "code_reviewer" "approach")
    assert_not_empty "$approach" "Shell automation code review approach loaded"
    assert_contains "$approach" "shellcheck" "Approach mentions shellcheck"
}

test_load_nodejs_api_prompts() {
    print_section "Test: Load Node.js API Prompts"
    
    local role=$(get_project_kind_prompt "nodejs_api" "documentation_specialist" "role")
    assert_not_empty "$role" "Node.js API doc specialist role loaded"
    assert_contains "$role" "API" "Role mentions API"
    
    local task_context=$(get_project_kind_prompt "nodejs_api" "test_engineer" "task_context")
    assert_not_empty "$task_context" "Node.js API test context loaded"
    assert_contains "$task_context" "endpoint" "Context mentions endpoints"
    
    local approach=$(get_project_kind_prompt "nodejs_api" "code_reviewer" "approach")
    assert_not_empty "$approach" "Node.js API code review approach loaded"
    assert_contains "$approach" "RESTful" "Approach mentions RESTful"
}

test_load_nodejs_cli_prompts() {
    print_section "Test: Load Node.js CLI Prompts"
    
    local role=$(get_project_kind_prompt "nodejs_cli" "documentation_specialist" "role")
    assert_not_empty "$role" "Node.js CLI doc specialist role loaded"
    assert_contains "$role" "CLI" "Role mentions CLI"
    
    local task_context=$(get_project_kind_prompt "nodejs_cli" "test_engineer" "task_context")
    assert_not_empty "$task_context" "Node.js CLI test context loaded" || true
    assert_contains "$task_context" "Command" "Context mentions commands" || true
}

test_load_web_application_prompts() {
    print_section "Test: Load Web Application Prompts"
    
    local role=$(get_project_kind_prompt "web_application" "documentation_specialist" "role")
    assert_not_empty "$role" "Web app doc specialist role loaded"
    assert_contains "$role" "frontend" "Role mentions frontend"
    
    local task_context=$(get_project_kind_prompt "web_application" "test_engineer" "task_context")
    assert_not_empty "$task_context" "Web app test context loaded" || true
    assert_contains "$task_context" "Component" "Context mentions components" || true
}

test_load_default_prompts() {
    print_section "Test: Load Default Prompts"
    
    local role=$(get_project_kind_prompt "default" "documentation_specialist" "role")
    assert_not_empty "$role" "Default doc specialist role loaded"
    
    local task_context=$(get_project_kind_prompt "default" "test_engineer" "task_context")
    assert_not_empty "$task_context" "Default test context loaded"
    
    local approach=$(get_project_kind_prompt "default" "code_reviewer" "approach")
    assert_not_empty "$approach" "Default code review approach loaded"
}

################################################################################
# Test: Build Project Kind Prompts
################################################################################

test_build_project_kind_prompt() {
    print_section "Test: Build Project Kind Prompt"
    
    export PRIMARY_PROJECT_KIND="shell_automation"
    
    local prompt=$(build_project_kind_prompt "shell_automation" "documentation_specialist" "Document the build system")
    assert_not_empty "$prompt" "Built shell automation prompt"
    assert_contains "$prompt" "**Role**:" "Prompt contains role section"
    assert_contains "$prompt" "**Project Context**:" "Prompt contains project context"
    assert_contains "$prompt" "**Task**:" "Prompt contains task section"
    assert_contains "$prompt" "**Approach**:" "Prompt contains approach section"
    assert_contains "$prompt" "Document the build system" "Prompt contains task description"
}

test_build_project_kind_doc_prompt() {
    print_section "Test: Build Project Kind Documentation Prompt"
    
    export PRIMARY_PROJECT_KIND="nodejs_api"
    
    local prompt=$(build_project_kind_doc_prompt "src/api/routes.js" "docs/api.md")
    assert_not_empty "$prompt" "Built documentation prompt"
    assert_contains "$prompt" "src/api/routes.js" "Prompt contains changed files"
    assert_contains "$prompt" "docs/api.md" "Prompt contains doc files"
    assert_contains "$prompt" "API" "Prompt mentions API"
}

test_build_project_kind_test_prompt() {
    print_section "Test: Build Project Kind Test Prompt"
    
    export PRIMARY_PROJECT_KIND="nodejs_cli"
    
    local prompt=$(build_project_kind_test_prompt "Coverage: 75%" "tests/cli.test.js")
    assert_not_empty "$prompt" "Built test prompt"
    assert_contains "$prompt" "Coverage: 75%" "Prompt contains coverage stats"
    assert_contains "$prompt" "tests/cli.test.js" "Prompt contains test files"
    assert_contains "$prompt" "CLI" "Prompt mentions CLI"
}

test_build_project_kind_review_prompt() {
    print_section "Test: Build Project Kind Review Prompt"
    
    export PRIMARY_PROJECT_KIND="web_application"
    
    local prompt=$(build_project_kind_review_prompt "src/components/Button.jsx" "security")
    assert_not_empty "$prompt" "Built review prompt"
    assert_contains "$prompt" "src/components/Button.jsx" "Prompt contains files to review"
    assert_contains "$prompt" "security" "Prompt contains focus area"
}

################################################################################
# Test: Fallback to Default
################################################################################

test_fallback_to_default() {
    print_section "Test: Fallback to Default for Unknown Project Kind"
    
    local prompt=$(build_project_kind_prompt "unknown_kind" "documentation_specialist" "Test task")
    assert_not_empty "$prompt" "Built prompt for unknown kind"
    assert_contains "$prompt" "Test task" "Prompt contains task"
    # Should fallback to default prompts
}

################################################################################
# Test: Feature Flags
################################################################################

test_should_use_project_kind_prompts() {
    print_section "Test: Feature Flag - Should Use Project Kind Prompts"
    
    export PRIMARY_PROJECT_KIND="shell_automation"
    export USE_PROJECT_KIND_PROMPTS="true"
    
    if should_use_project_kind_prompts; then
        ((TESTS_RUN++))
        print_success "✓ Should use project kind prompts when enabled"
        ((TESTS_PASSED++))
    else
        ((TESTS_RUN++))
        print_error "✗ Should use project kind prompts when enabled"
        ((TESTS_FAILED++))
    fi
    
    export USE_PROJECT_KIND_PROMPTS="false"
    
    if should_use_project_kind_prompts; then
        ((TESTS_RUN++))
        print_error "✗ Should not use project kind prompts when disabled"
        ((TESTS_FAILED++))
    else
        ((TESTS_RUN++))
        print_success "✓ Should not use project kind prompts when disabled"
        ((TESTS_PASSED++))
    fi
    
    unset PRIMARY_PROJECT_KIND
    export USE_PROJECT_KIND_PROMPTS="true"
    
    if should_use_project_kind_prompts; then
        ((TESTS_RUN++))
        print_error "✗ Should not use project kind prompts without detection"
        ((TESTS_FAILED++))
    else
        ((TESTS_RUN++))
        print_success "✓ Should not use project kind prompts without detection"
        ((TESTS_PASSED++))
    fi
}

################################################################################
# Test: Adaptive Prompts (Language + Project Kind)
################################################################################

test_generate_adaptive_prompt() {
    print_section "Test: Generate Adaptive Prompt (Combined)"
    
    export PRIMARY_PROJECT_KIND="shell_automation"
    export PRIMARY_LANGUAGE="bash"
    export USE_PROJECT_KIND_PROMPTS="true"
    export USE_LANGUAGE_AWARE_PROMPTS="true"
    
    local base_prompt="Review the code quality"
    local adaptive_prompt=$(generate_adaptive_prompt "$base_prompt" "quality")
    
    assert_not_empty "$adaptive_prompt" "Generated adaptive prompt"
    assert_contains "$adaptive_prompt" "Review the code quality" "Contains base prompt"
}

################################################################################
# Run All Tests
################################################################################

main() {
    print_header "Project Kind-Aware AI Prompts Test Suite"
    
    test_load_shell_automation_prompts
    test_load_nodejs_api_prompts
    test_load_nodejs_cli_prompts
    test_load_web_application_prompts
    test_load_default_prompts
    
    test_build_project_kind_prompt
    test_build_project_kind_doc_prompt
    test_build_project_kind_test_prompt
    test_build_project_kind_review_prompt
    
    test_fallback_to_default
    test_should_use_project_kind_prompts
    test_generate_adaptive_prompt
    
    # Print summary
    echo ""
    print_header "Test Summary"
    echo "Tests run:    $TESTS_RUN"
    print_success "Tests passed: $TESTS_PASSED"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        print_error "Tests failed: $TESTS_FAILED"
        return 1
    else
        print_success "All tests passed!"
        return 0
    fi
}

main "$@"
