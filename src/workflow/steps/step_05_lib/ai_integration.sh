#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 5 AI Integration Module  
# Purpose: AI prompts and Copilot CLI integration for test review
# Part of: Step 5 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# PROMPT BUILDING
# ==============================================================================

# Build test review prompt
# Usage: build_test_review_prompt_step5 <test_count> <test_files> <coverage_summary> <issues>
# Returns: Complete AI prompt
build_test_review_prompt_step5() {
    local test_count="$1"
    local test_files="$2"
    local coverage_summary="${3:-No coverage data available}"
    local issues="${4:-None detected}"
    
    local prompt=""
    
    prompt="## Test Review Request\n\n"
    prompt+="I need help reviewing the existing test suite for quality and completeness.\n\n"
    
    prompt+="### Test Suite Context\n"
    prompt+="- **Test Files Found**: $test_count\n"
    prompt+="- **Coverage Data**: $coverage_summary\n"
    prompt+="- **Automated Issues**: $issues\n\n"
    
    prompt+="### Test Files\n"
    prompt+="$test_files\n\n"
    
    prompt+="### Review Criteria\n\n"
    prompt+="Please analyze the test suite for:\n\n"
    prompt+="1. **Coverage Gaps**\n"
    prompt+="   - Untested functions or modules\n"
    prompt+="   - Missing edge cases\n"
    prompt+="   - Uncovered error paths\n\n"
    
    prompt+="2. **Test Quality**\n"
    prompt+="   - Test clarity and maintainability\n"
    prompt+="   - Proper assertions\n"
    prompt+="   - Test isolation\n"
    prompt+="   - Mock/stub usage\n\n"
    
    prompt+="3. **Best Practices**\n"
    prompt+="   - Naming conventions\n"
    prompt+="   - Test organization\n"
    prompt+="   - Setup/teardown patterns\n"
    prompt+="   - Test data management\n\n"
    
    prompt+="4. **Recommendations**\n"
    prompt+="   - Priority improvements\n"
    prompt+="   - Additional test scenarios\n"
    prompt+="   - Refactoring opportunities\n"
    
    echo -e "$prompt"
}

# Enhance with language-specific testing conventions
# Usage: enhance_test_review_prompt_step5 <base_prompt> <language>
# Returns: Enhanced prompt
enhance_test_review_prompt_step5() {
    local base_prompt="$1"
    local language="${2:-javascript}"
    local enhanced="$base_prompt"
    
    # Add language-specific testing conventions if available
    if command -v should_use_language_aware_prompts &>/dev/null && \
       should_use_language_aware_prompts; then
        if command -v get_language_test_conventions &>/dev/null; then
            local test_conventions
            test_conventions=$(get_language_test_conventions "$language")
            
            if [[ -n "$test_conventions" ]] && [[ "$test_conventions" != "No language specified" ]]; then
                enhanced+="\n\n**${language^} Testing Conventions:**\n"
                enhanced+="$test_conventions\n"
                print_info "Using language-aware test review for $language"
            fi
        fi
    fi
    
    echo -e "$enhanced"
}

# ==============================================================================
# AI EXECUTION
# ==============================================================================

# Execute test review with Copilot CLI
# Usage: execute_test_review_step5 <prompt> <log_file>
# Returns: 0 on success, 1 if skipped
execute_test_review_step5() {
    local prompt="$1"
    local log_file="$2"
    
    # Display prompt
    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Test Review Prompt:${NC}"
    echo -e "${YELLOW}${prompt}${NC}\n"
    
    # Check dry run
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        print_info "[DRY RUN] Would invoke Copilot with test review prompt"
        return 0
    fi
    
    # Confirm execution
    if ! confirm_action "Run GitHub Copilot CLI to review existing tests?" "y"; then
        print_warning "Skipped GitHub Copilot CLI test review"
        return 1
    fi
    
    # Execute Copilot
    print_info "Starting Copilot CLI session..."
    print_info "Logging output to: $log_file"
    
    if command -v execute_copilot_prompt &>/dev/null; then
        execute_copilot_prompt "$prompt" "$log_file"
    else
        # Fallback execution with comprehensive flags
        copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee "$log_file"
    fi
    
    print_success "GitHub Copilot CLI session completed"
    print_info "Full session log saved to: $log_file"
    
    # Extract issues
    if command -v extract_and_save_issues_from_log &>/dev/null; then
        extract_and_save_issues_from_log "5" "Test_Review" "$log_file"
    fi
    
    return 0
}

# ==============================================================================
# WORKFLOW
# ==============================================================================

# Run complete AI test review workflow
# Usage: run_ai_test_review_workflow_step5 <test_count> <test_files> <coverage_summary> <issues>
# Returns: 0 on success, 1 if skipped
run_ai_test_review_workflow_step5() {
    local test_count="$1"
    local test_files="$2"
    local coverage_summary="${3:-No coverage data}"
    local issues="${4:-None}"
    
    # Build prompt
    local prompt
    prompt=$(build_test_review_prompt_step5 "$test_count" "$test_files" "$coverage_summary" "$issues")
    
    # Enhance with language conventions
    prompt=$(enhance_test_review_prompt_step5 "$prompt" "${PRIMARY_LANGUAGE:-javascript}")
    
    # Create log file
    local log_timestamp
    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    local log_file="${LOGS_RUN_DIR:-./logs}/step5_copilot_test_review_${log_timestamp}.log"
    
    # Execute review
    execute_test_review_step5 "$prompt" "$log_file"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f build_test_review_prompt_step5
export -f enhance_test_review_prompt_step5
export -f execute_test_review_step5
export -f run_ai_test_review_workflow_step5
