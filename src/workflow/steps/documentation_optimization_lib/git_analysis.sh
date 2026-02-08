#!/usr/bin/env bash
#
# Git History Analysis for Documentation Optimization
# Analyzes git history to identify outdated and abandoned documents
#
# Functions:
# - Last modification timestamp extraction
# - Commit frequency analysis
# - Abandoned file detection
# - Activity-based scoring
#

set -euo pipefail

################################################################################
# Get last modification timestamp for a file from git
# Arguments:
#   $1 - File path (relative to repo root)
# Returns:
#   Unix timestamp of last modification, or 0 if not in git
################################################################################
get_file_last_modified() {
    local file="$1"
    
    # Check if file is tracked by git
    if ! git ls-files --error-unmatch "$file" &>/dev/null; then
        echo "0"
        return
    fi
    
    # Get last commit timestamp for this file
    local timestamp
    timestamp=$(git log -1 --format=%ct -- "$file" 2>/dev/null || echo "0")
    
    echo "$timestamp"
}

################################################################################
# Get commit count for a file in the last N months
# Arguments:
#   $1 - File path
#   $2 - Number of months to look back
# Returns:
#   Number of commits
################################################################################
get_file_commit_count() {
    local file="$1"
    local months="${2:-12}"
    
    # Calculate date N months ago
    local since_date
    since_date=$(date -d "$months months ago" +%Y-%m-%d 2>/dev/null || date -v-${months}m +%Y-%m-%d 2>/dev/null || echo "")
    
    if [[ -z "$since_date" ]]; then
        # Fallback: approximate as days
        local days=$((months * 30))
        since_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || echo "2020-01-01")
    fi
    
    # Count commits since date
    local count
    count=$(git log --since="$since_date" --oneline -- "$file" 2>/dev/null | wc -l)
    
    echo "$count"
}

################################################################################
# Check if file has been modified recently
# Arguments:
#   $1 - File path
#   $2 - Threshold in months (default: 12)
# Returns:
#   0 if modified recently, 1 if outdated
################################################################################
is_file_recently_modified() {
    local file="$1"
    local threshold_months="${2:-12}"
    
    local last_modified
    last_modified=$(get_file_last_modified "$file")
    
    # If not tracked or no history, consider recent
    if [[ $last_modified -eq 0 ]]; then
        return 0
    fi
    
    # Calculate threshold timestamp
    local threshold_timestamp
    local threshold_days=$((threshold_months * 30))
    threshold_timestamp=$(date -d "$threshold_days days ago" +%s 2>/dev/null || \
                         date -v-${threshold_days}d +%s 2>/dev/null || \
                         echo "0")
    
    # Compare timestamps
    if [[ $last_modified -lt $threshold_timestamp ]]; then
        return 1  # Outdated
    else
        return 0  # Recent
    fi
}

################################################################################
# Analyze git history for all documentation files
# Populates DOC_LAST_MODIFIED map
################################################################################
analyze_git_history() {
    print_info "Analyzing git history for documentation files..."
    
    local file timestamp
    local analyzed=0
    
    while IFS= read -r file; do
        # Skip excluded files
        if should_exclude_file "$file"; then
            continue
        fi
        
        # Get last modification timestamp
        timestamp=$(get_file_last_modified "$file")
        DOC_LAST_MODIFIED["$file"]="$timestamp"
        
        ((analyzed++))
    done < <(find "$DOCS_DIR" -name "*.md" -type f)
    
    print_success "Analyzed git history for $analyzed files"
    return 0
}

################################################################################
# Identify outdated files based on git history
# Populates OUTDATED_FILES array
################################################################################
identify_outdated_files() {
    local threshold_months="${DEFAULT_OUTDATED_THRESHOLD_MONTHS}"
    local current_time
    current_time=$(date +%s)
    
    print_info "Identifying outdated files (threshold: $threshold_months months)..."
    
    local file timestamp age_months
    local outdated_count=0
    
    for file in "${!DOC_LAST_MODIFIED[@]}"; do
        timestamp="${DOC_LAST_MODIFIED[$file]}"
        
        # Skip files not in git
        if [[ $timestamp -eq 0 ]]; then
            continue
        fi
        
        # Calculate age in months
        local age_seconds=$((current_time - timestamp))
        age_months=$((age_seconds / 60 / 60 / 24 / 30))
        
        # Check if outdated
        if [[ $age_months -gt $threshold_months ]]; then
            # Additional checks: has file been referenced recently?
            local commit_count
            commit_count=$(get_file_commit_count "$file" 6)  # Last 6 months
            
            if [[ $commit_count -eq 0 ]]; then
                OUTDATED_FILES+=("$file")
                ((outdated_count++))
                
                print_debug "Outdated: $file (last modified $age_months months ago)"
            else
                print_debug "Skipping $file (has recent activity: $commit_count commits in last 6 months)"
            fi
        fi
    done
    
    print_success "Identified $outdated_count outdated files"
    return 0
}

