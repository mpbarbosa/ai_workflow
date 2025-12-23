#!/bin/bash
set -euo pipefail

################################################################################
# Step Execution Library
# Purpose: Shared execution patterns for workflow steps (DRY principle)
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Handles Phase 2 AI analysis with issue extraction
# Arguments:
#   $1 - copilot_prompt: The prompt to execute
#   $2 - step_number: Step number (e.g., "2", "3")
#   $3 - step_name: Step name for logging (e.g., "consistency_analysis")
#   $4 - step_name_display: Display name (e.g., "Consistency_Analysis")
#   $5 - has_issues: Number of issues found (>0 triggers auto execution)
#   $6 - analysis_type: Description of analysis type
#   $7 - optional_prompt_msg: Message for optional run (when has_issues=0)
#   $8 - success_question: Question to ask after copilot runs
# Returns: 0 for success, 1 for failure
execute_phase2_ai_analysis() {
    local copilot_prompt="$1"
    local step_number="$2"
    local step_name="$3"
    local step_name_display="$4"
    local has_issues="$5"
    local analysis_type="$6"
    local optional_prompt_msg="${7:-No automated issues found}"
    local success_question="${8:-Did Copilot identify issues that need fixing?}"
    
    # Check if Copilot CLI is available and authenticated
    if ! is_copilot_available; then
        print_warning "GitHub Copilot CLI not found - using basic checks only"
        print_info "Install from: https://github.com/github/gh-copilot"
        print_info "For deep analysis, use the prompt above manually with Copilot"
        return 0
    fi
    
    if ! is_copilot_authenticated; then
        print_warning "GitHub Copilot CLI is not authenticated - using basic checks only"
        print_info "Authentication options:"
        print_info "  • Run 'copilot' and use the '/login' command"
        print_info "  • Set COPILOT_GITHUB_TOKEN, GH_TOKEN, or GITHUB_TOKEN environment variable"
        print_info "  • Run 'gh auth login' to authenticate with GitHub CLI"
        print_info "For deep analysis, authenticate and run the workflow again"
        return 0
    fi
    
    print_info "GitHub Copilot CLI detected - ready for ${analysis_type}..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with ${analysis_type} prompt"
        return 0
    fi
    
    # Smart triggering: Auto-trigger if issues found, user choice if interactive
    if [[ "$has_issues" -gt 0 ]] || [[ "$INTERACTIVE_MODE" == true ]]; then
        local confirmation_msg="Run Copilot CLI for deep ${analysis_type}?"
        local default_answer="y"
        
        # For optional runs (no issues), adjust message and default
        if [[ "$has_issues" -eq 0 ]]; then
            confirmation_msg="$optional_prompt_msg"
            default_answer="n"
        fi
        
        if confirm_action "$confirmation_msg" "$default_answer"; then
            print_info "Starting Copilot CLI ${analysis_type} session..."
            echo ""
            
            # Create log file with unique timestamp
            local log_timestamp
            log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
            local log_file="${LOGS_RUN_DIR}/step${step_number}_copilot_${step_name}_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            print_info "Log file: $log_file"
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            # Check if execution was successful
            if [[ $? -ne 0 ]]; then
                print_error "Copilot CLI execution failed - please check installation and try again"
                return 1
            fi
            
            # Check log file created
            if [[ ! -f "$log_file" ]]; then
                print_error "Expected log file not found: $log_file"
                return 1
            fi
            
            print_success "Copilot CLI ${analysis_type} completed"
            print_info "Full session log saved to: $log_file"
            echo ""
            
            # Ask user if they want to save issues from the Copilot session
            if confirm_action "Do you want to save issues from the Copilot session to the backlog?" "n"; then
                extract_and_save_issues "$log_file" "$step_number" "$step_name_display"
            fi
            
            echo ""
            
            # User feedback loop for issue resolution
            if confirm_action "$success_question" "n"; then
                print_warning "Please review and fix identified issues before continuing"
                if [[ "$INTERACTIVE_MODE" == true ]]; then
                    if ! confirm_action "Continue workflow with identified issues?"; then
                        print_error "Workflow paused - please fix issues"
                        return 1
                    fi
                fi
            fi
        else
            print_warning "Skipped Copilot CLI deep ${analysis_type}"
        fi
    else
        print_info "$optional_prompt_msg - skipping optional deep analysis"
        if confirm_action "Run optional Copilot ${analysis_type} anyway?" "n"; then
            # Recursive call with INTERACTIVE_MODE set
            local old_interactive="$INTERACTIVE_MODE"
            INTERACTIVE_MODE=true
            execute_phase2_ai_analysis "$copilot_prompt" "$step_number" "$step_name" "$step_name_display" "1" "$analysis_type" "$optional_prompt_msg" "$success_question"
            local result=$?
            INTERACTIVE_MODE="$old_interactive"
            return $result
        fi
    fi
    
    return 0
}

