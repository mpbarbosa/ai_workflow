#!/usr/bin/env bash
#
# Workflow Profiles - Customize execution by change type
# 
# This module provides intelligent workflow customization based on detected
# change patterns. It defines execution profiles that skip unnecessary steps
# and focus on relevant validation for different change types.
#
# Version: 1.0.1
# Author: AI Workflow Team
# Last Modified: 2026-02-07
#
# Usage:
#   source workflow_profiles.sh
#   detect_workflow_profile
#   get_profile_steps "$WORKFLOW_PROFILE"
#
# Profiles:
#   - docs_only: Documentation changes only
#   - code_changes: Source code modifications
#   - infrastructure: CI/CD, dependencies, config
#   - test_changes: Test-only modifications
#   - full_validation: Run all steps (default)
#
# Environment Variables:
#   WORKFLOW_PROFILE - Set to override auto-detection
#   SKIP_PROFILE_DETECTION - Set to disable profile detection
#

set -euo pipefail

# Profile definitions
# Format: "profile_name|description|skip_steps|focus_steps|estimated_time"
declare -A WORKFLOW_PROFILES=(
    ["docs_only"]="Documentation changes only|7,8|2,4,10|8-12 minutes"
    ["code_changes"]="Source code modifications|2|7,8,9,13|20-25 minutes"
    ["test_changes"]="Test modifications only|2,4|7,9|15-18 minutes"
    ["infrastructure"]="CI/CD and dependencies|2,4|8,9,14|25-30 minutes"
    ["full_validation"]="Complete workflow validation|none|all|23-28 minutes"
)

# Step name to number mapping
declare -A STEP_NUMBERS=(
    ["analyze"]="0"
    ["tech_stack"]="1"
    ["documentation"]="2"
    ["script_refs"]="3"
    ["structure"]="4"
    ["code_analysis"]="5"
    ["ai_validation"]="6"
    ["tests"]="7"
    ["dependencies"]="8"
    ["quality"]="9"
    ["analysis"]="10"
    ["optimization"]="11"
    ["prompt"]="13"
    ["summary"]="14"
    ["version"]="15"
)

# File patterns for profile detection
declare -A PROFILE_PATTERNS=(
    ["docs_only"]="*.md|docs/|README*|CHANGELOG*|*.txt"
    ["code_changes"]="src/**/*.sh|*.sh|lib/*.sh"
    ["test_changes"]="test*.sh|*_test.sh|tests/"
    ["infrastructure"]="*.yml|*.yaml|.github/|Makefile|*.json"
)

#######################################
# Detect workflow profile based on git changes
# Analyzes changed files and selects appropriate profile
# Globals:
#   WORKFLOW_PROFILE
#   SKIP_PROFILE_DETECTION
# Arguments:
#   None
# Returns:
#   0 on success
#######################################
detect_workflow_profile() {
    # Skip if explicitly disabled
    if [[ "${SKIP_PROFILE_DETECTION:-false}" == "true" ]]; then
        WORKFLOW_PROFILE="full_validation"
        return 0
    fi

    # Skip if manually set
    if [[ -n "${WORKFLOW_PROFILE:-}" ]]; then
        log_info "Using manually set profile: $WORKFLOW_PROFILE"
        return 0
    fi

    log_info "Detecting workflow profile based on changes..."

    # Get changed files
    local changed_files
    changed_files=$(get_changed_files) || {
        log_warning "Could not detect changes, using full_validation"
        WORKFLOW_PROFILE="full_validation"
        return 0
    }

    # Count files by category
    local docs_count=0
    local code_count=0
    local test_count=0
    local infra_count=0
    local total_count=0

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        ((total_count++))

        # Check against patterns
        if matches_pattern "$file" "${PROFILE_PATTERNS[docs_only]}"; then
            ((docs_count++))
        elif matches_pattern "$file" "${PROFILE_PATTERNS[code_changes]}"; then
            ((code_count++))
        elif matches_pattern "$file" "${PROFILE_PATTERNS[test_changes]}"; then
            ((test_count++))
        elif matches_pattern "$file" "${PROFILE_PATTERNS[infrastructure]}"; then
            ((infra_count++))
        fi
    done <<< "$changed_files"

    # Determine profile based on dominant change type
    if [[ $total_count -eq 0 ]]; then
        WORKFLOW_PROFILE="full_validation"
    elif [[ $infra_count -gt 0 ]]; then
        # Infrastructure changes always trigger full validation
        WORKFLOW_PROFILE="infrastructure"
    elif [[ $docs_count -gt 0 && $code_count -eq 0 && $test_count -eq 0 ]]; then
        # Pure documentation changes
        WORKFLOW_PROFILE="docs_only"
    elif [[ $test_count -gt 0 && $code_count -eq 0 && $docs_count -eq 0 ]]; then
        # Pure test changes
        WORKFLOW_PROFILE="test_changes"
    elif [[ $code_count -gt 0 ]]; then
        # Any code changes
        WORKFLOW_PROFILE="code_changes"
    else
        # Mixed or unknown changes
        WORKFLOW_PROFILE="full_validation"
    fi

    log_info "Detected profile: $WORKFLOW_PROFILE"
    log_info "  Changed files: $total_count (docs: $docs_count, code: $code_count, tests: $test_count, infra: $infra_count)"

    export WORKFLOW_PROFILE
}

#######################################
# Get changed files from git
# Returns:
#   List of changed files, one per line
#######################################
get_changed_files() {
    # Try different methods to detect changes
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Try vs main branch
        git diff --name-only origin/main...HEAD 2>/dev/null || \
        git diff --name-only main...HEAD 2>/dev/null || \
        git diff --name-only HEAD~1 2>/dev/null || \
        git ls-files -m 2>/dev/null || \
        return 1
    else
        return 1
    fi
}

