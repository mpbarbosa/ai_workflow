#!/bin/bash
set -euo pipefail

################################################################################
# Git State Caching Module
# Purpose: Performance optimization via centralized git state caching
# Part of: Tests & Documentation Workflow Automation v2.0.0
#
# Performance Impact: 25-30% faster execution (eliminates 30+ git subprocess calls)
# See: /docs/WORKFLOW_PERFORMANCE_OPTIMIZATION.md
################################################################################

# ==============================================================================
# GLOBAL CACHE VARIABLES
# ==============================================================================

# Associative array for structured git state
declare -A GIT_CACHE

# Raw git output caches
GIT_STATUS_OUTPUT=""
GIT_STATUS_SHORT_OUTPUT=""
GIT_DIFF_STAT_OUTPUT=""
GIT_DIFF_SUMMARY_OUTPUT=""
GIT_DIFF_FILES_OUTPUT=""

# ==============================================================================
# CACHE INITIALIZATION
# ==============================================================================

# Initialize git state cache - called once at workflow start
# Captures all git information in a single batch of queries
init_git_cache() {
    print_info "Initializing git state cache..."
    
    cd "$PROJECT_ROOT"
    
    # Single git status call - capture both formats
    GIT_STATUS_OUTPUT=$(git status --porcelain 2>/dev/null || echo "")
    GIT_STATUS_SHORT_OUTPUT=$(git status --short 2>/dev/null || echo "")
    
    # Single git diff call - capture stats, summary, and file list
    GIT_DIFF_STAT_OUTPUT=$(git diff --stat 2>/dev/null || echo "")
    GIT_DIFF_SUMMARY_OUTPUT=$(git diff --shortstat 2>/dev/null || echo "")
    
    # Get diff files and filter out workflow artifacts
    local raw_diff_files=$(git diff --name-only HEAD~1 2>/dev/null || git ls-files --modified 2>/dev/null || echo "")
    
    # Apply artifact filtering if available
    if command -v filter_workflow_artifacts &>/dev/null; then
        GIT_DIFF_FILES_OUTPUT=$(filter_workflow_artifacts "$raw_diff_files")
    else
        GIT_DIFF_FILES_OUTPUT="$raw_diff_files"
    fi
    
    # Single branch tracking call
    GIT_CACHE[current_branch]=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    GIT_CACHE[commits_ahead]=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    GIT_CACHE[commits_behind]=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    
    # Parse and cache file counts (single pass through git status output)
    local _modified=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^ M' 2>/dev/null || true)
    local _staged=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^[MARC]' 2>/dev/null || true)
    local _untracked=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^??' 2>/dev/null || true)
    local _deleted=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^ D' 2>/dev/null || true)
    
    GIT_CACHE[modified_count]=${_modified:-0}
    GIT_CACHE[staged_count]=${_staged:-0}
    GIT_CACHE[untracked_count]=${_untracked:-0}
    GIT_CACHE[deleted_count]=${_deleted:-0}
    GIT_CACHE[total_changes]=$((${_modified:-0} + ${_staged:-0} + ${_untracked:-0} + ${_deleted:-0}))
    
    # Cache file type counts (single pass)
    local _docs=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.md$\|docs/' 2>/dev/null || true)
    local _tests=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '__tests__/\|\.test\.\|\.spec\.' 2>/dev/null || true)
    local _scripts=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.sh$' 2>/dev/null || true)
    local _code=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.js$\|\.mjs$\|\.html$\|\.css$' 2>/dev/null || true)
    
    GIT_CACHE[docs_modified]=${_docs:-0}
    GIT_CACHE[tests_modified]=${_tests:-0}
    GIT_CACHE[scripts_modified]=${_scripts:-0}
    GIT_CACHE[code_modified]=${_code:-0}
    
    # Cache special file checks
    if echo "$GIT_STATUS_SHORT_OUTPUT" | grep -q "package.json\|package-lock.json"; then
        GIT_CACHE[deps_modified]="true"
    else
        GIT_CACHE[deps_modified]="false"
    fi
    
    # Cache git repository check
    if git rev-parse --git-dir > /dev/null 2>&1; then
        GIT_CACHE[is_git_repo]="true"
    else
        GIT_CACHE[is_git_repo]="false"
    fi
    
    print_success "Git cache initialized (branch: ${GIT_CACHE[current_branch]}, modified: ${GIT_CACHE[modified_count]}, staged: ${GIT_CACHE[staged_count]})"
}