# Extracts issues from Copilot log and saves to backlog
# Arguments:
#   $1 - log_file: Path to Copilot session log
#   $2 - step_number: Step number
#   $3 - step_name: Step name for backlog
# Returns: 0 for success
extract_and_save_issues() {
    local log_file="$1"
    local step_number="$2"
    local step_name="$3"
    
    if [[ ! -f "$log_file" ]]; then
        print_warning "Log file not found - skipping issue extraction"
        return 0
    fi
    
    local log_content
    log_content=$(cat "$log_file")
    
    # Build issue extraction prompt using helper function
    local extract_prompt
    extract_prompt=$(build_issue_extraction_prompt "$log_file" "$log_content")

    echo -e "\n${CYAN}Issue Extraction Prompt:${NC}"
    echo -e "${YELLOW}${extract_prompt}${NC}\n"
    
    if confirm_action "Run GitHub Copilot CLI to extract and organize issues from the log?" "y"; then
        sleep 1
        print_info "Starting Copilot CLI session for issue extraction..."
        copilot -p "$extract_prompt" --allow-all-tools --allow-all-paths --enable-all-github-mcp-tools
        
        # Collect organized issues using reusable function
        local organized_issues
        organized_issues=$(collect_ai_output "Please copy the organized issues from Copilot output." "multi")
        
        if [[ -n "$organized_issues" ]]; then
            save_step_issues "$step_number" "$step_name" "$organized_issues"
            print_success "Issues extracted from log and saved to backlog"
        else
            print_warning "No organized issues provided - skipping backlog save"
        fi
    else
        print_warning "Skipped issue extraction - no backlog file created"
    fi
    
    return 0
}

# Generates and saves step summary and backlog
# Arguments:
#   $1 - step_number: Step number
#   $2 - step_name: Step name for backlog
#   $3 - issues_found: Number of issues found
#   $4 - success_message: Message when no issues found
#   $5 - failure_message: Message when issues found
#   $6 - issues_file: Path to file containing issue details (optional)
#   $7 - doc_count: Count of documents/items checked (optional)
# Returns: 0 for success
save_step_results() {
    local step_number="$1"
    local step_name="$2"
    local issues_found="$3"
    local success_message="$4"
    local failure_message="$5"
    local issues_file="${6:-}"
    local doc_count="${7:-}"
    
    echo ""
    
    local step_issues=""
    if [[ $issues_found -eq 0 ]]; then
        print_success "$success_message ✅"
        
        local summary_msg="$success_message"
        [[ -n "$doc_count" ]] && summary_msg="${summary_msg} (${doc_count} items checked)"
        save_step_summary "$step_number" "$step_name" "$summary_msg" "✅"
        
        # Save success status to backlog
        step_issues="### ${step_name//_/ }

**Total Issues:** 0
**Status:** ✅ All Checks Passed

${summary_msg}
"
    else
        print_warning "Found $issues_found issue(s) - review required"
        save_step_summary "$step_number" "$step_name" "$failure_message" "⚠️"
        
        # Save to backlog
        step_issues="### ${step_name//_/ } Issues Found

**Total Issues:** ${issues_found}

"
        if [[ -n "$issues_file" ]] && [[ -f "$issues_file" ]] && [[ -s "$issues_file" ]]; then
            step_issues+="### Details

\`\`\`
$(cat "$issues_file")
\`\`\`
"
        fi
    fi
    
    # Always save backlog file
    save_step_issues "$step_number" "$step_name" "$step_issues"
    
    return 0
}

# Export functions
export -f execute_phase2_ai_analysis
export -f extract_and_save_issues
export -f save_step_results
