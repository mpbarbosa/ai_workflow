#!/bin/bash
set -euo pipefail

################################################################################
# Step 0: Pre-Analysis - Analyzing Recent Changes
# Purpose: Analyze git state and capture change context before workflow execution (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.6.1
# Version: 2.3.0 (Added test infrastructure smoke test)
################################################################################

# Source test smoke test module
STEP0_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${STEP0_DIR}/../lib/test_smoke.sh" ]]; then
    source "${STEP0_DIR}/../lib/test_smoke.sh"
fi

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
    
    # Tech Stack Detection Report (Phase 3)
    if [[ -n "${PRIMARY_LANGUAGE:-}" ]]; then
        print_info "Detected language: $PRIMARY_LANGUAGE"
        print_info "Build system: ${BUILD_SYSTEM:-none}"
        print_info "Test framework: ${TEST_FRAMEWORK:-none}"
    else
        print_info "Tech stack: Not yet initialized"
    fi
    
    # Project Kind Detection (Phase 1 - Project Kind Awareness)
    if declare -f detect_project_kind >/dev/null 2>&1; then
        print_info "Detecting project kind..."
        local project_kind_result
        project_kind_result=$(detect_project_kind "$PROJECT_ROOT" 2>/dev/null || echo '{"kind":"unknown","confidence":0}')
        
        export PROJECT_KIND=$(echo "$project_kind_result" | grep -oP '"kind":\s*"\K[^"]+' || echo "unknown")
        export PROJECT_KIND_CONFIDENCE=$(echo "$project_kind_result" | grep -oP '"confidence":\s*\K[0-9]+' || echo "0")
        
        if [[ "$PROJECT_KIND" != "unknown" ]] && [[ $PROJECT_KIND_CONFIDENCE -gt 50 ]]; then
            local kind_desc
            kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
            print_info "Project kind: $kind_desc (${PROJECT_KIND_CONFIDENCE}% confidence)"
        else
            print_info "Project kind: Could not determine with confidence"
        fi
    fi
    
    # TEST INFRASTRUCTURE SMOKE TEST (NEW in v2.6.1)
    # Quick validation to catch test issues early (saves 30+ minutes on failures)
    local smoke_test_status="⚠️ Skipped"
    local smoke_test_details="Test smoke test not run"
    
    if declare -f smoke_test_infrastructure >/dev/null 2>&1; then
        print_info ""
        print_info "=== Test Infrastructure Pre-Validation ==="
        
        if smoke_test_infrastructure; then
            smoke_test_status="✅ Passed"
            smoke_test_details="Test infrastructure validated successfully"
            print_success "Test infrastructure validation passed"
        else
            smoke_test_status="❌ Failed"
            smoke_test_details="Test infrastructure validation failed - check logs"
            print_warning "Test infrastructure validation failed"
            print_warning "This may cause failures in Step 7 (Test Execution)"
            print_warning "Consider fixing test setup before continuing workflow"
            
            if [[ "${AUTO_MODE:-false}" != "true" ]]; then
                read -r -p "Continue anyway? (y/N): " continue_choice
                if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
                    print_error "Workflow aborted by user"
                    return 1
                fi
            fi
        fi
        print_info "=========================================="
        print_info ""
    fi
    
    export ANALYSIS_COMMITS=$commits_ahead
    export ANALYSIS_MODIFIED=$modified_files
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        read -r -p "Enter scope of changes (e.g., 'src/workflow', 'documentation', 'tests'): " CHANGE_SCOPE
    else
        CHANGE_SCOPE="automated-workflow"
    fi
    
    print_success "Pre-analysis complete (Scope: $CHANGE_SCOPE)"
    
    # Save step summary
    save_step_summary "0" "Pre_Analysis" "Analyzed ${modified_files} modified files across ${commits_ahead} commits. Change scope: ${CHANGE_SCOPE}. Test smoke test: ${smoke_test_status}. Repository state captured for workflow context." "✅"
    
    # Save pre-analysis data to backlog
    local step_issues
    local tech_stack_info=""
    if [[ -n "${PRIMARY_LANGUAGE:-}" ]]; then
        tech_stack_info="
### Tech Stack

**Language:** ${PRIMARY_LANGUAGE}
**Build System:** ${BUILD_SYSTEM:-none}
**Test Framework:** ${TEST_FRAMEWORK:-none}
**Package File:** ${TECH_STACK_CONFIG[package_file]:-none}
"
    fi
    
    local project_kind_info=""
    if [[ -n "${PROJECT_KIND:-}" ]] && [[ "${PROJECT_KIND}" != "unknown" ]]; then
        local kind_desc
        kind_desc=$(get_project_kind_description "$PROJECT_KIND" 2>/dev/null || echo "$PROJECT_KIND")
        project_kind_info="
### Project Kind

**Type:** ${kind_desc}
**Confidence:** ${PROJECT_KIND_CONFIDENCE}%
**Identifier:** ${PROJECT_KIND}
"
    fi
    
    local smoke_test_info="
### Test Infrastructure Pre-Validation

**Status:** ${smoke_test_status}
**Details:** ${smoke_test_details}

This early validation helps catch test infrastructure issues before Step 7, potentially saving 30+ minutes of workflow execution time.
"
    
    step_issues="### Repository Analysis

**Commits Ahead:** ${commits_ahead}
**Modified Files:** ${modified_files}
**Change Scope:** ${CHANGE_SCOPE}
${tech_stack_info}${project_kind_info}${smoke_test_info}

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
