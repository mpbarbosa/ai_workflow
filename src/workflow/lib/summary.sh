#!/bin/bash
set -euo pipefail

################################################################################
# Summary Generation Module
# Purpose: Helper functions for generating step-level summaries
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# STEP SUMMARY HELPERS
# ==============================================================================

# Determine step status icon based on findings
# Usage: determine_step_status <issues_found> <warnings_found>
# Returns: ✅ (success), ⚠️ (warnings), or ❌ (errors)
determine_step_status() {
    local issues_found="${1:-0}"
    local warnings_found="${2:-0}"
    
    if [[ "$issues_found" -gt 0 ]]; then
        echo "❌"
    elif [[ "$warnings_found" -gt 0 ]]; then
        echo "⚠️"
    else
        echo "✅"
    fi
}

# Format summary content with consistent structure
# Usage: format_step_summary <step_name> <summary_text>
format_step_summary() {
    local step_name="$1"
    local summary_text="$2"
    
    cat << EOF
**Step:** ${step_name}
**Status:** Completed
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')

## Summary

${summary_text}

---
EOF
}

# Create a concise one-line summary for progress tracking
# Usage: create_progress_summary <step_num> <step_name> <status>
create_progress_summary() {
    local step_num="$1"
    local step_name="$2"
    local status="$3"
    
    printf "[Step %2d] %-40s %s\n" "$step_num" "$step_name" "$status"
}

# Generate summary statistics from step execution
# Usage: generate_step_stats <files_checked> <issues_found> <warnings_found>
generate_step_stats() {
    local files_checked="${1:-0}"
    local issues_found="${2:-0}"
    local warnings_found="${3:-0}"
    
    cat << EOF
**Files Checked:** ${files_checked}
**Issues Found:** ${issues_found}
**Warnings:** ${warnings_found}
**Pass Rate:** $(( files_checked > 0 ? (files_checked - issues_found) * 100 / files_checked : 100 ))%
EOF
}

# Create a summary badge/indicator
# Usage: create_summary_badge <status>
create_summary_badge() {
    local status="$1"
    
    case "$status" in
        "✅"|"success")
            echo "![Success](https://img.shields.io/badge/status-success-brightgreen)"
            ;;
        "⚠️"|"warning")
            echo "![Warning](https://img.shields.io/badge/status-warning-yellow)"
            ;;
        "❌"|"error")
            echo "![Error](https://img.shields.io/badge/status-error-red)"
            ;;
        *)
            echo "![Unknown](https://img.shields.io/badge/status-unknown-lightgrey)"
            ;;
    esac
}

# Aggregate summaries from multiple steps
# Usage: aggregate_summaries <step_files...>
aggregate_summaries() {
    local total_steps=0
    local successful_steps=0
    local warning_steps=0
    local failed_steps=0
    
    for summary_file in "$@"; do
        if [[ -f "$summary_file" ]]; then
            ((total_steps++))
            
            if grep -q "✅" "$summary_file"; then
                ((successful_steps++))
            elif grep -q "⚠️" "$summary_file"; then
                ((warning_steps++))
            elif grep -q "❌" "$summary_file"; then
                ((failed_steps++))
            fi
        fi
    done
    
    cat << EOF
## Aggregated Results

- **Total Steps:** ${total_steps}
- **Successful:** ${successful_steps} ✅
- **Warnings:** ${warning_steps} ⚠️
- **Failed:** ${failed_steps} ❌
- **Success Rate:** $(( total_steps > 0 ? successful_steps * 100 / total_steps : 0 ))%
EOF
}

# Export all summary functions
export -f determine_step_status
export -f format_step_summary
export -f create_progress_summary
export -f generate_step_stats
export -f create_summary_badge
export -f aggregate_summaries
