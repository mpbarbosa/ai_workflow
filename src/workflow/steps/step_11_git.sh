#!/bin/bash
set -euo pipefail

################################################################################
# Step 11: AI-Powered Git Finalization & Commit Message Generation
# Purpose: Stage changes, generate conventional commit messages, push to remote
# Part of: Tests & Documentation Workflow Automation v2.7.0
# Version: 2.2.0
#
# NEW IN v2.7.0 (2025-12-31):
# - AI Batch Mode: Automatic AI commit message generation in --ai-batch mode
# - Non-interactive AI invocation using Copilot CLI
# - Enhanced fallback messages with full context
# - Maintains backward compatibility with interactive mode
# - Atomic Staging: Ensures consistent git state before Step 11 completion
#   * Resets mixed staged/unstaged state before staging
#   * Uses 'git add -A' for complete atomic staging
#   * Verifies no mixed state remains after staging
#   * Prevents partial commits and state confusion
#
# MODES:
# - Interactive Mode: User pastes AI-generated message (manual)
# - AI Batch Mode (--ai-batch): Automatic AI generation (NEW)
# - Auto Mode (--auto): Default conventional message
################################################################################

# Module version information
readonly STEP11_VERSION="2.2.0"
readonly STEP11_VERSION_MAJOR=2
readonly STEP11_VERSION_MINOR=2
readonly STEP11_VERSION_PATCH=0

