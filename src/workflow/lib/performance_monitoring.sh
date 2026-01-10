#!/bin/bash
set -euo pipefail

################################################################################
# Performance Monitoring and Thresholds Module
# Version: 2.7.0
# Purpose: Real-time performance monitoring with threshold alerts
#
# Features:
#   - Step duration thresholds
#   - Workflow duration limits
#   - API timeout management
#   - Real-time alerts
#   - Performance trending
#   - Auto-remediation suggestions
#
# Performance Target: Prevent workflow slowdowns, detect anomalies
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# ==============================================================================
# THRESHOLD CONFIGURATION
# ==============================================================================

# Step duration threshold (seconds) - warn if exceeded
STEP_DURATION_THRESHOLD=${STEP_DURATION_THRESHOLD:-300}  # 5 minutes default

# Workflow duration threshold (seconds) - fail if exceeded
WORKFLOW_DURATION_THRESHOLD=${WORKFLOW_DURATION_THRESHOLD:-600}  # 10 minutes default

# Copilot API timeout (seconds)
COPILOT_API_TIMEOUT=${COPILOT_API_TIMEOUT:-120}  # 2 minutes default

# Critical threshold multiplier (fail at this level)
CRITICAL_THRESHOLD_MULTIPLIER=2.0

# ==============================================================================
# THRESHOLD TRACKING
# ==============================================================================

# Track threshold violations
declare -A THRESHOLD_VIOLATIONS
THRESHOLD_VIOLATIONS=(
    [step_warnings]=0
    [step_failures]=0
    [workflow_warnings]=0
    [workflow_failures]=0
    [api_timeouts]=0
)

# Track step-level violations
declare -A STEP_VIOLATIONS

# ==============================================================================
# STEP DURATION MONITORING
# ==============================================================================

# Check if step duration exceeds threshold
# Args: $1 = step_number, $2 = duration_seconds
# Returns: 0 if OK, 1 if warning, 2 if critical
check_step_duration_threshold() {
    local step="$1"
    local duration="$2"
    
    local threshold=${STEP_DURATION_THRESHOLD}
    local critical_threshold=$(echo "$threshold * $CRITICAL_THRESHOLD_MULTIPLIER" | bc)
    
    if (( $(echo "$duration >= $critical_threshold" | bc -l) )); then
        # Critical - exceeds 2x threshold
        ((THRESHOLD_VIOLATIONS[step_failures]++)) || true
        STEP_VIOLATIONS[$step]="CRITICAL"
        return 2
    elif (( $(echo "$duration >= $threshold" | bc -l) )); then
        # Warning - exceeds threshold
        ((THRESHOLD_VIOLATIONS[step_warnings]++)) || true
        STEP_VIOLATIONS[$step]="WARNING"
        return 1
    else
        # OK
        STEP_VIOLATIONS[$step]="OK"
        return 0
    fi
}

# Report step duration threshold violation
# Args: $1 = step_number, $2 = duration_seconds, $3 = severity (WARNING/CRITICAL)
report_step_threshold_violation() {
    local step="$1"
    local duration="$2"
    local severity="$3"
    local threshold=${STEP_DURATION_THRESHOLD}
    
    local step_name=$(get_step_name "$step" 2>/dev/null || echo "Step $step")
    local duration_min=$(echo "$duration / 60" | bc)
    local threshold_min=$(echo "$threshold / 60" | bc)
    
    if [[ "$severity" == "CRITICAL" ]]; then
        print_error "⚠️  CRITICAL: $step_name took ${duration_min}m (threshold: ${threshold_min}m)"
        print_error "   This is significantly slower than expected!"
        
        # Log to workflow
        if type -t log_to_workflow > /dev/null; then
            log_to_workflow "ERROR" "Step $step exceeded critical threshold: ${duration}s > ${threshold}s"
        fi
        
        # Suggest remediation
        suggest_step_remediation "$step" "$duration"
        
    elif [[ "$severity" == "WARNING" ]]; then
        print_warning "⚠️  WARNING: $step_name took ${duration_min}m (threshold: ${threshold_min}m)"
        print_warning "   Consider investigating why this step is slow."
        
        # Log to workflow
        if type -t log_to_workflow > /dev/null; then
            log_to_workflow "WARN" "Step $step exceeded threshold: ${duration}s > ${threshold}s"
        fi
    fi
}

# ==============================================================================
# WORKFLOW DURATION MONITORING
# ==============================================================================

