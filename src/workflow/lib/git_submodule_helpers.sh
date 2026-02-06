#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Git Submodule Helper Module
# Purpose: Manage git submodule operations for Step 11
# Version: 1.0.0
# Part of: Tests & Documentation Workflow Automation v3.1.0
#
# Features:
# - Submodule detection and enumeration
# - Change detection within submodules
# - Update and synchronization operations
# - Status checking and validation
# - Diff generation for AI commit messages
################################################################################

# Module version
readonly GIT_SUBMODULE_HELPERS_VERSION="1.0.0"

################################################################################
# SUBMODULE DETECTION & ENUMERATION
################################################################################

# Detect all configured submodules from .gitmodules
# Returns: List of submodule paths (one per line), or empty if none
# Usage: submodules=$(detect_submodules)
detect_submodules() {
    local project_root="${PROJECT_ROOT:-.}"
    
    # Check if .gitmodules exists
    if [[ ! -f "${project_root}/.gitmodules" ]]; then
        return 0
    fi
    
    # Parse .gitmodules for submodule paths
    cd "$project_root"
    git config --file .gitmodules --get-regexp path | awk '{ print $2 }' || true
}

# Check if project has any submodules configured
# Returns: 0 if submodules exist, 1 if none
# Usage: if has_submodules; then ...
has_submodules() {
    local submodules
    submodules=$(detect_submodules)
    [[ -n "$submodules" ]]
}

# Get count of configured submodules
# Returns: Number of submodules
# Usage: count=$(get_submodule_count)
get_submodule_count() {
    local submodules
    submodules=$(detect_submodules)
    if [[ -z "$submodules" ]]; then
        echo "0"
    else
        echo "$submodules" | wc -l
    fi
}

################################################################################
# SUBMODULE STATUS CHECKING
################################################################################

# Check if submodule is initialized
# Args: $1 - submodule path
# Returns: 0 if initialized, 1 if not
# Usage: if is_submodule_initialized ".workflow_core"; then ...
is_submodule_initialized() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Check if submodule directory exists and has .git
    if [[ -d "${submodule_path}/.git" ]] || [[ -f "${submodule_path}/.git" ]]; then
        return 0
    fi
    
    return 1
}

# Get submodule status (clean, modified, untracked, etc.)
# Args: $1 - submodule path
# Returns: Status string (clean, dirty, uninitialized, detached)
# Usage: status=$(get_submodule_status ".workflow_core")
get_submodule_status() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Check if initialized
    if ! is_submodule_initialized "$submodule_path"; then
        echo "uninitialized"
        return 0
    fi
    
    # Check for detached HEAD
    if ! (cd "$submodule_path" && git symbolic-ref HEAD &>/dev/null); then
        echo "detached"
        return 0
    fi
    
    # Check for uncommitted changes
    if (cd "$submodule_path" && [[ -n "$(git status --porcelain)" ]]); then
        echo "dirty"
        return 0
    fi
    
    echo "clean"
}

# Check if submodule has uncommitted changes
# Args: $1 - submodule path
# Returns: 0 if changes exist, 1 if clean
# Usage: if has_submodule_changes ".workflow_core"; then ...
has_submodule_changes() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        return 1
    fi
    
    (cd "$submodule_path" && [[ -n "$(git status --porcelain)" ]])
}

# Check if submodule pointer has changed in parent repo
# Args: $1 - submodule path
# Returns: 0 if pointer changed, 1 if not
# Usage: if has_submodule_pointer_change ".workflow_core"; then ...
has_submodule_pointer_change() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Check if submodule path is in git status
    git status --porcelain | grep -q "^[AM] ${submodule_path}$"
}

# Get submodule current branch
# Args: $1 - submodule path
# Returns: Branch name or "detached"
# Usage: branch=$(get_submodule_branch ".workflow_core")
get_submodule_branch() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        echo "uninitialized"
        return 1
    fi
    
    (cd "$submodule_path" && git rev-parse --abbrev-ref HEAD 2>/dev/null) || echo "detached"
}

# Get submodule remote URL
# Args: $1 - submodule path
# Returns: Remote URL
# Usage: url=$(get_submodule_url ".workflow_core")
get_submodule_url() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    git config --file .gitmodules --get "submodule.${submodule_path}.url" || echo ""
}

################################################################################
# SUBMODULE UPDATE OPERATIONS
################################################################################