#######################################
# Check if file matches pattern
# Arguments:
#   $1 - File path
#   $2 - Pattern (can contain | for multiple patterns)
# Returns:
#   0 if matches, 1 otherwise
#######################################
matches_pattern() {
    local file="$1"
    local patterns="$2"
    
    IFS='|' read -ra pattern_array <<< "$patterns"
    for pattern in "${pattern_array[@]}"; do
        case "$file" in
            $pattern) return 0 ;;
        esac
    done
    return 1
}

#######################################
# Get steps to skip for a profile
# Arguments:
#   $1 - Profile name
# Returns:
#   Comma-separated list of step numbers to skip
#######################################
get_skip_steps() {
    local profile="${1:-$WORKFLOW_PROFILE}"
    local profile_data="${WORKFLOW_PROFILES[$profile]:-}"
    
    if [[ -z "$profile_data" ]]; then
        echo ""
        return 1
    fi
    
    # Extract skip_steps (2nd field, after description)
    echo "$profile_data" | cut -d'|' -f2
}

#######################################
# Get steps to focus on for a profile
# Arguments:
#   $1 - Profile name
# Returns:
#   Comma-separated list of step numbers to focus on
#######################################
get_focus_steps() {
    local profile="${1:-$WORKFLOW_PROFILE}"
    local profile_data="${WORKFLOW_PROFILES[$profile]:-}"
    
    if [[ -z "$profile_data" ]]; then
        echo "all"
        return 1
    fi
    
    # Extract focus_steps (3rd field)
    echo "$profile_data" | cut -d'|' -f3
}

#######################################
# Get estimated time for a profile
# Arguments:
#   $1 - Profile name
# Returns:
#   Estimated time string
#######################################
get_estimated_time() {
    local profile="${1:-$WORKFLOW_PROFILE}"
    local profile_data="${WORKFLOW_PROFILES[$profile]:-}"
    
    if [[ -z "$profile_data" ]]; then
        echo "unknown"
        return 1
    fi
    
    # Extract estimated_time (4th field)
    echo "$profile_data" | cut -d'|' -f4
}

#######################################
# Get profile description
# Arguments:
#   $1 - Profile name
# Returns:
#   Description string
#######################################
get_profile_description() {
    local profile="${1:-$WORKFLOW_PROFILE}"
    local profile_data="${WORKFLOW_PROFILES[$profile]:-}"
    
    if [[ -z "$profile_data" ]]; then
        echo "Unknown profile"
        return 1
    fi
    
    # Extract description (1st field)
    echo "$profile_data" | cut -d'|' -f1
}

#######################################
# Check if step should be skipped based on profile
# Arguments:
#   $1 - Step number
# Returns:
#   0 if should skip, 1 if should run
#######################################
should_skip_step() {
    local step_num="$1"
    local skip_steps
    
    skip_steps=$(get_skip_steps)
    
    # If no skip steps or "none", don't skip anything
    [[ -z "$skip_steps" || "$skip_steps" == "none" ]] && return 1
    
    # Check if step is in skip list
    IFS=',' read -ra skip_array <<< "$skip_steps"
    for skip in "${skip_array[@]}"; do
        [[ "$step_num" == "$skip" ]] && return 0
    done
    
    return 1
}

#######################################
# Display profile information
# Arguments:
#   $1 - Profile name (optional, uses WORKFLOW_PROFILE if not set)
# Returns:
#   None
#######################################
display_profile_info() {
    local profile="${1:-$WORKFLOW_PROFILE}"
    local description skip_steps focus_steps estimated_time
    
    description=$(get_profile_description "$profile")
    skip_steps=$(get_skip_steps "$profile")
    focus_steps=$(get_focus_steps "$profile")
    estimated_time=$(get_estimated_time "$profile")
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              WORKFLOW PROFILE: $profile"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Description: $description"
    echo "Estimated Time: $estimated_time"
    echo ""
    echo "Steps to Skip: ${skip_steps:-none}"
    echo "Focus Steps: ${focus_steps:-all}"
    echo ""
}

#######################################
# List all available profiles
# Returns:
#   None
#######################################
list_profiles() {
    echo "Available Workflow Profiles:"
    echo ""
    
    for profile in "${!WORKFLOW_PROFILES[@]}"; do
        local description time
        description=$(get_profile_description "$profile")
        time=$(get_estimated_time "$profile")
        
        printf "  %-20s %s (est. %s)\n" "$profile" "$description" "$time"
    done
    echo ""
}

#######################################
# Calculate time savings vs full validation
# Arguments:
#   $1 - Profile name
# Returns:
#   Savings percentage
#######################################
calculate_savings() {
    local profile="$1"
    local full_time_min=25  # Average time for full validation
    
    case "$profile" in
        docs_only)
            echo "60%"  # ~10 minutes saved
            ;;
        code_changes)
            echo "20%"  # ~5 minutes saved
            ;;
        test_changes)
            echo "35%"  # ~8 minutes saved
            ;;
        infrastructure)
            echo "0%"   # Full validation needed
            ;;
        full_validation)
            echo "0%"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

#######################################
# Log helper functions
#######################################
log_info() {
    echo "[INFO] $*" >&2
}

log_warning() {
    echo "[WARNING] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Export functions
export -f detect_workflow_profile
export -f get_changed_files
export -f matches_pattern
export -f get_skip_steps
export -f get_focus_steps
export -f get_estimated_time
export -f get_profile_description
export -f should_skip_step
export -f display_profile_info
export -f list_profiles
export -f calculate_savings
