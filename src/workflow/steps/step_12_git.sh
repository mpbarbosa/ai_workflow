#!/bin/bash
set -euo pipefail

################################################################################
# Step 12: AI-Powered Git Finalization & Commit Message Generation
# Purpose: Stage changes, generate conventional commit messages, push to remote
# Part of: Tests & Documentation Workflow Automation v3.1.7
# Version: 2.3.3
#
# NEW IN v2.3.0 (2026-02-06):
# - Git Submodule Support: Full lifecycle management for submodules
#   * Automatic detection and initialization
#   * Update to latest remote commits
#   * AI-powered commit messages for submodule changes
#   * Push submodule changes and update pointers in parent
#   * Error handling with rollback support
# - --skip-submodules flag to opt-out of submodule operations
# - Comprehensive submodule status logging
#
# NEW IN v2.7.1 (2025-12-31):
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
#
# SUBMODULE WORKFLOW:
# 1. Detect and validate all submodules
# 2. Initialize submodules if needed
# 3. Update each submodule to latest remote
# 4. Detect and stage changes within submodules
# 5. Generate AI commit messages for submodule changes
# 6. Commit and push submodule changes
# 7. Stage submodule pointer updates in parent
# 8. Commit and push parent repository
################################################################################

# Module version information
readonly STEP12_VERSION="2.3.0"
readonly STEP12_VERSION_MAJOR=2
readonly STEP12_VERSION_MINOR=3
readonly STEP12_VERSION_PATCH=0