# Check if workflow duration exceeds threshold
# Args: $1 = duration_seconds
# Returns: 0 if OK, 1 if warning, 2 if critical (should fail)
check_workflow_duration_threshold() {
    local duration="$1"
    local threshold=${WORKFLOW_DURATION_THRESHOLD}
    
    if (( $(echo "$duration >= $threshold" | bc -l) )); then
        # Critical - workflow should fail
        ((THRESHOLD_VIOLATIONS[workflow_failures]++)) || true
        return 2
    elif (( $(echo "$duration >= $threshold * 0.8" | bc -l) )); then
        # Warning - approaching threshold
        ((THRESHOLD_VIOLATIONS[workflow_warnings]++)) || true
        return 1
    else
        # OK
        return 0
    fi
}

# Report workflow duration threshold violation
# Args: $1 = duration_seconds, $2 = severity (WARNING/CRITICAL)
report_workflow_threshold_violation() {
    local duration="$1"
    local severity="$2"
    local threshold=${WORKFLOW_DURATION_THRESHOLD}
    
    local duration_min=$(echo "$duration / 60" | bc)
    local threshold_min=$(echo "$threshold / 60" | bc)
    
    if [[ "$severity" == "CRITICAL" ]]; then
        print_error "🚨 WORKFLOW FAILURE: Total duration ${duration_min}m exceeds threshold ${threshold_min}m"
        print_error "   Workflow is taking too long - aborting!"
        
        # Log to workflow
        if type -t log_to_workflow > /dev/null; then
            log_to_workflow "ERROR" "Workflow exceeded critical threshold: ${duration}s > ${threshold}s"
        fi
        
        return 1  # Signal failure
        
    elif [[ "$severity" == "WARNING" ]]; then
        print_warning "⏱️  WARNING: Workflow duration ${duration_min}m approaching threshold ${threshold_min}m"
        print_warning "   Consider optimizing workflow to avoid timeout."
    fi
    
    return 0
}

# ==============================================================================
# API TIMEOUT MANAGEMENT
# ==============================================================================

# Execute command with Copilot API timeout
# Args: $1 = command, $2 = description
# Returns: 0 on success, 1 on timeout/failure
execute_with_api_timeout() {
    local command="$1"
    local description="${2:-API call}"
    local timeout=${COPILOT_API_TIMEOUT}
    
    print_info "Executing: $description (timeout: ${timeout}s)"
    
    local start_time=$(date +%s)
    
    # Execute with timeout
    if timeout "${timeout}s" bash -c "$command" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        print_success "✓ $description completed in ${duration}s"
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $exit_code -eq 124 ]]; then
            # Timeout
            ((THRESHOLD_VIOLATIONS[api_timeouts]++)) || true
            print_error "⏰ TIMEOUT: $description exceeded ${timeout}s"
            
            # Log to workflow
            if type -t log_to_workflow > /dev/null; then
                log_to_workflow "ERROR" "API timeout: $description exceeded ${timeout}s"
            fi
            
            # Suggest remediation
            suggest_api_timeout_remediation "$description"
        else
            # Other failure
            print_error "❌ FAILED: $description (exit code: $exit_code)"
        fi
        
        return 1
    fi
}

# ==============================================================================
# REAL-TIME MONITORING
# ==============================================================================

# Monitor step execution in real-time
# Args: $1 = step_number
# Returns: Monitoring report
monitor_step_execution() {
    local step="$1"
    local start_time=${STEP_START_TIMES[$step]:-0}
    
    [[ $start_time -eq 0 ]] && return 0
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local threshold=${STEP_DURATION_THRESHOLD}
    local progress=$((elapsed * 100 / threshold))
    
    # Real-time status display
    if [[ $progress -lt 50 ]]; then
        echo "⏱️  ${elapsed}s elapsed (${progress}% of threshold)"
    elif [[ $progress -lt 80 ]]; then
        echo "⚠️  ${elapsed}s elapsed (${progress}% of threshold - approaching limit)"
    elif [[ $progress -lt 100 ]]; then
        echo "🚨 ${elapsed}s elapsed (${progress}% of threshold - CLOSE TO LIMIT!)"
    else
        echo "❌ ${elapsed}s elapsed (EXCEEDED threshold by $((progress - 100))%)"
    fi
}

# Monitor overall workflow progress
# Returns: Progress report
monitor_workflow_progress() {
    local start_time=${WORKFLOW_START_EPOCH:-0}
    [[ $start_time -eq 0 ]] && return 0
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local threshold=${WORKFLOW_DURATION_THRESHOLD}
    local progress=$((elapsed * 100 / threshold))
    
    local elapsed_min=$((elapsed / 60))
    local threshold_min=$((threshold / 60))
    
    print_header "Workflow Progress"
    echo "Time elapsed: ${elapsed_min}m / ${threshold_min}m (${progress}%)"
    
    if [[ $progress -lt 50 ]]; then
        print_success "✓ On track"
    elif [[ $progress -lt 80 ]]; then
        print_info "⚠️  Approaching threshold"
    elif [[ $progress -lt 100 ]]; then
        print_warning "🚨 Close to timeout - ${threshold_min}m limit"
    else
        print_error "❌ EXCEEDED threshold!"
        return 1
    fi
}

