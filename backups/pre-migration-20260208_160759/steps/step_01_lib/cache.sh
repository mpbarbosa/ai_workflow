#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 Cache Module
# Purpose: Performance caching for Step 1 documentation operations
# Part of: Step 1 Refactoring - Phase 1
# Version: 1.0.1
################################################################################

# Prevent double-loading
if [[ "${STEP1_CACHE_MODULE_LOADED:-}" == "true" ]]; then
    return 0
fi

# Module version
readonly STEP1_CACHE_VERSION="1.0.1"

# Performance cache for expensive operations
# Stores results of expensive operations to avoid recomputation
declare -A STEP1_CACHE

################################################################################
# PUBLIC API
################################################################################

# Initialize performance cache
# Clears any existing cache entries for fresh start
# Usage: init_step1_cache
# Returns: 0 on success
init_step1_cache() {
    STEP1_CACHE=()
    export STEP1_CACHE
    return 0
}

# Get cached value or execute function and cache result
# This is the core caching mechanism - checks cache first, executes on miss
# Usage: get_or_cache_step1 <cache_key> <function_name> [function_args...]
# Returns: Cached value or function output
# Example: result=$(get_or_cache_step1 "git_diff" get_git_diff_files_output)
get_or_cache_step1() {
    local cache_key="$1"
    shift
    
    # Temporarily disable nounset for array access (bash -u incompatible with associative arrays)
    set +u
    local cached_value="${STEP1_CACHE[$cache_key]:-}"
    set -u
    
    # Return cached value if exists
    if [[ -n "$cached_value" ]]; then
        echo "$cached_value"
        return 0
    fi
    
    # Execute function and cache result
    local result
    result=$("$@")
    STEP1_CACHE["$cache_key"]="$result"
    echo "$result"
    return 0
}

# Get cached git diff or fetch fresh
# Specialized cache for git diff operations
# Usage: get_cached_git_diff_step1
# Returns: Git diff files output (cached or fresh)
get_cached_git_diff_step1() {
    local cache_key="git_diff_files"
    
    # Temporarily disable nounset for array access (bash -u incompatible with associative arrays)
    set +u
    local cached_value="${STEP1_CACHE[$cache_key]:-}"
    set -u
    
    # Return cached value if exists
    if [[ -n "$cached_value" ]]; then
        echo "$cached_value"
        return 0
    fi
    
    # Get fresh git diff and cache it
    local diff_output
    diff_output=$(get_git_diff_files_output)
    STEP1_CACHE["$cache_key"]="$diff_output"
    echo "$diff_output"
    return 0
}

# Clear specific cache entry
# Usage: clear_cache_entry_step1 <cache_key>
# Returns: 0 on success
clear_cache_entry_step1() {
    local cache_key="$1"
    
    if [[ -v "STEP1_CACHE[$cache_key]" ]]; then
        unset STEP1_CACHE["$cache_key"]
    fi
    
    return 0
}

# Clear all cache entries
# Usage: clear_all_cache_step1
# Returns: 0 on success
clear_all_cache_step1() {
    STEP1_CACHE=()
    return 0
}

# Get cache statistics
# Usage: get_cache_stats_step1
# Returns: Number of cache entries
get_cache_stats_step1() {
    echo "${#STEP1_CACHE[@]}"
    return 0
}

# Check if key is cached
# Usage: is_cached_step1 <cache_key>
# Returns: 0 if cached, 1 if not
is_cached_step1() {
    local cache_key="$1"
    
    if [[ -v "STEP1_CACHE[$cache_key]" ]] && [[ -n "${STEP1_CACHE[$cache_key]}" ]]; then
        return 0
    fi
    
    return 1
}

################################################################################
# EXPORTS
################################################################################

# Export cache variable
export STEP1_CACHE

# Export all public functions
export -f init_step1_cache
export -f get_or_cache_step1
export -f get_cached_git_diff_step1
export -f clear_cache_entry_step1
export -f clear_all_cache_step1
export -f get_cache_stats_step1
export -f is_cached_step1

# Module loaded indicator
readonly STEP1_CACHE_MODULE_LOADED=true
export STEP1_CACHE_MODULE_LOADED
