#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Test Script for Batch AI Commit Message Generation
# Purpose: Verify the new AI batch mode functionality
# Version: 1.0.0
################################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}Batch AI Commit - Test Suite${NC}"
echo -e "${CYAN}================================${NC}"
echo ""

# Source required libraries
source "${WORKFLOW_DIR}/lib/batch_ai_commit.sh" || {
    echo -e "${RED}❌ Failed to source batch_ai_commit.sh${NC}"
    exit 1
}

# Mock git cache functions for testing
get_git_current_branch() { echo "main"; }
get_git_commits_ahead() { echo "0"; }
get_git_commits_behind() { echo "0"; }
get_git_modified_count() { echo "5"; }
get_git_staged_count() { echo "5"; }
get_git_untracked_count() { echo "0"; }
get_git_deleted_count() { echo "0"; }
get_git_total_changes() { echo "5"; }
get_git_docs_modified() { echo "5"; }
get_git_tests_modified() { echo "0"; }
get_git_scripts_modified() { echo "0"; }
get_git_code_modified() { echo "0"; }

export -f get_git_current_branch get_git_commits_ahead get_git_commits_behind
export -f get_git_modified_count get_git_staged_count get_git_untracked_count
export -f get_git_deleted_count get_git_total_changes get_git_docs_modified
export -f get_git_tests_modified get_git_scripts_modified get_git_code_modified

# Test 1: Git Context Assembly
test_git_context_assembly() {
    echo -e "${YELLOW}Test 1: Git Context Assembly${NC}"
    
    local context
    context=$(assemble_git_context_for_ai 2>/dev/null)
    
    if [[ -n "$context" ]] && \
       echo "$context" | grep -q "Repository:" && \
       echo "$context" | grep -q "Branch:" && \
       echo "$context" | grep -q "Documentation: 5 files"; then
        echo -e "${GREEN}✅ PASSED: Context assembly works${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Context assembly failed${NC}"
        echo "Context output:"
        echo "$context"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Test 2: Prompt Building
test_prompt_building() {
    echo -e "${YELLOW}Test 2: Prompt Building${NC}"
    
    local context="Repository: test\nBranch: main\nChanges: 5 files"
    local prompt
    prompt=$(build_batch_commit_prompt "$context" 2>/dev/null)
    
    if [[ -n "$prompt" ]] && \
       echo "$prompt" | grep -q "Conventional Commits" && \
       echo "$prompt" | grep -q "REQUIREMENTS"; then
        echo -e "${GREEN}✅ PASSED: Prompt building works${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Prompt building failed${NC}"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Test 3: AI Response Parsing - Valid Response
test_parse_valid_response() {
    echo -e "${YELLOW}Test 3: Parsing Valid AI Response${NC}"
    
    local ai_response="Here's a commit message for you:

docs(documentation): update API documentation

Updated API documentation to reflect new endpoints and parameters.

Key Changes:
- Added new endpoint documentation
- Updated parameter descriptions
- Fixed typos and formatting issues

Affected: docs/api/"
    
    local parsed
    parsed=$(parse_ai_commit_response "$ai_response")
    
    if [[ -n "$parsed" ]] && echo "$parsed" | grep -q "^docs(documentation):"; then
        echo -e "${GREEN}✅ PASSED: Valid response parsed correctly${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Valid response parsing failed${NC}"
        echo "Parsed output: $parsed"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Test 4: AI Response Parsing - With Code Block
test_parse_code_block_response() {
    echo -e "${YELLOW}Test 4: Parsing Response with Code Block${NC}"
    
    local ai_response="\`\`\`text
feat(api): add new user authentication endpoint

Implemented JWT-based authentication for user login.

Key Changes:
- Added /auth/login endpoint
- Implemented JWT token generation
- Added user validation middleware
\`\`\`"
    
    local parsed
    parsed=$(parse_ai_commit_response "$ai_response")
    
    if [[ -n "$parsed" ]] && echo "$parsed" | grep -q "^feat(api):"; then
        echo -e "${GREEN}✅ PASSED: Code block response parsed correctly${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Code block parsing failed${NC}"
        echo "Parsed output: $parsed"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Test 5: Enhanced Fallback Message
test_enhanced_fallback() {
    echo -e "${YELLOW}Test 5: Enhanced Fallback Message Generation${NC}"
    
    SCRIPT_VERSION="2.7.0"
    local fallback
    fallback=$(generate_enhanced_fallback_message 2>/dev/null)
    
    if [[ -n "$fallback" ]] && \
       echo "$fallback" | grep -q "^docs(documentation):" && \
       echo "$fallback" | grep -q "batch mode"; then
        echo -e "${GREEN}✅ PASSED: Enhanced fallback works${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Enhanced fallback failed${NC}"
        echo "Fallback output:"
        echo "$fallback"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Test 6: Invalid Response Handling
test_parse_invalid_response() {
    echo -e "${YELLOW}Test 6: Invalid Response Handling${NC}"
    
    local ai_response="This is not a valid commit message format"
    
    local parsed
    parsed=$(parse_ai_commit_response "$ai_response" 2>/dev/null || echo "")
    
    if [[ -z "$parsed" ]]; then
        echo -e "${GREEN}✅ PASSED: Invalid response rejected correctly${NC}"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}❌ FAILED: Invalid response not rejected${NC}"
        echo "Parsed output: $parsed"
        ((TESTS_FAILED++)) || true
        return 1
    fi
}

# Run all tests
echo "Running tests..."
echo ""

test_git_context_assembly
test_prompt_building
test_parse_valid_response
test_parse_code_block_response
test_enhanced_fallback
test_parse_invalid_response

# Summary
echo ""
echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}Test Summary${NC}"
echo -e "${CYAN}================================${NC}"
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
