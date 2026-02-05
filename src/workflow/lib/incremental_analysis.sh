#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Incremental Analysis Module
# Purpose: Optimize Steps 2 and 4 for client_spa projects with change-based analysis
# Part of: Tests & Documentation Workflow Automation v2.7.0
# Created: 2026-01-27
################################################################################

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Cache directory for git tree data
# Only declare as readonly if not already set (avoid errors when sourced multiple times)
if [[ -z "${INCREMENTAL_CACHE_DIR:-}" ]]; then
    readonly INCREMENTAL_CACHE_DIR="${PROJECT_ROOT:-.}/.ai_workflow/.incremental_cache"
fi

# ==============================================================================
# CACHE MANAGEMENT
# ==============================================================================

# Initialize cache directory
# Usage: init_incremental_cache
init_incremental_cache() {
    mkdir -p "$INCREMENTAL_CACHE_DIR"
}

# Get cached git tree for directory analysis
# Usage: get_cached_tree <output_file>
# Returns: 0 if cache exists and is valid, 1 otherwise
get_cached_tree() {
    local output_file="${1:-${INCREMENTAL_CACHE_DIR}/tree.txt}"
    local cache_file="${INCREMENTAL_CACHE_DIR}/tree_cache.txt"
    local cache_timestamp="${INCREMENTAL_CACHE_DIR}/tree_cache.timestamp"
    
    # Check if cache exists and is less than 1 hour old
    if [[ -f "$cache_file" ]] && [[ -f "$cache_timestamp" ]]; then
        local cache_age=$(($(date +%s) - $(cat "$cache_timestamp")))
        if [[ $cache_age -lt 3600 ]]; then
            cp "$cache_file" "$output_file"
            return 0
        fi
    fi
    
    # Cache is stale or doesn't exist - regenerate
    git ls-tree -r HEAD --name-only | grep 'src/' > "$cache_file" 2>/dev/null || true
    date +%s > "$cache_timestamp"
    cp "$cache_file" "$output_file"
    
    return 0
}

# ==============================================================================
# CHANGE-BASED FILE FILTERING
# ==============================================================================

# Get list of changed JavaScript/source files since last commit
# Usage: get_changed_js_files [base_ref]
# Returns: List of changed .js/.mjs files (one per line)
get_changed_js_files() {
    local base_ref="${1:-HEAD~1}"
    
    # Get changed files, filter for JavaScript
    git diff --name-only "$base_ref" 2>/dev/null | grep '\.\(js\|mjs\)$' || true
}

# Get list of changed files for consistency analysis
# Usage: get_changed_consistency_files [base_ref]
# Returns: List of changed documentation and code files
get_changed_consistency_files() {
    local base_ref="${1:-HEAD~1}"
    
    # Get changed files, filter for docs and source
    git diff --name-only "$base_ref" 2>/dev/null | \
        grep -E '\.(md|js|mjs|json|yaml|yml)$' || true
}

# Check if incremental analysis should be used
# Usage: should_use_incremental_analysis <project_kind>
# Returns: 0 if incremental analysis is applicable, 1 otherwise
should_use_incremental_analysis() {
    local project_kind="${1:-unknown}"
    
    # Only apply to client_spa projects
    [[ "$project_kind" == "client_spa" ]] || return 1
    
    # Check if we're in a git repository
    git rev-parse --git-dir &>/dev/null || return 1
    
    # Check if there are previous commits (need at least 2 commits)
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    [[ $commit_count -ge 2 ]] || return 1
    
    return 0
}

# ==============================================================================
# STEP 2 OPTIMIZATION: CONSISTENCY ANALYSIS
# ==============================================================================

# Get documentation inventory with incremental filtering
# Usage: get_incremental_doc_inventory [base_ref]
# Returns: List of documentation files to analyze
get_incremental_doc_inventory() {
    local base_ref="${1:-HEAD~1}"
    
    # Get changed markdown files
    local changed_docs=$(git diff --name-only "$base_ref" 2>/dev/null | grep '\.md$' || true)
    
    if [[ -z "$changed_docs" ]]; then
        echo "No documentation changes detected"
        return 1
    fi
    
    echo "$changed_docs"
    return 0
}

# Analyze consistency for changed files only
# Usage: analyze_consistency_incremental [base_ref]
# Returns: Consistency analysis results
analyze_consistency_incremental() {
    local base_ref="${1:-HEAD~1}"
    local changed_files=$(get_changed_consistency_files "$base_ref")
    
    if [[ -z "$changed_files" ]]; then
        if command -v print_success &>/dev/null; then
            print_success "No files changed - skipping consistency analysis"
        fi
        return 0
    fi
    
    local file_count=$(echo "$changed_files" | wc -l)
    if command -v print_info &>/dev/null; then
        print_info "Incremental analysis: checking ${file_count} changed file(s)"
    fi
    
    # Return list for further processing
    echo "$changed_files"
}

# ==============================================================================
# STEP 4 OPTIMIZATION: DIRECTORY STRUCTURE
# ==============================================================================

# Get directory structure using cached git tree
# Usage: get_cached_directory_tree
# Returns: Directory tree from cache or generates new one
get_cached_directory_tree() {
    local cache_file="${INCREMENTAL_CACHE_DIR}/tree_cache.txt"
    
    init_incremental_cache
    
    # Use cached tree if available
    if get_cached_tree "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    # Fallback to live tree generation
    git ls-tree -r HEAD --name-only | grep 'src/' || true
}

# Check if directory structure validation can be skipped
# Usage: can_skip_directory_validation [base_ref]
# Returns: 0 if can skip, 1 if full validation needed
can_skip_directory_validation() {
    local base_ref="${1:-HEAD~1}"
    
    # Check if any structural changes occurred
    local structural_changes=$(git diff --name-only "$base_ref" 2>/dev/null | \
        grep -E '(package\.json|\.github/|src/[^/]+/$|tests?/|docs/)' || true)
    
    if [[ -z "$structural_changes" ]]; then
        if command -v print_info &>/dev/null; then
            print_info "No structural changes detected - directory validation can be optimized"
        fi
        return 0
    fi
    
    if command -v print_info &>/dev/null; then
        print_info "Structural changes detected - full directory validation required"
    fi
    return 1
}

# ==============================================================================
# METRICS AND REPORTING
# ==============================================================================

# Calculate time savings from incremental analysis
# Usage: calculate_incremental_savings <total_files> <analyzed_files>
calculate_incremental_savings() {
    local total_files="${1:-0}"
    local analyzed_files="${2:-0}"
    
    if [[ $total_files -eq 0 ]]; then
        echo "0"
        return
    fi
    
    local percentage=$((100 - (analyzed_files * 100 / total_files)))
    echo "$percentage"
}

# Report incremental analysis statistics
# Usage: report_incremental_stats <step_number> <total_files> <analyzed_files>
report_incremental_stats() {
    local step_number="$1"
    local total_files="$2"
    local analyzed_files="$3"
    
    local savings=$(calculate_incremental_savings "$total_files" "$analyzed_files")
    
    print_info "Step ${step_number} Incremental Analysis:"
    print_info "  - Total files: ${total_files}"
    print_info "  - Analyzed files: ${analyzed_files}"
    print_info "  - Time savings: ~${savings}%"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f init_incremental_cache
export -f get_cached_tree
export -f get_changed_js_files
export -f get_changed_consistency_files
export -f should_use_incremental_analysis
export -f get_incremental_doc_inventory
export -f analyze_consistency_incremental
export -f get_cached_directory_tree
export -f can_skip_directory_validation
export -f calculate_incremental_savings
export -f report_incremental_stats
