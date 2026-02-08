#!/bin/bash
set -euo pipefail

################################################################################
# Step 11.5: AI-Powered Context Analysis & Workflow Adaptation (Language-Aware)
# Purpose: Analyze workflow context and provide strategic recommendations (adaptive)
# Part of: Tests & Documentation Workflow Automation v3.3.0
# Version: 2.2.0 (Renamed from Step 11 to accommodate Deployment Readiness Gate)
################################################################################

# Module version information
readonly STEP11_5_VERSION="2.2.0"
readonly STEP11_5_VERSION_MAJOR=2
readonly STEP11_5_VERSION_MINOR=2
readonly STEP11_5_VERSION_PATCH=0

# Main step function - analyzes workflow context with AI strategic planning
# Returns: 0 for success, 1 for failure
step11_5_context_analysis() {
    print_step "10.5" "Context Analysis & Summary"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Refresh git cache to get current state before analysis
    if command -v refresh_git_cache &>/dev/null; then
        refresh_git_cache
    fi
    
    local context_report
    context_report=$(mktemp)
    TEMP_FILES+=("$context_report")
    
    # PHASE 1: Automated context collection
    print_info "Phase 1: Collecting workflow context..."
    
    # Check 1: Workflow execution summary
    print_info "Analyzing workflow execution status..."
    local steps_completed=0
    local steps_failed=0
    local workflow_summary=""
    
    for step in "${!WORKFLOW_STATUS[@]}"; do
        local status="${WORKFLOW_STATUS[$step]}"
        workflow_summary+="$step: $status\n"
        if [[ "$status" == "✅" ]]; then
            ((steps_completed++))
        else
            ((steps_failed++))
        fi
    done
    
    local total_steps=${#WORKFLOW_STATUS[@]}
    local completion_rate=0
    if [[ $total_steps -gt 0 ]]; then
        completion_rate=$((steps_completed * 100 / total_steps))
    fi
    
    print_info "Workflow completion: $steps_completed/$total_steps steps ($completion_rate%)"
    echo "Workflow Status: $steps_completed/$total_steps completed ($completion_rate%)" >> "$context_report"
    echo -e "Step Details:\n$workflow_summary" >> "$context_report"
    
    # Check 2: Git repository state analysis
    print_info "Analyzing git repository state..."
    local git_status=""
    local modified_files=0
    local untracked_files=0
    local staged_files=0
    
    if is_git_repo; then
        # Get from cache
        modified_files=$(get_git_modified_count)
        untracked_files=$(get_git_untracked_count)
        staged_files=$(get_git_staged_count)
        
        git_status="Modified: $modified_files, Untracked: $untracked_files, Staged: $staged_files"
        
        # Get branch info
        local current_branch
        current_branch=$(get_git_current_branch)
        local commits_ahead
        commits_ahead=$(get_git_commits_ahead)
        
        echo "Git Status: $git_status" >> "$context_report"
        echo "Branch: $current_branch (commits ahead: $commits_ahead)" >> "$context_report"
    else
        git_status="Not in a git repository"
        echo "Git: Not a git repository" >> "$context_report"
    fi
    
    print_info "Git state: $git_status"
    
    # Check 3: Change impact assessment
    print_info "Assessing change impact..."
    local change_impact="Low"
    local impact_score=0
    
    # Calculate impact based on files changed
    if [[ $modified_files -gt 10 ]]; then
        ((impact_score += 3))
    elif [[ $modified_files -gt 5 ]]; then
        ((impact_score += 2))
    elif [[ $modified_files -gt 0 ]]; then
        ((impact_score += 1))
    fi
    
    # Check for critical file modifications
    if is_deps_modified; then
        ((impact_score += 2))
        echo "Impact: Dependencies modified (package.json)" >> "$context_report"
    fi
    
    if [[ $(get_git_scripts_modified) -gt 0 ]]; then
        ((impact_score += 1))
        echo "Impact: Shell scripts modified" >> "$context_report"
    fi
    
    # Determine impact level
    if [[ $impact_score -ge 5 ]]; then
        change_impact="High"
    elif [[ $impact_score -ge 3 ]]; then
        change_impact="Medium"
    fi
    
    echo "Change Impact Level: $change_impact (score: $impact_score)" >> "$context_report"
    print_info "Change impact: $change_impact"
    
    # Check 4: Aggregate issues and warnings
    print_info "Aggregating workflow issues and warnings..."
    local total_issues=0
    local critical_issues=0
    
    # Scan all workflow status
    for step in "${!WORKFLOW_STATUS[@]}"; do
        local status="${WORKFLOW_STATUS[$step]}"
        if [[ "$status" == "❌" ]]; then
            ((critical_issues++))
            ((total_issues++))
        elif [[ "$status" == "⚠️" ]]; then
            ((total_issues++))
        fi
    done
    
    echo "Issues Found: $total_issues total, $critical_issues critical" >> "$context_report"
    print_info "Issues: $total_issues total, $critical_issues critical"
    
    # Check 5: Workflow metrics
    print_info "Calculating workflow metrics..."
    local workflow_start_time=${WORKFLOW_START_TIME:-$(date +%s)}
    local workflow_end_time
    workflow_end_time=$(date +%s)
    local workflow_duration=$((workflow_end_time - workflow_start_time))
    
    echo "Workflow Duration: ${workflow_duration}s" >> "$context_report"
    
    # PHASE 2: AI-powered strategic analysis
    print_info "Phase 2: Preparing AI-powered strategic analysis..."
    
    # Build comprehensive context summary
    local context_summary="Comprehensive Workflow Context:
- Workflow Completion: $steps_completed/$total_steps steps ($completion_rate%)
- Git State: $git_status
- Change Impact: $change_impact (score: $impact_score)
- Issues: $total_issues total, $critical_issues critical
- Modified Files: $modified_files
- Untracked Files: $untracked_files
- Workflow Duration: ${workflow_duration}s"
    
    # Collect change scope
    local change_scope_detail="${CHANGE_SCOPE:-No specific scope detected}"
    local recent_commits
    recent_commits=$(git log --oneline -5 2>/dev/null || echo "No recent commits")
    local git_status_sample
    git_status_sample=$(get_git_status_short_output | head -20 || echo "None")
    local context_report_content
    context_report_content=$(cat "$context_report" 2>/dev/null || echo "   No additional context")
    
    # Get project metadata for dynamic context
    local metadata
    metadata=$(get_project_metadata)
    local project_name="${metadata%%|*}"
    local temp="${metadata#*|}"
    local project_description="${temp%%|*}"
    local primary_language="${temp#*|}"
    
    # Build comprehensive strategic analysis prompt
    local copilot_prompt
    copilot_prompt="**Role**: You are a senior technical project manager and workflow orchestration specialist with expertise in software development workflows, continuous integration strategies, change impact assessment, risk management, and adaptive process optimization.

**Task**: Analyze the complete workflow execution context, assess effectiveness, identify risks and opportunities, and provide strategic recommendations for workflow optimization and next steps.

**Context:**
- Project: ${project_name} (${project_description})
- Primary Language: ${primary_language}
- Workflow: Tests & Documentation Automation v${SCRIPT_VERSION}
- Execution Mode: ${INTERACTIVE_MODE:+Interactive}${AUTO_MODE:+Automatic}${DRY_RUN:+Dry-Run}
- Total Steps: $total_steps
- Completed Steps: $steps_completed ($completion_rate%)
- Failed Steps: $steps_failed

**Workflow Context Summary:**
$context_summary

**Detailed Workflow Status:**
$(echo -e "$workflow_summary")

**Context Report:**
$context_report_content

**Change Scope:**
$change_scope_detail

**Recent Commits:**
$recent_commits

**Modified Files (sample):**
$git_status_sample

**Analysis Tasks:**

1. **Workflow Effectiveness Assessment:**
   - Evaluate overall workflow success ($completion_rate% completion)
   - Identify bottlenecks or inefficiencies in execution
   - Assess whether all steps added value
   - Determine if workflow steps are in optimal order
   - Evaluate automation vs manual intervention balance
   - Measure workflow efficiency (time, resources)

2. **Context-Aware Recommendations:**
   - Based on change impact ($change_impact), recommend next actions
   - Suggest additional validation if high-impact changes detected
   - Recommend rollback strategies if critical issues found
   - Propose testing priorities based on modified files
   - Identify missing validation steps
   - Suggest documentation updates based on changes

3. **Adaptive Workflow Optimization:**
   - Recommend workflow modifications for future runs
   - Suggest additional automation opportunities
   - Identify steps that could be parallelized
   - Propose new validation steps based on this execution
   - Recommend conditional step execution strategies
   - Suggest workflow customization based on change type

4. **Next Steps Strategic Planning:**
   - Prioritize immediate actions (pre-commit, pre-push)
   - Recommend git operations (commit, push, branch)
   - Suggest deployment readiness assessment
   - Identify follow-up tasks or technical debt
   - Propose code review focus areas
   - Recommend stakeholder communications

5. **Risk & Opportunity Identification:**
   - Identify potential risks from detected issues
   - Assess deployment risk based on change impact
   - Highlight opportunities for improvement
   - Flag breaking changes or backward compatibility issues
   - Identify testing gaps or coverage concerns
   - Recommend mitigation strategies for risks

**Expected Output:**
- Workflow effectiveness score (1-10) with justification
- Top 3 workflow strengths and top 3 improvement areas
- Context-specific next actions (prioritized, actionable)
- Adaptive workflow recommendations for future runs
- Risk assessment with mitigation strategies
- Opportunity identification with effort estimates
- Strategic roadmap for continuous improvement
- Immediate action checklist
- Long-term optimization recommendations

Please provide a comprehensive strategic analysis with specific, prioritized recommendations for immediate actions and long-term workflow optimization."

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Strategic Context Analysis Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with strategic context analysis prompt"
    else
        if confirm_action "Run GitHub Copilot CLI for strategic context analysis?" "y"; then
            # Save prompt to temporary file for tracking
            local temp_prompt_file
            temp_prompt_file=$(mktemp)
            TEMP_FILES+=("$temp_prompt_file")
            echo "$copilot_prompt" > "$temp_prompt_file"
            
            # Invoke Copilot CLI
            print_info "Starting Copilot CLI session..."
            
            # Create log file with unique timestamp
            local log_timestamp
            log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
            local log_file="${LOGS_RUN_DIR}/step11_copilot_context_analysis_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file" "step11" "context_analyst"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "10" "Context_Analysis" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Summary
    echo ""
    print_header "Workflow Context Summary"
    echo -e "${CYAN}Completion:${NC} $steps_completed/$total_steps steps ($completion_rate%)"
    echo -e "${CYAN}Git State:${NC} $git_status"
    echo -e "${CYAN}Change Impact:${NC} $change_impact"
    echo -e "${CYAN}Issues:${NC} $total_issues total, $critical_issues critical"
    
    if [[ $completion_rate -eq 100 ]] && [[ $critical_issues -eq 0 ]]; then
        print_success "Workflow executed successfully - ready for finalization ✅"
        save_step_summary "10" "Context_Analysis" "Workflow ${completion_rate}% complete. ${git_status}. Impact: ${change_impact}. ${total_issues} issues (${critical_issues} critical). Ready for finalization." "✅"
    elif [[ $critical_issues -gt 0 ]]; then
        print_warning "Critical issues detected - review before proceeding ⚠️"
        save_step_summary "10" "Context_Analysis" "CRITICAL: ${critical_issues} critical issues detected. ${steps_completed}/${total_steps} steps complete. Review and address critical issues before proceeding." "⚠️"
    else
        print_info "Workflow completed with warnings - review recommended"
        save_step_summary "10" "Context_Analysis" "Workflow ${completion_rate}% complete with ${total_issues} non-critical issues. Review recommended before finalization." "⚠️"
    fi
    
    # Save to backlog
    local step_issues="### Workflow Context Summary

**Completion:** ${steps_completed}/${total_steps} steps (${completion_rate}%)
**Git State:** ${git_status}
**Change Impact:** ${change_impact}
**Total Issues:** ${total_issues}
**Critical Issues:** ${critical_issues}

### Workflow Steps Completion

"
    for key in "${!WORKFLOW_STATUS[@]}"; do
        step_issues+="- ${key}: ${WORKFLOW_STATUS[$key]}
"
    done
    save_step_issues "10" "Context_Analysis" "$step_issues"
    
    update_workflow_status "step11" "✅"
}

# Alias for backward compatibility (main script calls step10_context_analysis)
step10_context_analysis() {
    step11_5_context_analysis "$@"
}

# Export step function
export -f step11_5_context_analysis step10_context_analysis
