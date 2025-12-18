#!/bin/bash
################################################################################
# Workflow Metrics Collection Module
# Purpose: Track duration, success rate, and step timing for workflow automation
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Created: December 18, 2025
################################################################################

# ==============================================================================
# METRICS STORAGE
# ==============================================================================

# Metrics directory structure
METRICS_DIR="${PROJECT_ROOT}/shell_scripts/workflow/metrics"
METRICS_CURRENT="${METRICS_DIR}/current_run.json"
METRICS_HISTORY="${METRICS_DIR}/history.jsonl"  # JSON Lines format for append-only history
METRICS_SUMMARY="${METRICS_DIR}/summary.md"

# Step timing tracking
declare -A STEP_START_TIMES
declare -A STEP_END_TIMES
declare -A STEP_DURATIONS
declare -A STEP_STATUSES

# Workflow-level metrics
WORKFLOW_START_EPOCH=0
WORKFLOW_END_EPOCH=0
WORKFLOW_DURATION=0
WORKFLOW_SUCCESS=false
WORKFLOW_STEPS_COMPLETED=0
WORKFLOW_STEPS_FAILED=0
WORKFLOW_STEPS_SKIPPED=0

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize metrics collection
# Creates necessary directories and files
init_metrics() {
    # Create metrics directory if it doesn't exist
    mkdir -p "${METRICS_DIR}"
    
    # Initialize current run file
    cat > "${METRICS_CURRENT}" << EOF
{
  "workflow_run_id": "${WORKFLOW_RUN_ID}",
  "start_time": "$(date -Iseconds)",
  "start_epoch": $(date +%s),
  "version": "${SCRIPT_VERSION}",
  "mode": "$(get_execution_mode)",
  "steps": {}
}
EOF
    
    # Initialize history file if it doesn't exist
    if [[ ! -f "${METRICS_HISTORY}" ]]; then
        touch "${METRICS_HISTORY}"
    fi
    
    WORKFLOW_START_EPOCH=$(date +%s)
}

# Get current execution mode as string
get_execution_mode() {
    if [[ "${DRY_RUN}" == true ]]; then
        echo "dry-run"
    elif [[ "${AUTO_MODE}" == true ]]; then
        echo "auto"
    elif [[ "${INTERACTIVE_MODE}" == true ]]; then
        echo "interactive"
    else
        echo "unknown"
    fi
}

# ==============================================================================
# STEP TIMING
# ==============================================================================

# Start timing for a step
# Usage: start_step_timer <step_number> <step_name>
start_step_timer() {
    local step_num="$1"
    local step_name="$2"
    
    STEP_START_TIMES["${step_num}"]=$(date +%s)
    
    # Update current run JSON
    update_current_run_step "${step_num}" "${step_name}" "running" "" ""
}

# Stop timing for a step
# Usage: stop_step_timer <step_number> <status> [error_message]
stop_step_timer() {
    local step_num="$1"
    local status="$2"  # success, failed, skipped
    local error_msg="${3:-}"
    
    STEP_END_TIMES["${step_num}"]=$(date +%s)
    STEP_STATUSES["${step_num}"]="${status}"
    
    # Calculate duration
    local start_time="${STEP_START_TIMES[${step_num}]:-0}"
    local end_time="${STEP_END_TIMES[${step_num}]:-0}"
    local duration=$((end_time - start_time))
    STEP_DURATIONS["${step_num}"]=${duration}
    
    # Update counters
    case "${status}" in
        success)
            ((WORKFLOW_STEPS_COMPLETED++))
            ;;
        failed)
            ((WORKFLOW_STEPS_FAILED++))
            ;;
        skipped)
            ((WORKFLOW_STEPS_SKIPPED++))
            ;;
    esac
    
    # Get step name from step files
    local step_name=$(get_step_name "${step_num}")
    
    # Update current run JSON
    update_current_run_step "${step_num}" "${step_name}" "${status}" "${duration}" "${error_msg}"
}

# Get step name from step number
get_step_name() {
    local step_num="$1"
    
    case "${step_num}" in
        0) echo "Pre_Analysis" ;;
        1) echo "Documentation_Updates" ;;
        2) echo "Consistency_Analysis" ;;
        3) echo "Script_Reference_Validation" ;;
        4) echo "Directory_Structure_Validation" ;;
        5) echo "Test_Review" ;;
        6) echo "Test_Generation" ;;
        7) echo "Test_Execution" ;;
        8) echo "Dependency_Validation" ;;
        9) echo "Code_Quality_Validation" ;;
        10) echo "Context_Analysis" ;;
        11) echo "Git_Finalization" ;;
        12) echo "Markdown_Linting" ;;
        *) echo "Unknown_Step_${step_num}" ;;
    esac
}