# Initialize submodule if not already initialized
# Args: $1 - submodule path
# Returns: 0 on success, 1 on failure
# Usage: init_submodule ".workflow_core"
init_submodule() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if is_submodule_initialized "$submodule_path"; then
        return 0
    fi
    
    print_info "Initializing submodule: ${submodule_path}"
    
    if ! git submodule init "$submodule_path"; then
        print_error "Failed to initialize submodule: ${submodule_path}"
        return 1
    fi
    
    if ! git submodule update "$submodule_path"; then
        print_error "Failed to update submodule: ${submodule_path}"
        return 1
    fi
    
    return 0
}

# Update submodule to latest remote commit
# Args: $1 - submodule path
# Returns: 0 on success, 1 on failure
# Usage: update_submodule ".workflow_core"
update_submodule() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Initialize if needed
    if ! is_submodule_initialized "$submodule_path"; then
        if ! init_submodule "$submodule_path"; then
            return 1
        fi
    fi
    
    print_info "Updating submodule: ${submodule_path}"
    
    # Check for uncommitted changes
    if has_submodule_changes "$submodule_path"; then
        print_warning "Submodule ${submodule_path} has uncommitted changes"
        print_info "Will commit changes before updating..."
    fi
    
    # Update to latest remote
    if ! git submodule update --remote --merge "$submodule_path" 2>&1; then
        print_error "Failed to update submodule: ${submodule_path}"
        print_info "Check for merge conflicts or network issues"
        return 1
    fi
    
    return 0
}

# Update all submodules in the repository
# Returns: 0 if all succeed, 1 if any fail
# Usage: update_all_submodules
update_all_submodules() {
    local submodules
    submodules=$(detect_submodules)
    
    if [[ -z "$submodules" ]]; then
        return 0
    fi
    
    local failed=0
    while IFS= read -r submodule_path; do
        if ! update_submodule "$submodule_path"; then
            failed=1
        fi
    done <<< "$submodules"
    
    return $failed
}

################################################################################
# SUBMODULE DIFF & CHANGE ANALYSIS
################################################################################

# Get detailed diff of submodule changes for AI context
# Args: $1 - submodule path
# Returns: Formatted diff string
# Usage: diff=$(get_submodule_diff ".workflow_core")
get_submodule_diff() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    local max_lines="${2:-200}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        echo "Submodule not initialized"
        return 1
    fi
    
    if ! has_submodule_changes "$submodule_path"; then
        echo "No changes in submodule"
        return 0
    fi
    
    # Get comprehensive diff
    local diff_output
    diff_output=$(cd "$submodule_path" && git diff --stat HEAD 2>/dev/null || true)
    
    # Limit lines if specified
    if [[ -n "$diff_output" ]] && [[ "$max_lines" -gt 0 ]]; then
        diff_output=$(echo "$diff_output" | head -n "$max_lines")
    fi
    
    echo "$diff_output"
}

# Get summary of submodule changes (files changed, insertions, deletions)
# Args: $1 - submodule path
# Returns: Summary string
# Usage: summary=$(get_submodule_change_summary ".workflow_core")
get_submodule_change_summary() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        echo "uninitialized"
        return 1
    fi
    
    (cd "$submodule_path" && git diff --shortstat HEAD 2>/dev/null || echo "no changes")
}

# Get list of modified files in submodule
# Args: $1 - submodule path
# Returns: List of files (one per line)
# Usage: files=$(get_submodule_modified_files ".workflow_core")
get_submodule_modified_files() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        return 1
    fi
    
    (cd "$submodule_path" && git status --porcelain | awk '{print $2}')
}

################################################################################
# SUBMODULE COMMIT OPERATIONS
################################################################################

# Stage all changes in submodule
# Args: $1 - submodule path
# Returns: 0 on success, 1 on failure
# Usage: stage_submodule_changes ".workflow_core"
stage_submodule_changes() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        print_error "Submodule not initialized: ${submodule_path}"
        return 1
    fi
    
    if ! has_submodule_changes "$submodule_path"; then
        return 0
    fi
    
    print_info "Staging changes in submodule: ${submodule_path}"
    
    if ! (cd "$submodule_path" && git add -A); then
        print_error "Failed to stage changes in submodule: ${submodule_path}"
        return 1
    fi
    
    return 0
}