################################################################################
# Check if file is referenced by other files
# Arguments:
#   $1 - File path to check
# Returns:
#   Number of files that reference this file
################################################################################
count_file_references() {
    local target_file="$1"
    local basename
    basename=$(basename "$target_file")
    
    # Search for references in other markdown files
    # Look for: [text](filename.md) or [text](path/to/filename.md)
    local ref_count
    ref_count=$(grep -r "\]($basename)" "$DOCS_DIR" --include="*.md" 2>/dev/null | \
                grep -v "^$target_file:" | \
                wc -l)
    
    echo "$ref_count"
}

################################################################################
# Get list of files that haven't been touched in active development period
# Arguments:
#   $1 - Project root directory
# Returns:
#   List of potentially abandoned files
################################################################################
find_abandoned_files() {
    local project_root="$1"
    
    print_info "Searching for abandoned files..."
    
    # Get recent commit activity (last 3 months)
    local recent_files
    recent_files=$(git log --since="3 months ago" --name-only --pretty=format: -- "$DOCS_DIR" 2>/dev/null | \
                   sort -u | \
                   grep "\.md$" || true)
    
    local abandoned_count=0
    
    # Check each documentation file
    while IFS= read -r file; do
        if should_exclude_file "$file"; then
            continue
        fi
        
        # Skip if already identified as outdated
        local is_outdated=false
        for outdated in "${OUTDATED_FILES[@]}"; do
            if [[ "$file" == "$outdated" ]]; then
                is_outdated=true
                break
            fi
        done
        [[ "$is_outdated" == "true" ]] && continue
        
        # Check if file is in recent activity list
        if ! echo "$recent_files" | grep -q "^$file$"; then
            # File hasn't been touched recently - check if it's referenced
            local ref_count
            ref_count=$(count_file_references "$file")
            
            if [[ $ref_count -eq 0 ]]; then
                # Not referenced and not recently modified - likely abandoned
                print_debug "Potentially abandoned: $file (no recent activity, no references)"
                OUTDATED_FILES+=("$file")
                ((abandoned_count++))
            fi
        fi
    done < <(find "$DOCS_DIR" -name "*.md" -type f)
    
    print_success "Found $abandoned_count abandoned files"
    return 0
}

################################################################################
# Generate git history report for a file
# Arguments:
#   $1 - File path
# Returns:
#   Formatted history summary
################################################################################
generate_file_history_summary() {
    local file="$1"
    
    local timestamp="${DOC_LAST_MODIFIED[$file]:-0}"
    
    if [[ $timestamp -eq 0 ]]; then
        echo "  Not tracked in git"
        return
    fi
    
    # Format timestamp
    local last_modified_date
    last_modified_date=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                        date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                        echo "unknown")
    
    # Get commit count (all time)
    local total_commits
    total_commits=$(git log --oneline -- "$file" 2>/dev/null | wc -l)
    
    # Get recent commits (last 6 months)
    local recent_commits
    recent_commits=$(get_file_commit_count "$file" 6)
    
    # Get file age (months since last modification)
    local current_time
    current_time=$(date +%s)
    local age_months=$(( (current_time - timestamp) / 60 / 60 / 24 / 30 ))
    
    echo "  Last modified: $last_modified_date ($age_months months ago)"
    echo "  Total commits: $total_commits"
    echo "  Recent commits (6mo): $recent_commits"
}

################################################################################
# Main git history analysis entry point
# Called from main step
################################################################################
analyze_documentation_git_history() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        print_warning "Not a git repository - skipping git history analysis"
        return 1
    fi
    
    # Analyze git history
    if ! analyze_git_history; then
        print_error "Git history analysis failed"
        return 1
    fi
    
    # Identify outdated files
    if ! identify_outdated_files; then
        print_error "Outdated file identification failed"
        return 1
    fi
    
    # Find abandoned files
    if ! find_abandoned_files "$PROJECT_ROOT"; then
        print_warning "Abandoned file detection failed (non-fatal)"
    fi
    
    print_success "Git history analysis complete"
    return 0
}

# Export functions
export -f get_file_last_modified
export -f get_file_commit_count
export -f is_file_recently_modified
export -f analyze_git_history
export -f identify_outdated_files
export -f count_file_references
export -f find_abandoned_files
export -f generate_file_history_summary
export -f analyze_documentation_git_history