# ==============================================================================
# PERFORMANCE TRENDING
# ==============================================================================

# Analyze performance trends
# Args: $1 = step_number (optional, blank for workflow)
# Returns: Trend analysis
analyze_performance_trend() {
    local step="${1:-}"
    
    if [[ -z "$step" ]]; then
        # Workflow-level trend
        analyze_workflow_trend
    else
        # Step-level trend
        analyze_step_trend "$step"
    fi
}

# Analyze workflow performance trend
analyze_workflow_trend() {
    if ! type -t get_recent_runs > /dev/null; then
        echo "Metrics system not available"
        return 1
    fi
    
    local recent_runs=$(get_recent_runs 5 2>/dev/null || echo "")
    [[ -z "$recent_runs" ]] && return 0
    
    local durations=()
    while IFS= read -r run; do
        local duration=$(echo "$run" | jq -r '.duration_seconds // 0')
        durations+=("$duration")
    done <<< "$recent_runs"
    
    [[ ${#durations[@]} -lt 2 ]] && return 0
    
    # Calculate trend
    local first=${durations[0]}
    local last=${durations[-1]}
    
    if [[ $last -gt $first ]]; then
        local increase=$(echo "($last - $first) * 100 / $first" | bc)
        print_warning "📈 Performance degrading: +${increase}% slower than baseline"
        echo "   Recent durations: ${durations[*]}"
    elif [[ $last -lt $first ]]; then
        local decrease=$(echo "($first - $last) * 100 / $first" | bc)
        print_success "📉 Performance improving: ${decrease}% faster than baseline"
    else
        print_info "➡️  Performance stable"
    fi
}

# Analyze step performance trend
# Args: $1 = step_number
analyze_step_trend() {
    local step="$1"
    
    # Get historical data for this step
    if type -t get_step_average_duration > /dev/null; then
        local avg_duration=$(get_step_average_duration "$step" 2>/dev/null || echo "0")
        local current_duration=${STEP_DURATIONS[$step]:-0}
        
        if [[ $avg_duration -gt 0 ]] && [[ $current_duration -gt 0 ]]; then
            local variance=$(echo "($current_duration - $avg_duration) * 100 / $avg_duration" | bc)
            
            if [[ $variance -gt 20 ]]; then
                print_warning "Step $step is ${variance}% slower than average (${avg_duration}s)"
            elif [[ $variance -lt -20 ]]; then
                print_success "Step $step is ${variance#-}% faster than average!"
            fi
        fi
    fi
}

# ==============================================================================
# REMEDIATION SUGGESTIONS
# ==============================================================================

# Suggest remediation for slow step
# Args: $1 = step_number, $2 = duration_seconds
suggest_step_remediation() {
    local step="$1"
    local duration="$2"
    
    echo ""
    print_header "Performance Remediation Suggestions"
    
    case "$step" in
        1)
            echo "📝 Step 1 (Documentation Update) is slow:"
            echo "  • Consider using --smart-execution to skip unchanged docs"
            echo "  • Enable caching: export USE_ANALYSIS_CACHE=true"
            echo "  • Check if AI response caching is enabled"
            ;;
        7)
            echo "🧪 Step 7 (Test Execution) is slow:"
            echo "  • Use incremental test execution"
            echo "  • Enable test sharding (4-way parallel)"
            echo "  • Check if tests have unnecessary delays/timeouts"
            ;;
        9)
            echo "🔍 Step 9 (Code Quality) is slow:"
            echo "  • Use smart code quality checks (changed files only)"
            echo "  • Enable quality cache"
            echo "  • Consider running linters in parallel"
            ;;
        *)
            echo "Step $step exceeded threshold:"
            echo "  • Review step implementation for optimization opportunities"
            echo "  • Check if caching is enabled and working"
            echo "  • Consider parallelization if step is independent"
            ;;
    esac
    
    echo ""
}

# Suggest remediation for API timeout
# Args: $1 = description
suggest_api_timeout_remediation() {
    local description="$1"
    
    echo ""
    print_header "API Timeout Remediation"
    echo "API call timed out: $description"
    echo ""
    echo "Suggestions:"
    echo "  • Increase timeout: export COPILOT_API_TIMEOUT=180"
    echo "  • Check network connectivity"
    echo "  • Reduce prompt size/complexity"
    echo "  • Enable AI response caching"
    echo ""
}