# Commit changes in submodule
# Args: $1 - submodule path
#       $2 - commit message
# Returns: 0 on success, 1 on failure
# Usage: commit_submodule_changes ".workflow_core" "feat: update config"
commit_submodule_changes() {
    local submodule_path="${1:?Submodule path required}"
    local commit_message="${2:?Commit message required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        print_error "Submodule not initialized: ${submodule_path}"
        return 1
    fi
    
    # Stage changes first
    if ! stage_submodule_changes "$submodule_path"; then
        return 1
    fi
    
    # Check if there's anything to commit
    if ! (cd "$submodule_path" && git diff --cached --quiet); then
        print_info "Committing changes in submodule: ${submodule_path}"
        
        if ! (cd "$submodule_path" && git commit -m "$commit_message"); then
            print_error "Failed to commit changes in submodule: ${submodule_path}"
            return 1
        fi
    else
        print_info "No staged changes to commit in submodule: ${submodule_path}"
    fi
    
    return 0
}

# Push submodule changes to remote
# Args: $1 - submodule path
# Returns: 0 on success, 1 on failure
# Usage: push_submodule ".workflow_core"
push_submodule() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    if ! is_submodule_initialized "$submodule_path"; then
        print_error "Submodule not initialized: ${submodule_path}"
        return 1
    fi
    
    local branch
    branch=$(get_submodule_branch "$submodule_path")
    
    if [[ "$branch" == "detached" ]]; then
        print_error "Submodule is in detached HEAD state: ${submodule_path}"
        return 1
    fi
    
    print_info "Pushing submodule: ${submodule_path} to origin/${branch}"
    
    if ! (cd "$submodule_path" && git push origin "$branch"); then
        print_error "Failed to push submodule: ${submodule_path}"
        return 1
    fi
    
    return 0
}

################################################################################
# SUBMODULE VALIDATION
################################################################################

# Validate submodule state before operations
# Args: $1 - submodule path
# Returns: 0 if valid, 1 if invalid with error message
# Usage: validate_submodule_state ".workflow_core"
validate_submodule_state() {
    local submodule_path="${1:?Submodule path required}"
    local project_root="${PROJECT_ROOT:-.}"
    
    cd "$project_root"
    
    # Check if submodule is configured
    if ! git config --file .gitmodules --get "submodule.${submodule_path}.url" &>/dev/null; then
        print_error "Submodule not configured in .gitmodules: ${submodule_path}"
        return 1
    fi
    
    # Check if initialized
    if ! is_submodule_initialized "$submodule_path"; then
        print_warning "Submodule not initialized: ${submodule_path}"
        return 0  # Not an error, will be initialized
    fi
    
    # Check for detached HEAD
    local status
    status=$(get_submodule_status "$submodule_path")
    
    if [[ "$status" == "detached" ]]; then
        print_error "Submodule in detached HEAD state: ${submodule_path}"
        print_info "Run: cd ${submodule_path} && git checkout main"
        return 1
    fi
    
    return 0
}

################################################################################
# UTILITY FUNCTIONS
################################################################################

# Print formatted submodule status
# Args: $1 - submodule path
# Usage: print_submodule_status ".workflow_core"
print_submodule_status() {
    local submodule_path="${1:?Submodule path required}"
    
    local status
    status=$(get_submodule_status "$submodule_path")
    
    local branch
    branch=$(get_submodule_branch "$submodule_path")
    
    local url
    url=$(get_submodule_url "$submodule_path")
    
    echo "Submodule: ${submodule_path}"
    echo "  Status:  ${status}"
    echo "  Branch:  ${branch}"
    echo "  URL:     ${url}"
    
    if has_submodule_changes "$submodule_path"; then
        local summary
        summary=$(get_submodule_change_summary "$submodule_path")
        echo "  Changes: ${summary}"
    fi
}

# Export functions for use in other modules
export -f detect_submodules
export -f has_submodules
export -f get_submodule_count
export -f is_submodule_initialized
export -f get_submodule_status
export -f has_submodule_changes
export -f has_submodule_pointer_change
export -f get_submodule_branch
export -f get_submodule_url
export -f init_submodule
export -f update_submodule
export -f update_all_submodules
export -f get_submodule_diff
export -f get_submodule_change_summary
export -f get_submodule_modified_files
export -f stage_submodule_changes
export -f commit_submodule_changes
export -f push_submodule
export -f validate_submodule_state
export -f print_submodule_status