# Main step function - finalizes git operations with AI-generated commit messages
# Returns: 0 for success, 1 for failure
step11_git_finalization() {
    print_step "11" "Git Finalization"
    
    cd "$PROJECT_ROOT"
    
    local git_analysis=$(mktemp)
    TEMP_FILES+=("$git_analysis")
    
    # Dry-run preview
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Git operations preview:"
        print_info "  - Would stage all changes"
        print_info "  - Would generate AI commit message"
        print_info "  - Would commit with comprehensive message"
        print_info "  - Would push to origin"
        
        # Save dry-run status to backlog
        local step_issues="### Git Finalization - DRY RUN

**Status:** ✅ DRY RUN MODE

Dry run mode enabled. No actual git operations performed.

### Planned Operations
- Stage all changes
- Generate AI commit message
- Commit with comprehensive message
- Push to origin
"
        save_step_issues "11" "Git_Finalization" "$step_issues"
        save_step_summary "11" "Git_Finalization" "Dry run mode - no git operations performed." "✅"
        
        update_workflow_status "step11" "✅"
        return 0
    fi
    
    # PHASE 1: Automated git analysis (use cached git state)
    print_info "Phase 1: Analyzing git repository state..."
    
    # Check 1: Repository state (from cache)
    print_info "Checking repository state..."
    local current_branch=$(get_git_current_branch)
    local commits_ahead=$(get_git_commits_ahead)
    local commits_behind=$(get_git_commits_behind)
    
    echo "Branch: $current_branch" >> "$git_analysis"
    echo "Commits ahead: $commits_ahead" >> "$git_analysis"
    echo "Commits behind: $commits_behind" >> "$git_analysis"
    
    print_info "Branch: $current_branch (ahead: $commits_ahead, behind: $commits_behind)"
    
    # Check 2: Change enumeration (from cache)
    print_info "Enumerating changes..."
    local modified_count=$(get_git_modified_count)
    local staged_count=$(get_git_staged_count)
    local untracked_count=$(get_git_untracked_count)
    local deleted_count=$(get_git_deleted_count)
    local total_changes=$(get_git_total_changes)
    
    echo "Modified: $modified_count" >> "$git_analysis"
    echo "Staged: $staged_count" >> "$git_analysis"
    echo "Untracked: $untracked_count" >> "$git_analysis"
    echo "Deleted: $deleted_count" >> "$git_analysis"
    
    print_info "Changes: $total_changes files (modified: $modified_count, untracked: $untracked_count)"
    
    # Show current status (from cache)
    print_info "Current git status:"
    get_git_status_short_output
    echo ""
    
    # Check 3: Diff statistics and file categorization (from cache)
    print_info "Analyzing diff statistics..."
    local diff_stats=$(get_git_diff_stat_output)
    local diff_summary=$(get_git_diff_summary_output)
    
    echo "Diff Summary: $diff_summary" >> "$git_analysis"
    
    # Categorize files by type (from cache)
    local docs_modified=$(get_git_docs_modified)
    local tests_modified=$(get_git_tests_modified)
    local scripts_modified=$(get_git_scripts_modified)
    local code_modified=$(get_git_code_modified)
    
    echo "Documentation files: $docs_modified" >> "$git_analysis"
    echo "Test files: $tests_modified" >> "$git_analysis"
    echo "Script files: $scripts_modified" >> "$git_analysis"
    echo "Code files: $code_modified" >> "$git_analysis"
    
    # Check 4: Infer commit type
    print_info "Inferring commit type..."
    local commit_type="chore"
    local commit_scope=""
    
    # Prioritized commit type inference
    if [[ $code_modified -gt 0 ]] && [[ $tests_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation+tests"
    elif [[ $code_modified -gt 0 ]]; then
        commit_type="feat"
        commit_scope="implementation"
    elif [[ $tests_modified -gt 0 ]]; then
        commit_type="test"
        commit_scope="testing"
    elif [[ $docs_modified -gt 0 ]]; then
        commit_type="docs"
        commit_scope="documentation"
    elif [[ $scripts_modified -gt 0 ]]; then
        commit_type="chore"
        commit_scope="automation"
    fi
    
    echo "Inferred Commit Type: $commit_type" >> "$git_analysis"
    echo "Inferred Scope: $commit_scope" >> "$git_analysis"
    
    print_info "Inferred commit type: $commit_type($commit_scope)"
    
    # Pre-commit diff review
    print_info "Reviewing changes to be committed..."
    git diff --stat
    echo ""
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        if confirm_action "Review detailed diff before committing?"; then
            git diff HEAD
            echo ""
        fi
    fi
    
    # PHASE 2: AI-powered commit message generation
    print_info "Phase 2: Preparing AI-powered commit message generation..."
    
    # Build comprehensive git context
    local git_context="Git Repository Context:
- Branch: $current_branch
- Commits ahead: $commits_ahead, behind: $commits_behind
- Total Changes: $total_changes files
- Modified: $modified_count, Untracked: $untracked_count, Deleted: $deleted_count
- Documentation: $docs_modified files
- Tests: $tests_modified files
- Scripts: $scripts_modified files
- Code: $code_modified files
- Inferred Type: $commit_type
- Inferred Scope: $commit_scope"
    
    # Sample changed files
    local changed_files
    changed_files=$(git status --short | head -50)
    
    # Get diff sample for context
    local diff_sample
    diff_sample=$(git diff --unified=3 HEAD | head -200)
    
    local git_analysis_content
    git_analysis_content=$(cat "$git_analysis" 2>/dev/null || echo "   No additional context")
    
    # Build comprehensive commit message generation prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step11_git_commit_prompt \
        "${SCRIPT_VERSION}" \
        "${CHANGE_SCOPE:-General updates}" \
        "$git_context" \
        "$changed_files" \
        "$diff_summary" \
        "$git_analysis_content" \
        "$diff_sample")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Commit Message Generation Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # Stage changes (v2.7.0: Atomic staging strategy)
    echo ""
    print_info "Determining staging strategy..."
    
    # Ensure clean git state before staging
    # Unstage any partially staged files to ensure atomic staging
    local mixed_state_files=$(git status --porcelain | grep -E "^(MM|AM)" | awk '{print $2}')
    if [[ -n "$mixed_state_files" ]]; then
        print_warning "Detected mixed staged/unstaged state - resetting for atomic staging"
        git reset HEAD > /dev/null 2>&1 || true
    fi
    
    # Try conditional staging first (docs only if tests passed)
    local conditional_staging_applied=false
    if type -t conditional_stage_docs > /dev/null 2>&1; then
        if conditional_stage_docs; then
            conditional_staging_applied=true
            print_success "Conditional staging applied: Documentation files staged after test success"
        fi
    fi
    
    # If conditional staging wasn't applied, stage all changes (original behavior)
    if [[ "$conditional_staging_applied" == false ]]; then
        if [[ "$INTERACTIVE_MODE" == true ]]; then
            if ! confirm_action "Stage all changes for commit?"; then
                print_warning "Skipping commit - changes not staged"
                return 0
            fi
        fi
        
        print_info "Staging all changes atomically..."
        # Use 'git add -A' for full atomic staging (stages, modifies, and removes)
        git add -A
        print_success "All changes staged atomically"
    fi
    
    # Verify atomic staging completed successfully
    local verify_mixed_state=$(git status --porcelain | grep -E "^(MM|AM)" | wc -l)
    if [[ $verify_mixed_state -gt 0 ]]; then
        print_error "CRITICAL: Atomic staging verification failed - mixed state detected"
        print_error "Run 'git add -u' to complete staging or 'git reset HEAD' to restart"
        return 1
    fi
    
    # Generate commit message
    local ai_commit_msg=""
    local use_ai_message=false
    local commit_msg_file=$(mktemp)
    TEMP_FILES+=("$commit_msg_file")
    
    # Check if Copilot CLI is available
    if is_copilot_available; then
        print_info "GitHub Copilot CLI detected - ready for commit message generation..."
        
        # Check if AI batch mode (with Copilot available) - NEW v2.7.0
        if [[ "${AI_BATCH_MODE:-false}" == "true" ]]; then
            # AI BATCH MODE: Generate AI commit message non-interactively
            print_info "AI Batch Mode: Generating commit message automatically..."
            print_info "This will use AI to create a professional conventional commit message"
            echo ""
            
            # Generate AI commit message using batch mode
            if ai_commit_msg=$(generate_batch_ai_commit_message); then
                use_ai_message=true
                echo "$ai_commit_msg" > "$commit_msg_file"
                print_success "Using AI-generated commit message (batch mode) ✅"
            else
                print_warning "Batch AI generation failed - using enhanced fallback"
                # Message already set by fallback in generate_batch_ai_commit_message
                use_ai_message=true
                echo "$ai_commit_msg" > "$commit_msg_file"
            fi
        elif [[ "$INTERACTIVE_MODE" == false ]]; then
            # AUTO MODE (not batch): Skip AI generation, use default
            print_info "Auto mode - using default conventional commit message"
            print_info "Tip: Use --ai-batch for AI-generated commit messages in non-interactive mode"
        elif [[ "$INTERACTIVE_MODE" == true ]]; then
            if confirm_action "Generate AI-powered commit message with Copilot CLI?"; then
                print_info "Starting Copilot CLI commit message generation..."
                print_info "This will create a professional conventional commit message"
                print_info "BEST PRACTICE: Using 'copilot -p' for specialized git commit expertise"
                echo ""
                
                print_warning "Copilot CLI will open interactive session for message generation"
                print_info "After AI generates message, copy it and paste when prompted"
                echo ""
                
                # Create log file with unique timestamp
                local log_timestamp
                log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
                local log_file="${LOGS_RUN_DIR}/step11_copilot_commit_message_${log_timestamp}.log"
                print_info "Logging output to: $log_file"
                
                # Execute Copilot prompt
                execute_copilot_prompt "$copilot_prompt" "$log_file" "step11" "git_workflow_specialist"
                
                echo ""
                print_success "Copilot CLI commit message generation session completed"
                print_info "Full session log saved to: $log_file"
                echo ""
                
                # Extract and save issues using library function
                extract_and_save_issues_from_log "11" "Git_Finalization" "$log_file"
                echo ""
                
                # Collect AI-generated commit message using reusable function (multi-line)
                ai_commit_msg=$(collect_ai_output "Please copy the AI-generated commit message from Copilot session above" "multi")
                
                if [[ -n "$ai_commit_msg" ]]; then
                    use_ai_message=true
                    echo "$ai_commit_msg" > "$commit_msg_file"
                    print_success "Using AI-generated commit message ✅"
                else
                    print_info "No AI message provided - using default commit message"
                fi
            else
                print_warning "Skipped AI commit message generation"
            fi
        fi  # End of interactive mode check
    else
        print_warning "GitHub Copilot CLI not found - using default message"
        print_info "Install from: https://github.com/github/gh-copilot"
    fi
    
    # Commit with chosen message
    local commit_message=""
    
    if [[ "$use_ai_message" == true ]] && [[ -n "$ai_commit_msg" ]]; then
        commit_message="$ai_commit_msg"
    else
        # Build default comprehensive commit message
        commit_message="${commit_type}(${commit_scope}): update tests and documentation

Workflow automation completed comprehensive validation and updates.

Changes:
- Modified files: $modified_count
- Documentation: $docs_modified files
- Tests: $tests_modified files  
- Scripts: $scripts_modified files
- Code: $code_modified files

Scope: ${CHANGE_SCOPE:-General updates}
Total changes: $total_changes files

[workflow-automation v${SCRIPT_VERSION}]"
    fi
    
    print_info "Commit message:"
    echo -e "${CYAN}${commit_message}${NC}"
    echo ""
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        if ! confirm_action "Commit with this message?"; then
            print_warning "Commit cancelled - entering manual mode"
            read -r -p "Enter custom commit message: " custom_msg
            if [[ -n "$custom_msg" ]]; then
                commit_message="$custom_msg"
            else
                print_error "Empty commit message - aborting commit"
                return 1
            fi
        fi
    fi
    
    # Execute commit
    if git commit -m "$commit_message"; then
        print_success "Changes committed successfully ✅"
    else
        print_error "Commit failed"
        return 1
    fi
    
    # Push to remote with confirmation
    echo ""
    print_warning "🔴 CRITICAL: Ready to push to origin"
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        if ! confirm_action "Push to remote repository?"; then
            print_warning "Push skipped - workflow incomplete"
            return 0
        fi
    fi
    
    local current_branch=$(git branch --show-current)
    
    # Save to backlog BEFORE push (in case push fails)
    local step_issues="### Git Finalization Summary

**Commit Type:** ${commit_type}
**Commit Scope:** ${commit_scope}
**Branch:** ${current_branch}
**Modified Files:** ${modified_count}
**Total Changes:** ${total_changes}

### Commit Message

\`\`\`
${commit_message}
\`\`\`

### Git Changes

\`\`\`
$(git show --stat HEAD 2>/dev/null || echo "Latest commit details unavailable")
\`\`\`
"
    save_step_issues "11" "Git_Finalization" "$step_issues"
    
    if git push origin "$current_branch"; then
        print_success "Successfully pushed to origin/$current_branch ✅"
        save_step_summary "11" "Git_Finalization" "Changes committed and pushed successfully to ${current_branch}. ${modified_count} files modified. Commit: ${commit_type}(${commit_scope})." "✅"
        update_workflow_status "step11" "✅"
    else
        print_error "PUSH FAILED - workflow incomplete ❌"
        save_step_summary "11" "Git_Finalization" "FAILED: Push to ${current_branch} failed. Changes committed locally but not pushed to remote." "❌"
        update_workflow_status "step11" "❌"
        return 1
    fi
    
    # Set executable permissions on shell scripts (only if workflow directory exists)
    if [[ -d "${WORKFLOW_ROOT:-}/src/workflow" ]]; then
        print_info "Setting executable permissions on shell scripts..."
        find "${WORKFLOW_ROOT}/src/workflow" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        print_success "Permissions updated"
    fi
}

# Export step function
export -f step11_git_finalization
