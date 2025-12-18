#!/bin/bash
################################################################################
# Step 0: Pre-Analysis - Analyzing Recent Changes
# Purpose: Analyze git state and capture change context before workflow execution
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Main step function - analyzes recent changes and sets workflow context
# Returns: 0 for success
step0_analyze_changes() {
    print_step "0" "Pre-Analysis - Analyzing Recent Changes"
    cd "$PROJECT_ROOT" || return 1
    
    # Use cached git state (performance optimization)
    local commits_ahead
    local modified_files
    commits_ahead=$(get_git_commits_ahead)
    modified_files=$(get_git_total_changes)
    
    print_info "Commits ahead of remote: $commits_ahead"
    print_info "Modified files: $modified_files"
    
    export ANALYSIS_COMMITS=$commits_ahead
    export ANALYSIS_MODIFIED=$modified_files
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        read -r -p "Enter scope of changes (e.g., 'shell_scripts', 'documentation', 'tests'): " CHANGE_SCOPE
    else
        CHANGE_SCOPE="automated-workflow"
    fi
    
    print_success "Pre-analysis complete (Scope: $CHANGE_SCOPE)"
    
    # Save step summary
    save_step_summary "0" "Pre_Analysis" "Analyzed ${modified_files} modified files across ${commits_ahead} commits. Change scope: ${CHANGE_SCOPE}. Repository state captured for workflow context." "✅"
    
    # Save pre-analysis data to backlog
    local step_issues
    step_issues="### Repository Analysis

**Commits Ahead:** ${commits_ahead}
**Modified Files:** ${modified_files}
**Change Scope:** ${CHANGE_SCOPE}

### Modified Files List

\`\`\`
$(get_git_status_output)
\`\`\`
"
    save_step_issues "0" "Pre_Analysis" "$step_issues"
    
    update_workflow_status "step0" "✅"
}

# Export step function
export -f step0_analyze_changes
