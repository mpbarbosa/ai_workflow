#!/usr/bin/env bash
set -euo pipefail

################################################################################
# CHANGELOG Validation Module
# Purpose: Validate CHANGELOG.md updates for deployment readiness
# Part of: Step 11 - Deployment Readiness Gate
################################################################################

# ==============================================================================
# CHANGELOG VALIDATION
# ==============================================================================

# Check if CHANGELOG.md was updated in this workflow
# Returns: 0 if updated, 1 if not updated or missing
check_changelog_updated() {
    local changelog_file="${PROJECT_ROOT}/CHANGELOG.md"
    
    # Check 1: File exists
    if [[ ! -f "$changelog_file" ]]; then
        print_error "CHANGELOG.md not found at project root"
        return 1
    fi
    
    # Check 2: Staged changes (highest priority)
    if git diff --cached --name-only 2>/dev/null | grep -q "CHANGELOG.md"; then
        return 0
    fi
    
    # Check 3: Unstaged changes
    if git diff --name-only 2>/dev/null | grep -q "CHANGELOG.md"; then
        return 0
    fi
    
    # Check 4: Check if file was modified in recent commits (last 5)
    local recent_changes
    recent_changes=$(git log -5 --name-only --pretty=format: -- "$changelog_file" 2>/dev/null | grep -c "CHANGELOG.md" || echo "0")
    
    if [[ $recent_changes -gt 0 ]]; then
        return 0
    fi
    
    # Check 5: Compare file modification time with workflow start time
    if [[ -n "${WORKFLOW_START_TIME:-}" ]]; then
        local changelog_mtime
        changelog_mtime=$(stat -c %Y "$changelog_file" 2>/dev/null || stat -f %m "$changelog_file" 2>/dev/null || echo "0")
        
        if [[ $changelog_mtime -ge $WORKFLOW_START_TIME ]]; then
            return 0
        fi
    fi
    
    # Check 6: Check if CHANGELOG has content for current version
    # Look for version pattern in first 50 lines
    local has_version_entry=false
    if head -50 "$changelog_file" | grep -qE "\[Unreleased\]|## \[[0-9]+\.[0-9]+\.[0-9]+\]|## [0-9]+\.[0-9]+\.[0-9]+"; then
        # Check if the entry has content (not just heading)
        local line_count
        line_count=$(head -50 "$changelog_file" | wc -l)
        if [[ $line_count -gt 10 ]]; then
            has_version_entry=true
        fi
    fi
    
    if [[ "$has_version_entry" == "true" ]]; then
        # CHANGELOG has version entries, but check if recently updated
        local days_since_update
        days_since_update=$(( ($(date +%s) - $(stat -c %Y "$changelog_file" 2>/dev/null || stat -f %m "$changelog_file" 2>/dev/null || date +%s)) / 86400 ))
        
        if [[ $days_since_update -le 7 ]]; then
            return 0
        fi
    fi
    
    # If we reach here, CHANGELOG appears outdated
    print_error "CHANGELOG.md not updated (last modified: $(stat -c %y "$changelog_file" 2>/dev/null | cut -d' ' -f1 || echo "unknown"))"
    return 1
}

# Check if CHANGELOG follows Keep a Changelog format
# Returns: 0 if valid format, 1 if invalid
validate_changelog_format() {
    local changelog_file="${PROJECT_ROOT}/CHANGELOG.md"
    
    [[ ! -f "$changelog_file" ]] && return 1
    
    # Check for required sections
    local has_title=false
    local has_version=false
    local has_unreleased=false
    
    if head -10 "$changelog_file" | grep -qi "changelog\|change log"; then
        has_title=true
    fi
    
    if grep -qE "## \[[0-9]+\.[0-9]+\.[0-9]+\]|## [0-9]+\.[0-9]+\.[0-9]+" "$changelog_file"; then
        has_version=true
    fi
    
    if grep -qi "\[unreleased\]" "$changelog_file"; then
        has_unreleased=true
    fi
    
    if [[ "$has_title" == "true" && "$has_version" == "true" ]]; then
        return 0
    fi
    
    return 1
}

# Get CHANGELOG statistics
# Returns: Multi-line string with CHANGELOG statistics
get_changelog_stats() {
    local changelog_file="${PROJECT_ROOT}/CHANGELOG.md"
    local stats=""
    
    if [[ ! -f "$changelog_file" ]]; then
        echo "CHANGELOG.md not found"
        return 1
    fi
    
    # Count versions
    local version_count
    version_count=$(grep -cE "## \[[0-9]+\.[0-9]+\.[0-9]+\]|## [0-9]+\.[0-9]+\.[0-9]+" "$changelog_file" || echo "0")
    stats+="Versions documented: ${version_count}\n"
    
    # Count entries
    local entry_count
    entry_count=$(grep -cE "^- |^\\* " "$changelog_file" || echo "0")
    stats+="Total entries: ${entry_count}\n"
    
    # Last update
    local last_update
    last_update=$(stat -c %y "$changelog_file" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
    stats+="Last updated: ${last_update}\n"
    
    # File size
    local line_count
    line_count=$(wc -l < "$changelog_file")
    stats+="Lines: ${line_count}\n"
    
    echo -e "$stats"
}

# Export functions
export -f check_changelog_updated validate_changelog_format get_changelog_stats
