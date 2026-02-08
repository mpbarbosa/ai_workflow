#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1.5 Incremental Analysis Module
# Version: 1.0.0
# Purpose: Filter changed files for smart execution
################################################################################

# Get changed source files (for smart execution)
# Returns: List of changed source files
get_changed_source_files_step1_5() {
    local changed_files=""
    
    # Use git to get changed files
    if command -v git &>/dev/null && [[ -d ".git" ]]; then
        # Get files changed in last commit or uncommitted changes
        changed_files=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")
        
        # Filter for source files
        echo "$changed_files" | grep -E '\.(sh|py|js|ts|jsx|tsx|go|java)$' || true
    fi
}

# Get all source files
# Returns: List of all source files
get_all_source_files_step1_5() {
    local source_dir="${1:-src}"
    
    find "$source_dir" \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
        -o -name "*.jsx" -o -name "*.tsx" -o -name "*.go" -o -name "*.java" \) \
        -type f \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -path "*/vendor/*" \
        ! -path "*/test/*" \
        ! -path "*/tests/*" \
        2>/dev/null || true
}

# Determine if incremental analysis should be used
# Returns: 0 if should use incremental, 1 otherwise
should_use_incremental_analysis_step1_5() {
    local smart_execution="${SMART_EXECUTION:-false}"
    
    if [[ "$smart_execution" == "true" ]]; then
        # Check if there are changed files
        local changed=$(get_changed_source_files_step1_5)
        if [[ -n "$changed" ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Export functions
export -f get_changed_source_files_step1_5
export -f get_all_source_files_step1_5
export -f should_use_incremental_analysis_step1_5
