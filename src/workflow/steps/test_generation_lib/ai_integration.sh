#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 7 AI Integration Module
# Purpose: AI prompts for test generation
# Part of: Step 7 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.7
################################################################################

# Build test generation prompt
# Usage: build_test_generation_prompt_step6 <untested_count> <untested_files>
build_test_generation_prompt_step6() {
    local untested_count="$1"
    local untested_files="$2"
    
    local prompt="## Test Generation Request\n\n"
    prompt+="I need help generating tests for $untested_count untested modules.\n\n"
    prompt+="### Untested Files\n$untested_files\n\n"
    prompt+="### Requirements\n"
    prompt+="- Comprehensive test coverage\n"
    prompt+="- Edge case handling\n"
    prompt+="- Clear test descriptions\n"
    
    echo -e "$prompt"
}

# Execute test generation workflow
# Usage: run_ai_test_generation_workflow_step6 <untested_count> <untested_files>
run_ai_test_generation_workflow_step6() {
    local untested_count="$1"
    local untested_files="$2"
    
    [[ $untested_count -eq 0 ]] && return 0
    
    local prompt=$(build_test_generation_prompt_step6 "$untested_count" "$untested_files")
    
    print_info "AI test generation prompt ready"
    echo -e "${CYAN}$prompt${NC}"
    
    if [[ "${DRY_RUN:-false}" != "true" ]] && confirm_action "Generate tests with AI?" "n"; then
        print_info "Test generation initiated"
    else
        print_info "Test generation skipped"
    fi
    
    return 0
}

export -f build_test_generation_prompt_step6
export -f run_ai_test_generation_workflow_step6