# Refresh git state cache - call when git state changes (e.g., before Step 11)
# Updates all cached values with current git state
refresh_git_cache() {
    if [[ "${ENABLE_DEBUG_LOGGING:-false}" == "true" ]]; then
        print_debug "Refreshing git state cache..."
    fi
    
    cd "$PROJECT_ROOT"
    
    # Re-capture git status and diff (same as init)
    GIT_STATUS_OUTPUT=$(git status --porcelain 2>/dev/null || echo "")
    GIT_STATUS_SHORT_OUTPUT=$(git status --short 2>/dev/null || echo "")
    
    GIT_DIFF_STAT_OUTPUT=$(git diff --stat 2>/dev/null || echo "")
    GIT_DIFF_SUMMARY_OUTPUT=$(git diff --shortstat 2>/dev/null || echo "")
    
    local raw_diff_files=$(git diff --name-only HEAD~1 2>/dev/null || git ls-files --modified 2>/dev/null || echo "")
    
    if command -v filter_workflow_artifacts &>/dev/null; then
        GIT_DIFF_FILES_OUTPUT=$(filter_workflow_artifacts "$raw_diff_files")
    else
        GIT_DIFF_FILES_OUTPUT="$raw_diff_files"
    fi
    
    # Re-capture branch tracking
    GIT_CACHE[current_branch]=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    GIT_CACHE[commits_ahead]=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    GIT_CACHE[commits_behind]=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    
    # Re-parse file counts
    local _modified=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^ M' 2>/dev/null || true)
    local _staged=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^[MARC]' 2>/dev/null || true)
    local _untracked=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^??' 2>/dev/null || true)
    local _deleted=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '^ D' 2>/dev/null || true)
    
    GIT_CACHE[modified_count]=${_modified:-0}
    GIT_CACHE[staged_count]=${_staged:-0}
    GIT_CACHE[untracked_count]=${_untracked:-0}
    GIT_CACHE[deleted_count]=${_deleted:-0}
    GIT_CACHE[total_changes]=$((${_modified:-0} + ${_staged:-0} + ${_untracked:-0} + ${_deleted:-0}))
    
    # Re-cache file type counts
    local _docs=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.md$\|docs/' 2>/dev/null || true)
    local _tests=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '__tests__/\|\.test\.\|\.spec\.' 2>/dev/null || true)
    local _scripts=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.sh$' 2>/dev/null || true)
    local _code=$(echo "$GIT_STATUS_SHORT_OUTPUT" | grep -c '\.js$\|\.mjs$\|\.html$\|\.css$' 2>/dev/null || true)
    
    GIT_CACHE[docs_modified]=${_docs:-0}
    GIT_CACHE[tests_modified]=${_tests:-0}
    GIT_CACHE[scripts_modified]=${_scripts:-0}
    GIT_CACHE[code_modified]=${_code:-0}
    
    # Re-cache special file checks
    if echo "$GIT_STATUS_SHORT_OUTPUT" | grep -q "package.json\|package-lock.json"; then
        GIT_CACHE[deps_modified]="true"
    else
        GIT_CACHE[deps_modified]="false"
    fi
    
    if [[ "${ENABLE_DEBUG_LOGGING:-false}" == "true" ]]; then
        print_debug "Git cache refreshed (modified: ${GIT_CACHE[modified_count]}, staged: ${GIT_CACHE[staged_count]}, total: ${GIT_CACHE[total_changes]})"
    fi
}

# ==============================================================================
# ACCESSOR FUNCTIONS - Replace direct git calls throughout workflow
# ==============================================================================

# File count accessors
get_git_modified_count() { echo "${GIT_CACHE[modified_count]:-0}"; }
get_git_staged_count() { echo "${GIT_CACHE[staged_count]:-0}"; }
get_git_untracked_count() { echo "${GIT_CACHE[untracked_count]:-0}"; }
get_git_deleted_count() { echo "${GIT_CACHE[deleted_count]:-0}"; }
get_git_total_changes() { echo "${GIT_CACHE[total_changes]:-0}"; }

# Branch and tracking accessors
get_git_current_branch() { echo "${GIT_CACHE[current_branch]:-unknown}"; }
get_git_commits_ahead() { echo "${GIT_CACHE[commits_ahead]:-0}"; }
get_git_commits_behind() { echo "${GIT_CACHE[commits_behind]:-0}"; }

# Raw output accessors
get_git_status_output() { echo "$GIT_STATUS_OUTPUT"; }
get_git_status_short_output() { echo "$GIT_STATUS_SHORT_OUTPUT"; }
get_git_diff_stat_output() { echo "$GIT_DIFF_STAT_OUTPUT"; }
get_git_diff_summary_output() { echo "$GIT_DIFF_SUMMARY_OUTPUT"; }
get_git_diff_files_output() { echo "$GIT_DIFF_FILES_OUTPUT"; }

# File type accessors
get_git_docs_modified() { echo "${GIT_CACHE[docs_modified]:-0}"; }
get_git_tests_modified() { echo "${GIT_CACHE[tests_modified]:-0}"; }
get_git_scripts_modified() { echo "${GIT_CACHE[scripts_modified]:-0}"; }
get_git_code_modified() { echo "${GIT_CACHE[code_modified]:-0}"; }

# Boolean accessors
is_deps_modified() { [[ "${GIT_CACHE[deps_modified]:-false}" == "true" ]]; }
is_git_repo() { [[ "${GIT_CACHE[is_git_repo]:-false}" == "true" ]]; }

# Convenience aliases for backward compatibility
get_cached_git_branch() { echo "${GIT_CACHE[current_branch]:-unknown}"; }
get_cached_git_status() { echo "$GIT_STATUS_SHORT_OUTPUT"; }
get_cached_git_diff() { echo "$GIT_DIFF_FILES_OUTPUT"; }

# Export all accessor functions
export -f init_git_cache refresh_git_cache
export -f get_git_modified_count get_git_staged_count get_git_untracked_count get_git_deleted_count get_git_total_changes
export -f get_git_current_branch get_git_commits_ahead get_git_commits_behind
export -f get_git_status_output get_git_status_short_output get_git_diff_stat_output get_git_diff_summary_output get_git_diff_files_output
export -f get_git_docs_modified get_git_tests_modified get_git_scripts_modified get_git_code_modified
export -f is_deps_modified is_git_repo
export -f get_cached_git_branch get_cached_git_status get_cached_git_diff