# ==============================================================================
# THRESHOLD REPORTING
# ==============================================================================

# Display threshold violations summary
display_threshold_violations() {
    local step_warnings=${THRESHOLD_VIOLATIONS[step_warnings]:-0}
    local step_failures=${THRESHOLD_VIOLATIONS[step_failures]:-0}
    local workflow_warnings=${THRESHOLD_VIOLATIONS[workflow_warnings]:-0}
    local workflow_failures=${THRESHOLD_VIOLATIONS[workflow_failures]:-0}
    local api_timeouts=${THRESHOLD_VIOLATIONS[api_timeouts]:-0}
    
    local total=$((step_warnings + step_failures + workflow_warnings + workflow_failures + api_timeouts))
    
    [[ $total -eq 0 ]] && return 0
    
    print_header "Performance Threshold Violations"
    
    [[ $step_warnings -gt 0 ]] && print_warning "Step warnings: $step_warnings"
    [[ $step_failures -gt 0 ]] && print_error "Step failures: $step_failures"
    [[ $workflow_warnings -gt 0 ]] && print_warning "Workflow warnings: $workflow_warnings"
    [[ $workflow_failures -gt 0 ]] && print_error "Workflow failures: $workflow_failures"
    [[ $api_timeouts -gt 0 ]] && print_error "API timeouts: $api_timeouts"
    
    echo ""
    print_info "Total violations: $total"
    
    # Show step-level details
    if [[ ${#STEP_VIOLATIONS[@]} -gt 0 ]]; then
        echo ""
        print_info "Step-level violations:"
        for step in "${!STEP_VIOLATIONS[@]}"; do
            local status="${STEP_VIOLATIONS[$step]}"
            [[ "$status" == "OK" ]] && continue
            
            local step_name=$(get_step_name "$step" 2>/dev/null || echo "Step $step")
            local duration=${STEP_DURATIONS[$step]:-0}
            local duration_min=$((duration / 60))
            
            if [[ "$status" == "CRITICAL" ]]; then
                print_error "  • $step_name: $status (${duration_min}m)"
            else
                print_warning "  • $step_name: $status (${duration_min}m)"
            fi
        done
    fi
}

# ==============================================================================
# CONFIGURATION HELPERS
# ==============================================================================

# Set custom step duration threshold
# Args: $1 = threshold_seconds
set_step_duration_threshold() {
    local threshold="$1"
    export STEP_DURATION_THRESHOLD=$threshold
    print_info "Step duration threshold set to ${threshold}s ($(($threshold / 60))m)"
}

# Set custom workflow duration threshold
# Args: $1 = threshold_seconds
set_workflow_duration_threshold() {
    local threshold="$1"
    export WORKFLOW_DURATION_THRESHOLD=$threshold
    print_info "Workflow duration threshold set to ${threshold}s ($(($threshold / 60))m)"
}

# Set custom API timeout
# Args: $1 = timeout_seconds
set_api_timeout() {
    local timeout="$1"
    export COPILOT_API_TIMEOUT=$timeout
    print_info "Copilot API timeout set to ${timeout}s"
}

# Display current threshold configuration
display_threshold_config() {
    print_header "Performance Thresholds Configuration"
    echo "Step duration threshold:     ${STEP_DURATION_THRESHOLD}s ($(($STEP_DURATION_THRESHOLD / 60))m)"
    echo "Workflow duration threshold: ${WORKFLOW_DURATION_THRESHOLD}s ($(($WORKFLOW_DURATION_THRESHOLD / 60))m)"
    echo "Copilot API timeout:         ${COPILOT_API_TIMEOUT}s ($(($COPILOT_API_TIMEOUT / 60))m)"
    echo ""
    echo "Critical multiplier: ${CRITICAL_THRESHOLD_MULTIPLIER}x"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f check_step_duration_threshold
export -f report_step_threshold_violation
export -f check_workflow_duration_threshold
export -f report_workflow_threshold_violation
export -f execute_with_api_timeout
export -f monitor_step_execution
export -f monitor_workflow_progress
export -f analyze_performance_trend
export -f analyze_workflow_trend
export -f analyze_step_trend
export -f suggest_step_remediation
export -f suggest_api_timeout_remediation
export -f display_threshold_violations
export -f set_step_duration_threshold
export -f set_workflow_duration_threshold
export -f set_api_timeout
export -f display_threshold_config

################################################################################
# End of Performance Monitoring Module
################################################################################
