#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Branch Sync Validation Module
# Purpose: Validate branch sync with origin for deployment readiness (optional)
# Part of: Step 11 - Deployment Readiness Gate
################################################################################

# ==============================================================================
# BRANCH SYNC VALIDATION
# ==============================================================================

# Check if branch is up-to-date with origin
# Returns: 0 if in sync, 1 if out of sync or cannot determine
check_branch_sync() {
    # Get current branch
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [[ -z "$current_branch" ]]; then
        print_warning "Not on a branch (detached HEAD)"
        return 1
    fi
    
    # Check if remote tracking branch exists
    local remote_branch
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
    
    if [[ -z "$remote_branch" ]]; then
        print_warning "No remote tracking branch configured for ${current_branch}"
        return 1
    fi
    
    # Fetch latest from remote (with timeout)
    print_info "Fetching latest from remote..."
    if ! timeout 10s git fetch origin "$current_branch" 2>/dev/null; then
        print_warning "Could not fetch from remote (timeout or network issue)"
        # Don't fail - just warn
        return 1
    fi
    
    # Get commit hashes
    local local_hash
    local_hash=$(git rev-parse HEAD 2>/dev/null || echo "")
    
    local remote_hash
    remote_hash=$(git rev-parse "$remote_branch" 2>/dev/null || echo "")
    
    if [[ -z "$local_hash" || -z "$remote_hash" ]]; then
        print_warning "Could not determine commit hashes"
        return 1
    fi
    
    # Check if commits match
    if [[ "$local_hash" == "$remote_hash" ]]; then
        return 0
    fi
    
    # Check if local is ahead or behind
    local ahead
    ahead=$(git rev-list --count ${remote_branch}..HEAD 2>/dev/null || echo "0")
    
    local behind
    behind=$(git rev-list --count HEAD..${remote_branch} 2>/dev/null || echo "0")
    
    if [[ $ahead -gt 0 && $behind -eq 0 ]]; then
        print_warning "Local branch is ${ahead} commit(s) ahead of origin"
        print_warning "Push your changes before deployment"
        return 1
    elif [[ $behind -gt 0 && $ahead -eq 0 ]]; then
        print_warning "Local branch is ${behind} commit(s) behind origin"
        print_warning "Pull latest changes before deployment"
        return 1
    elif [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        print_warning "Branches have diverged (${ahead} ahead, ${behind} behind)"
        print_warning "Merge or rebase before deployment"
        return 1
    fi
    
    # Should not reach here
    return 1
}

# Get detailed branch sync information
# Returns: Multi-line string with sync details
get_branch_sync_info() {
    local info=""
    
    # Current branch
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
    info+="Current branch: ${current_branch}\n"
    
    # Remote tracking branch
    local remote_branch
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none")
    info+="Tracking: ${remote_branch}\n"
    
    if [[ "$remote_branch" != "none" ]]; then
        # Ahead/behind status
        local ahead
        ahead=$(git rev-list --count ${remote_branch}..HEAD 2>/dev/null || echo "0")
        
        local behind
        behind=$(git rev-list --count HEAD..${remote_branch} 2>/dev/null || echo "0")
        
        info+="Ahead by: ${ahead} commit(s)\n"
        info+="Behind by: ${behind} commit(s)\n"
        
        # Last sync time (last fetch)
        if [[ -f ".git/FETCH_HEAD" ]]; then
            local last_fetch
            last_fetch=$(stat -c %y .git/FETCH_HEAD 2>/dev/null | cut -d' ' -f1 || echo "unknown")
            info+="Last fetch: ${last_fetch}\n"
        fi
    fi
    
    echo -e "$info"
}

# Check if there are unpushed commits
# Returns: 0 if no unpushed commits, 1 if unpushed commits exist
check_unpushed_commits() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    [[ -z "$current_branch" ]] && return 1
    
    local remote_branch
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
    
    [[ -z "$remote_branch" ]] && return 1
    
    local ahead
    ahead=$(git rev-list --count ${remote_branch}..HEAD 2>/dev/null || echo "0")
    
    [[ $ahead -gt 0 ]] && return 1
    
    return 0
}

# Check if there are unpulled commits
# Returns: 0 if no unpulled commits, 1 if unpulled commits exist
check_unpulled_commits() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    [[ -z "$current_branch" ]] && return 1
    
    local remote_branch
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
    
    [[ -z "$remote_branch" ]] && return 1
    
    # Fetch with timeout
    timeout 5s git fetch origin "$current_branch" 2>/dev/null || return 1
    
    local behind
    behind=$(git rev-list --count HEAD..${remote_branch} 2>/dev/null || echo "0")
    
    [[ $behind -gt 0 ]] && return 1
    
    return 0
}

# Export functions
export -f check_branch_sync get_branch_sync_info
export -f check_unpushed_commits check_unpulled_commits
