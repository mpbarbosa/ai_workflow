#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2 AI Integration Module
# Purpose: AI prompt building and Copilot CLI integration for consistency analysis
# Part of: Step 2 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# PROMPT BUILDING
# ==============================================================================

# Build Step 2 consistency analysis prompt
# Usage: build_consistency_prompt_step2 <doc_count> <change_scope> <modified_files> <broken_refs> <doc_files>
# Returns: Complete AI prompt
build_consistency_prompt_step2() {
    local doc_count="$1"
    local change_scope="${2:-unknown}"
    local modified_files="${3:-none}"
    local broken_refs="${4:-No broken references detected}"
    local doc_files="${5:-}"
    
    local prompt=""
    
    # Header
    prompt="## Documentation Consistency Analysis Request\n\n"
    prompt+="I need help analyzing documentation consistency across the project.\n\n"
    
    # Context
    prompt+="### Project Context\n"
    prompt+="- **Documentation Files**: $doc_count\n"
    prompt+="- **Change Scope**: $change_scope\n"
    prompt+="- **Modified Files**: $modified_files\n\n"
    
    # Broken references section
    prompt+="### Automated Checks Results\n\n"
    prompt+="**Broken References:**\n"
    prompt+="$broken_refs\n\n"
    
    # Documentation inventory
    if [[ -n "$doc_files" ]]; then
        prompt+="**Documentation Inventory:**\n"
        prompt+="$doc_files\n\n"
    fi
    
    # Analysis request
    prompt+="### Analysis Required\n\n"
    prompt+="Please analyze the documentation for:\n\n"
    prompt+="1. **Consistency Issues**\n"
    prompt+="   - Cross-references between documents\n"
    prompt+="   - Terminology consistency\n"
    prompt+="   - Format consistency\n\n"
    
    prompt+="2. **Completeness Gaps**\n"
    prompt+="   - Missing documentation for new features\n"
    prompt+="   - Incomplete API documentation\n"
    prompt+="   - Missing examples or tutorials\n\n"
    
    prompt+="3. **Accuracy Verification**\n"
    prompt+="   - Documentation matches actual code behavior\n"
    prompt+="   - Version numbers are consistent\n"
    prompt+="   - Examples are up-to-date\n\n"
    
    prompt+="4. **Quality Recommendations**\n"
    prompt+="   - Structural improvements\n"
    prompt+="   - Clarity enhancements\n"
    prompt+="   - Navigation improvements\n"
    
    echo -e "$prompt"
}

# Enhance prompt with language-specific conventions
# Usage: enhance_consistency_prompt_with_language_step2 <base_prompt> <language>
# Returns: Enhanced prompt
enhance_consistency_prompt_with_language_step2() {
    local base_prompt="$1"
    local language="${2:-bash}"
    local enhanced="$base_prompt"
    
    # Check if language-aware prompts are available
    if command -v should_use_language_aware_prompts &>/dev/null; then
        if should_use_language_aware_prompts; then
            if command -v get_language_documentation_conventions &>/dev/null; then
                local lang_conventions
                lang_conventions=$(get_language_documentation_conventions "$language")
                
                if [[ -n "$lang_conventions" ]] && [[ "$lang_conventions" != "No language specified" ]]; then
                    enhanced+="\n\n**${language^} Documentation Standards:**\n"
                    enhanced+="$lang_conventions\n"
                    print_info "Using language-aware consistency checks for $language"
                fi
            fi
        fi
    fi
    
    echo -e "$enhanced"
}

# ==============================================================================
# AI EXECUTION
# ==============================================================================

# Execute Copilot CLI for consistency analysis
# Usage: execute_consistency_analysis_step2 <prompt> <log_file>
# Returns: 0 on success, 1 on failure
execute_consistency_analysis_step2() {
    local prompt="$1"
    local log_file="$2"
    
    # Display prompt
    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Consistency Analysis Prompt:${NC}"
    echo -e "${YELLOW}${prompt}${NC}\n"
    
    # Check if in dry run mode
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        print_info "[DRY RUN] Would invoke: copilot with consistency analysis prompt"
        return 0
    fi
    
    # Confirm execution
    if ! confirm_action "Run GitHub Copilot CLI to analyze documentation consistency?" "y"; then
        print_warning "Skipped GitHub Copilot CLI - using manual review"
        return 1
    fi
    
    # Save prompt to temporary file
    local temp_prompt_file
    temp_prompt_file=$(mktemp)
    TEMP_FILES+=("$temp_prompt_file")
    echo "$prompt" > "$temp_prompt_file"
    
    # Execute Copilot CLI
    print_info "Starting Copilot CLI session..."
    print_info "Logging output to: $log_file"
    
    # Call execute_copilot_prompt if available, otherwise fallback
    if command -v execute_copilot_prompt &>/dev/null; then
        execute_copilot_prompt "$prompt" "$log_file"
    else
        # Fallback execution with comprehensive flags
        copilot -p "$prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools 2>&1 | tee "$log_file"
    fi
    
    print_success "GitHub Copilot CLI session completed"
    print_info "Full session log saved to: $log_file"
    
    return 0
}

# Extract and save issues from Copilot log
# Usage: process_copilot_results_step2 <log_file>
# Returns: 0 on success
process_copilot_results_step2() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        print_warning "Log file not found: $log_file"
        return 1
    fi
    
    # Use library function if available
    if command -v extract_and_save_issues_from_log &>/dev/null; then
        extract_and_save_issues_from_log "2" "Consistency_Analysis" "$log_file"
    else
        print_info "Issues extraction skipped - library function not available"
    fi
    
    return 0
}

# ==============================================================================
# HIGH-LEVEL WORKFLOW
# ==============================================================================

# Run complete AI consistency analysis workflow
# Usage: run_ai_consistency_workflow_step2 <doc_count> <broken_refs> <doc_files>
# Returns: 0 on success, 1 if skipped
run_ai_consistency_workflow_step2() {
    local doc_count="$1"
    local broken_refs="$2"
    local doc_files="$3"
    
    # Build prompt
    local prompt
    prompt=$(build_consistency_prompt_step2 \
        "$doc_count" \
        "${CHANGE_SCOPE:-unknown}" \
        "${ANALYSIS_MODIFIED:-none}" \
        "$broken_refs" \
        "$doc_files")
    
    # Enhance with language-specific conventions if available
    prompt=$(enhance_consistency_prompt_with_language_step2 "$prompt" "${PRIMARY_LANGUAGE:-bash}")
    
    # Create log file
    local log_timestamp
    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
    local log_file="${LOGS_RUN_DIR:-./logs}/step2_copilot_consistency_analysis_${log_timestamp}.log"
    
    # Execute analysis
    if ! execute_consistency_analysis_step2 "$prompt" "$log_file"; then
        return 1
    fi
    
    # Process results
    process_copilot_results_step2 "$log_file"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f build_consistency_prompt_step2
export -f enhance_consistency_prompt_with_language_step2
export -f execute_consistency_analysis_step2
export -f process_copilot_results_step2
export -f run_ai_consistency_workflow_step2