# Build AI prompt for git commit message generation
# Args: $1=script_version $2=change_scope $3=git_context $4=changed_files
#       $5=diff_summary $6=git_analysis_content $7=diff_sample
build_step12_git_commit_prompt() {
    local script_version="$1"
    local change_scope="$2"
    local git_context="$3"
    local changed_files="$4"
    local diff_summary="$5"
    local git_analysis_content="$6"
    local diff_sample="$7"
    
    cat << EOF
You are a Git commit message specialist following Conventional Commits specification.

## Project Information
- Workflow Version: ${script_version}
- Change Scope: ${change_scope}

## Git Context
${git_context}

## Changed Files (${changed_files} total)
Use this to determine the commit scope.

## Diff Summary
${diff_summary}

## Additional Analysis
${git_analysis_content}

## Sample Changes
\`\`\`diff
${diff_sample}
\`\`\`

## Your Task
Generate a conventional commit message following this format:

\`\`\`
<type>(<scope>): <description>

<body>

<footer>
\`\`\`

**Requirements**:
1. Type must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore
2. Scope should be concise (e.g., "workflow", "docs", "tests", "config")
3. Description must be lowercase, imperative mood, no period at end
4. Body should explain WHAT and WHY (not HOW)
5. Include breaking changes in footer if applicable: "BREAKING CHANGE: description"
6. Keep total message under 200 characters for first line

**Examples**:
- \`feat(workflow): add parallel execution support\`
- \`fix(tests): resolve flaky test in auth module\`
- \`docs(readme): update installation instructions\`
- \`refactor(core): simplify error handling logic\`

Generate ONLY the commit message, no additional commentary.
EOF
}

export -f build_step12_git_commit_prompt

# Push to remote if local is ahead
# Args:
#   $1 - commit_was_made (true/false) - whether a commit was just created
#   $2 - commit_type - type of commit (for backlog)
#   $3 - commit_scope - scope of commit (for backlog)
#   $4 - commit_message - commit message (for backlog)
#   $5 - modified_count - number of modified files (for backlog)
#   $6 - total_changes - total number of changes (for backlog)
# Returns: 0 for success, 1 for failure
push_if_ahead() {
    local commit_was_made="${1:-false}"
    local commit_type="${2:-}"
    local commit_scope="${3:-}"
    local commit_message="${4:-}"
    local modified_count="${5:-0}"
    local total_changes="${6:-0}"
    
    local commits_ahead=$(get_git_commits_ahead)
    local current_branch=$(git branch --show-current)
    
    # Check if local is ahead of remote
    if [[ "$commits_ahead" -eq 0 ]]; then
        print_info "Local branch is up to date with origin/$current_branch"
        
        if [[ "$commit_was_made" == "false" ]]; then
            # No commit made and nothing to push
            local step_issues="### Git Finalization Summary

**Status:** No changes to commit
**Branch:** ${current_branch}
**Commits Ahead:** 0

No changes were detected. Repository is up to date with remote.
"
            save_step_issues "11" "Git_Finalization" "$step_issues"
            save_step_summary "11" "Git_Finalization" "No changes to commit. Repository up to date with origin/${current_branch}." "✅"
        fi
        
        update_workflow_status "step12" "✅"
        return 0
    fi
    
    # Local is ahead - push needed
    echo ""
    if [[ "$commit_was_made" == "true" ]]; then
        print_warning "🔴 CRITICAL: Ready to push newly created commit to origin"
    else
        print_warning "🔴 CRITICAL: Local branch is ${commits_ahead} commit(s) ahead of origin"
        print_info "No new commit created, but existing commits need to be pushed"
    fi
    
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        if ! confirm_action "Push to remote repository?"; then
            print_warning "Push skipped - workflow incomplete"
            return 0
        fi
    fi
    
    # Save to backlog BEFORE push (in case push fails)
    local step_issues
    if [[ "$commit_was_made" == "true" ]]; then
        step_issues="### Git Finalization Summary

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
    else
        step_issues="### Git Finalization Summary

**Status:** No new commit (no changes detected)
**Branch:** ${current_branch}
**Commits Ahead:** ${commits_ahead}

No changes were detected, so no commit was created.
Pushing ${commits_ahead} existing commit(s) to remote.

### Latest Commit

\`\`\`
$(git show --stat HEAD 2>/dev/null || echo "Latest commit details unavailable")
\`\`\`
"
    fi
    save_step_issues "11" "Git_Finalization" "$step_issues"
    
    if git push origin "$current_branch"; then
        print_success "Successfully pushed to origin/$current_branch ✅"
        
        if [[ "$commit_was_made" == "true" ]]; then
            save_step_summary "11" "Git_Finalization" "Changes committed and pushed successfully to ${current_branch}. ${modified_count} files modified. Commit: ${commit_type}(${commit_scope})." "✅"
        else
            save_step_summary "11" "Git_Finalization" "Pushed ${commits_ahead} existing commit(s) to ${current_branch}. No new changes to commit." "✅"
        fi
        update_workflow_status "step12" "✅"
    else
        print_error "PUSH FAILED - workflow incomplete ❌"
        
        if [[ "$commit_was_made" == "true" ]]; then
            save_step_summary "11" "Git_Finalization" "FAILED: Push to ${current_branch} failed. Changes committed locally but not pushed to remote." "❌"
        else
            save_step_summary "11" "Git_Finalization" "FAILED: Push to ${current_branch} failed. ${commits_ahead} commit(s) remain unpushed." "❌"
        fi
        update_workflow_status "step12" "❌"
        return 1
    fi
    
    return 0
}

################################################################################
# SUBMODULE WORKFLOW ORCHESTRATION
################################################################################

# Process all submodules: update, commit, push
# Returns: 0 on success, 1 on failure
# Usage: process_submodules
process_submodules() {
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Check for --skip-submodules flag
    if [[ "${SKIP_SUBMODULES:-false}" == "true" ]]; then
        print_info "Submodule operations skipped (--skip-submodules flag)"
        return 0
    fi
    
    # Check if submodules exist
    if ! has_submodules; then
        print_info "No submodules configured - skipping submodule processing"
        return 0
    fi
    
    local submodule_count
    submodule_count=$(get_submodule_count)
    
    print_info "═══════════════════════════════════════════════════════════"
    print_info "Processing ${submodule_count} submodule(s)..."
    print_info "═══════════════════════════════════════════════════════════"
    
    local submodules
    submodules=$(detect_submodules)
    
    local processed=0
    local failed=0
    local skipped=0
    
    while IFS= read -r submodule_path; do
        print_info ""
        print_info "─────────────────────────────────────────────────────────"
        print_info "Submodule: ${submodule_path}"
        print_info "─────────────────────────────────────────────────────────"
        
        # Validate submodule state
        if ! validate_submodule_state "$submodule_path"; then
            print_error "Submodule validation failed: ${submodule_path}"
            ((failed++))
            return 1  # Stop on validation error
        fi
        
        # Initialize if needed
        if ! is_submodule_initialized "$submodule_path"; then
            print_info "Initializing submodule..."
            if ! init_submodule "$submodule_path"; then
                print_error "Failed to initialize submodule: ${submodule_path}"
                ((failed++))
                return 1
            fi
        fi
        
        # Update submodule to latest remote
        print_info "Updating submodule from remote..."
        if ! update_submodule "$submodule_path"; then
            print_error "Failed to update submodule: ${submodule_path}"
            ((failed++))
            return 1
        fi
        
        # Check for changes within submodule
        if ! has_submodule_changes "$submodule_path"; then
            print_info "No changes in submodule - skipping commit"
            ((skipped++))
            
            # Check if pointer changed in parent
            if has_submodule_pointer_change "$submodule_path"; then
                print_info "Submodule pointer updated (will be committed in parent)"
            fi
            
            ((processed++))
            continue
        fi
        
        # Display submodule status
        print_submodule_status "$submodule_path"
        echo ""
        
        # Stage changes in submodule
        print_info "Staging changes in submodule..."
        if ! stage_submodule_changes "$submodule_path"; then
            print_error "Failed to stage submodule changes: ${submodule_path}"
            ((failed++))
            return 1
        fi
        
        # Generate commit message for submodule
        print_info "Generating AI commit message for submodule..."
        local submodule_commit_msg=""
        
        # Try AI generation if in AI batch mode
        if [[ "${AI_BATCH_MODE:-false}" == "true" ]] && command -v copilot &>/dev/null; then
            local ai_start
            ai_start=$(date +%s)
            
            if submodule_commit_msg=$(generate_submodule_commit_message "$submodule_path" 2>&1); then
                local ai_end
                ai_end=$(date +%s)
                local ai_duration=$((ai_end - ai_start))
                
                print_success "AI generated submodule commit message (${ai_duration}s)"
                echo ""
                print_info "Generated Message:"
                echo -e "${CYAN}${submodule_commit_msg}${NC}"
                echo ""
            else
                print_warning "AI generation failed for submodule, using fallback"
                submodule_commit_msg=$(generate_submodule_fallback_message "$submodule_path")
                echo ""
                print_info "Fallback Message:"
                echo -e "${YELLOW}${submodule_commit_msg}${NC}"
                echo ""
            fi
        else
            # Use fallback message
            submodule_commit_msg=$(generate_submodule_fallback_message "$submodule_path")
            print_info "Using fallback commit message for submodule:"
            echo -e "${YELLOW}${submodule_commit_msg}${NC}"
            echo ""
        fi
        
        # Confirm commit in interactive mode
        if [[ "$INTERACTIVE_MODE" == true ]]; then
            if ! confirm_action "Commit changes in submodule ${submodule_path}?"; then
                print_warning "Submodule commit cancelled by user"
                ((skipped++))
                continue
            fi
        fi
        
        # Commit changes in submodule
        print_info "Committing changes in submodule..."
        if ! commit_submodule_changes "$submodule_path" "$submodule_commit_msg"; then
            print_error "Failed to commit submodule changes: ${submodule_path}"
            ((failed++))
            return 1
        fi
        
        print_success "Submodule committed successfully"
        
        # Push submodule to remote
        print_info "Pushing submodule to remote..."
        if ! push_submodule "$submodule_path"; then
            print_error "Failed to push submodule: ${submodule_path}"
            print_error "Changes are committed locally but not pushed"
            ((failed++))
            return 1
        fi
        
        print_success "Submodule pushed successfully ✅"
        
        # Stage submodule pointer update in parent
        print_info "Staging submodule pointer update in parent..."
        if ! git add "$submodule_path"; then
            print_error "Failed to stage submodule pointer: ${submodule_path}"
            ((failed++))
            return 1
        fi
        
        print_success "Submodule pointer staged in parent repository"
        
        ((processed++))
        
    done <<< "$submodules"
    
    # Summary
    print_info ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "Submodule Processing Complete"
    print_info "═══════════════════════════════════════════════════════════"
    print_info "Total:     ${submodule_count}"
    print_info "Processed: ${processed}"
    print_info "Skipped:   ${skipped} (no changes)"
    print_info "Failed:    ${failed}"
    print_info "═══════════════════════════════════════════════════════════"
    
    if [[ $failed -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# Main step function - finalizes git operations with AI-generated commit messages
# Returns: 0 for success, 1 for failure
step12_git_finalization() {
    print_step "11" "Git Finalization"
    
    cd "$PROJECT_ROOT"
    
    local git_analysis=$(mktemp)
    TEMP_FILES+=("$git_analysis")
    
    # Dry-run preview
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Git operations preview:"
        print_info "  - Would check for submodules and process them"
        print_info "  - Would check for changes to commit"
        print_info "  - Would stage changes if any exist"
        print_info "  - Would generate AI commit message if changes exist"
        print_info "  - Would commit with comprehensive message if changes exist"
        print_info "  - Would push to origin if local is ahead"
        
        # Save dry-run status to backlog
        local step_issues="### Git Finalization - DRY RUN

**Status:** ✅ DRY RUN MODE

Dry run mode enabled. No actual git operations performed.

### Planned Operations
- Detect and process all git submodules
- Update submodules to latest remote
- Commit and push submodule changes
- Check for changes to commit in parent
- Stage changes if any exist
- Generate AI commit message if changes exist
- Commit with comprehensive message if changes exist
- Push to origin if local is ahead of remote
"
        save_step_issues "11" "Git_Finalization" "$step_issues"
        save_step_summary "11" "Git_Finalization" "Dry run mode - no git operations performed." "✅"
        
        update_workflow_status "step12" "✅"
        return 0
    fi
    
    # PHASE 1: Automated git analysis (use cached git state)
    print_info "Phase 1: Analyzing git repository state..."
    
    # Refresh git cache to get current state (fixes stale cache issue)
    if command -v refresh_git_cache &>/dev/null; then
        refresh_git_cache
    else
        print_warning "refresh_git_cache not available - using potentially stale cache"
    fi
    
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
    
    # PHASE 1.5: Process submodules (if any)
    echo ""
    print_info "Phase 1.5: Processing git submodules..."
    
    # Process submodules before committing parent
    if ! process_submodules; then
        print_error "Submodule processing failed"
        update_workflow_status "step12" "❌"
        return 1
    fi
    
    # Refresh git cache after submodule operations (may have staged submodule pointers)
    if command -v refresh_git_cache &>/dev/null; then
        refresh_git_cache
        # Update counts after submodule processing
        total_changes=$(get_git_total_changes)
        staged_count=$(get_git_staged_count)
    fi
    
    # CHECK: Early detection of no changes to commit
    echo ""
    print_info "Checking for changes to commit..."
    
    if [[ "$total_changes" -eq 0 ]] && [[ "$staged_count" -eq 0 ]]; then
        print_info "No changes detected - skipping commit phase"
        echo ""
        
        # Check if we need to push existing commits
        print_info "Checking for unpushed commits..."
        push_if_ahead "false" "" "" "" "0" "0"
        
        # Set executable permissions on shell scripts (only if workflow directory exists)
        if [[ -d "${WORKFLOW_ROOT:-}/src/workflow" ]]; then
            print_info "Setting executable permissions on shell scripts..."
            find "${WORKFLOW_ROOT}/src/workflow" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
            print_success "Permissions updated"
        fi
        
        return 0
    fi
    
    print_success "Changes detected: ${total_changes} files to commit"
    
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
    copilot_prompt=$(build_step12_git_commit_prompt \
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
    
    # Stage changes (v2.7.1: Atomic staging strategy)
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
        
        # Check if AI batch mode (with Copilot available) - NEW v2.7.1
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
                local log_file="${LOGS_RUN_DIR}/step12_copilot_commit_message_${log_timestamp}.log"
                print_info "Logging output to: $log_file"
                
                # Execute Copilot prompt
                execute_copilot_prompt "$copilot_prompt" "$log_file" "step12" "git_workflow_specialist"
                
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
    
    # Push to remote using extracted function
    push_if_ahead "true" "$commit_type" "$commit_scope" "$commit_message" "$modified_count" "$total_changes"
    local push_result=$?
    
    # Set executable permissions on shell scripts (only if workflow directory exists)
    if [[ -d "${WORKFLOW_ROOT:-}/src/workflow" ]]; then
        print_info "Setting executable permissions on shell scripts..."
        find "${WORKFLOW_ROOT}/src/workflow" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        print_success "Permissions updated"
    fi
    
    return $push_result
}

# Alias for backward compatibility (main script calls step11_git_finalization)
step11_git_finalization() {
    step12_git_finalization "$@"
}

# Export functions
export -f push_if_ahead
export -f process_submodules
export -f step12_git_finalization step11_git_finalization