# ==============================================================================
# JSON UPDATES
# ==============================================================================

# Update current run JSON with step information
# Usage: update_current_run_step <step_num> <step_name> <status> <duration> <error_msg>
update_current_run_step() {
    local step_num="$1"
    local step_name="$2"
    local status="$3"
    local duration="${4:-0}"
    local error_msg="${5:-}"
    
    # Create temporary file for jq processing
    local temp_file="${METRICS_CURRENT}.tmp"
    
    # Build step object
    local step_obj=$(cat << EOF
{
  "name": "${step_name}",
  "status": "${status}",
  "start_time": ${STEP_START_TIMES[${step_num}]:-0},
  "end_time": ${STEP_END_TIMES[${step_num}]:-0},
  "duration_seconds": ${duration},
  "timestamp": "$(date -Iseconds)"
}
EOF
    )
    
    # Add error message if present
    if [[ -n "${error_msg}" ]]; then
        step_obj=$(echo "${step_obj}" | jq --arg msg "${error_msg}" '. + {error: $msg}')
    fi
    
    # Update JSON (fallback to manual update if jq not available)
    if command -v jq &> /dev/null; then
        jq --argjson step "${step_obj}" ".steps[\"step_${step_num}\"] = \$step" "${METRICS_CURRENT}" > "${temp_file}" && mv "${temp_file}" "${METRICS_CURRENT}"
    else
        # Manual JSON update without jq
        echo "Warning: jq not found, metrics may be incomplete" >&2
    fi
}

# ==============================================================================
# WORKFLOW FINALIZATION
# ==============================================================================

# Finalize metrics and save to history
# Usage: finalize_metrics [success|failed]
finalize_metrics() {
    local final_status="${1:-failed}"
    
    WORKFLOW_END_EPOCH=$(date +%s)
    WORKFLOW_DURATION=$((WORKFLOW_END_EPOCH - WORKFLOW_START_EPOCH))
    WORKFLOW_SUCCESS=$([[ "${final_status}" == "success" ]] && echo "true" || echo "false")
    
    # Update current run JSON with final metrics
    local temp_file="${METRICS_CURRENT}.tmp"
    
    if command -v jq &> /dev/null; then
        jq --arg status "${final_status}" \
           --argjson duration "${WORKFLOW_DURATION}" \
           --argjson completed "${WORKFLOW_STEPS_COMPLETED}" \
           --argjson failed "${WORKFLOW_STEPS_FAILED}" \
           --argjson skipped "${WORKFLOW_STEPS_SKIPPED}" \
           --argjson success "${WORKFLOW_SUCCESS}" \
           --arg end_time "$(date -Iseconds)" \
           --argjson end_epoch "${WORKFLOW_END_EPOCH}" \
           '. + {
               status: $status,
               end_time: $end_time,
               end_epoch: $end_epoch,
               duration_seconds: $duration,
               steps_completed: $completed,
               steps_failed: $failed,
               steps_skipped: $skipped,
               success: $success
           }' "${METRICS_CURRENT}" > "${temp_file}" && mv "${temp_file}" "${METRICS_CURRENT}"
    fi
    
    # Append to history (JSON Lines format)
    if [[ -f "${METRICS_CURRENT}" ]]; then
        cat "${METRICS_CURRENT}" >> "${METRICS_HISTORY}"
        echo >> "${METRICS_HISTORY}"  # Ensure newline between records
    fi
    
    # Generate summary report
    generate_metrics_summary
}

# ==============================================================================
# METRICS REPORTING
# ==============================================================================

# Generate human-readable metrics summary
generate_metrics_summary() {
    cat > "${METRICS_SUMMARY}" << EOF
# Workflow Metrics Summary

**Last Updated:** $(date '+%Y-%m-%d %H:%M:%S')

## Current Run: ${WORKFLOW_RUN_ID}

- **Status:** $(get_workflow_status_emoji) ${final_status:-unknown}
- **Duration:** $(format_duration ${WORKFLOW_DURATION})
- **Mode:** $(get_execution_mode)
- **Steps Completed:** ${WORKFLOW_STEPS_COMPLETED}
- **Steps Failed:** ${WORKFLOW_STEPS_FAILED}
- **Steps Skipped:** ${WORKFLOW_STEPS_SKIPPED}

## Step Timing Breakdown

| Step | Name | Duration | Status |
|------|------|----------|--------|
$(generate_step_timing_table)

## Historical Performance

$(generate_historical_stats)

---

*Generated by Workflow Metrics Module v2.0.0*
EOF
}

# Get workflow status emoji
get_workflow_status_emoji() {
    if [[ "${WORKFLOW_SUCCESS}" == "true" ]]; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Format duration in human-readable format
# Usage: format_duration <seconds>
format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    if [[ ${hours} -gt 0 ]]; then
        printf "%dh %dm %ds" "${hours}" "${minutes}" "${seconds}"
    elif [[ ${minutes} -gt 0 ]]; then
        printf "%dm %ds" "${minutes}" "${seconds}"
    else
        printf "%ds" "${seconds}"
    fi
}

# Generate step timing table for markdown
generate_step_timing_table() {
    for i in {0..12}; do
        if [[ -n "${STEP_DURATIONS[${i}]:-}" ]]; then
            local step_name=$(get_step_name "${i}")
            local duration=$(format_duration "${STEP_DURATIONS[${i}]}")
            local status="${STEP_STATUSES[${i}]:-unknown}"
            local status_emoji=$(get_step_status_emoji "${status}")
            
            printf "| %2d | %-35s | %10s | %s %s |\n" \
                "${i}" "${step_name}" "${duration}" "${status_emoji}" "${status}"
        fi
    done
}

# Get step status emoji
get_step_status_emoji() {
    local status="$1"
    
    case "${status}" in
        success) echo "✅" ;;
        failed) echo "❌" ;;
        skipped) echo "⏭️" ;;
        running) echo "🔄" ;;
        *) echo "❓" ;;
    esac
}

# Generate historical statistics from past runs
generate_historical_stats() {
    if [[ ! -f "${METRICS_HISTORY}" ]] || [[ ! -s "${METRICS_HISTORY}" ]]; then
        echo "_No historical data available yet._"
        return
    fi
    
    local total_runs=$(grep -c "workflow_run_id" "${METRICS_HISTORY}" 2>/dev/null || echo "0")
    local successful_runs=$(grep -c '"success": *true' "${METRICS_HISTORY}" 2>/dev/null || echo "0")
    local success_rate=0
    
    if [[ ${total_runs} -gt 0 ]]; then
        success_rate=$((successful_runs * 100 / total_runs))
    fi
    
    cat << EOF
- **Total Runs:** ${total_runs}
- **Successful Runs:** ${successful_runs}
- **Success Rate:** ${success_rate}%
- **Average Duration:** $(calculate_average_duration)

### Recent Runs (Last 5)

$(display_recent_runs 5)
EOF
}

# Calculate average duration from history
calculate_average_duration() {
    if [[ ! -f "${METRICS_HISTORY}" ]]; then
        echo "N/A"
        return
    fi
    
    # Extract durations and calculate average (fallback without jq)
    if command -v jq &> /dev/null; then
        local avg=$(jq -s '[.[].duration_seconds] | add / length' "${METRICS_HISTORY}" 2>/dev/null || echo "0")
        format_duration "${avg%.*}"  # Remove decimal part
    else
        echo "N/A (jq required)"
    fi
}

# Display recent workflow runs
display_recent_runs() {
    local count="${1:-5}"
    
    if [[ ! -f "${METRICS_HISTORY}" ]]; then
        echo "_No history available._"
        return
    fi
    
    # Use tail to get last N runs, then parse (basic parsing without jq)
    tail -n "$((count * 2))" "${METRICS_HISTORY}" | grep "workflow_run_id" | while read -r line; do
        echo "- ${line}"
    done
}

# ==============================================================================
# METRICS QUERY API
# ==============================================================================

# Get success rate for last N runs
# Usage: get_success_rate [count]
get_success_rate() {
    local count="${1:-10}"
    
    if [[ ! -f "${METRICS_HISTORY}" ]]; then
        echo "0"
        return
    fi
    
    local recent_runs=$(tail -n "$((count * 2))" "${METRICS_HISTORY}")
    local total=$(echo "${recent_runs}" | grep -c "workflow_run_id" || echo "0")
    local successful=$(echo "${recent_runs}" | grep -c '"success": *true' || echo "0")
    
    if [[ ${total} -gt 0 ]]; then
        echo "$((successful * 100 / total))"
    else
        echo "0"
    fi
}

# Get average step duration across history
# Usage: get_average_step_duration <step_number>
get_average_step_duration() {
    local step_num="$1"
    
    if [[ ! -f "${METRICS_HISTORY}" ]] || ! command -v jq &> /dev/null; then
        echo "N/A"
        return
    fi
    
    local avg=$(jq -s "[.[] | .steps.step_${step_num}.duration_seconds // 0] | add / length" "${METRICS_HISTORY}" 2>/dev/null || echo "0")
    format_duration "${avg%.*}"
}

# Export functions for use in workflow
export -f init_metrics start_step_timer stop_step_timer finalize_metrics
export -f get_success_rate get_average_step_duration generate_metrics_summary
