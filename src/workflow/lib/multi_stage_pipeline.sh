#!/bin/bash
set -euo pipefail

################################################################################
# Multi-Stage Pipeline Module
# Version: 2.7.1
# Purpose: Intelligent pipeline staging with progressive validation
#
# Features:
#   - 3-stage progressive pipeline
#   - Fast validation (2 min)
#   - Targeted checks (5 min)
#   - Full validation (15 min)
#   - Smart stage selection
#   - Manual/auto triggers
#   - Stage-level metrics
#
# Performance Target: 80%+ of runs complete in Stage 1 or 2
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# ==============================================================================
# PIPELINE STAGE DEFINITIONS
# ==============================================================================

# Stage 1: Fast Validation (Target: 2 minutes)
# Purpose: Quick smoke tests and basic validation
declare -a STAGE_FAST_VALIDATION=(0)
STAGE_FAST_VALIDATION_NAME="Fast Validation"
STAGE_FAST_VALIDATION_TARGET=120  # 2 minutes

# Stage 2: Targeted Checks (Target: 5 minutes)
# Purpose: Domain-specific validation (docs, scripts, structure)
declare -a STAGE_TARGETED_CHECKS=(1 2 3 4)
STAGE_TARGETED_CHECKS_NAME="Targeted Checks"
STAGE_TARGETED_CHECKS_TARGET=300  # 5 minutes

# Stage 3: Full Validation (Target: 15 minutes)
# Purpose: Comprehensive code, test, and security validation
declare -a STAGE_FULL_VALIDATION=(5 6 7 8 9 10 11 12 13 14)
STAGE_FULL_VALIDATION_NAME="Full Validation"
STAGE_FULL_VALIDATION_TARGET=900  # 15 minutes

# Stage execution tracking
declare -A STAGE_RESULTS
declare -A STAGE_DURATIONS
declare -A STAGE_STATUS

# ==============================================================================
# STAGE TRIGGERS
# ==============================================================================

# Define when each stage should run
# Format: stage_name:trigger_condition

# Stage 1: Always run (mandatory)
STAGE_1_TRIGGER="always"

# Stage 2: Run if Stage 1 passes AND changes detected
STAGE_2_TRIGGER="stage_1_success AND (docs_changes OR script_changes OR structure_changes)"

# Stage 3: Run if Stage 2 passes AND (manual OR high_impact)
STAGE_3_TRIGGER="stage_2_success AND (manual OR high_impact OR code_changes)"

# ==============================================================================
# TRIGGER EVALUATION
# ==============================================================================

# Check if stage should run based on trigger
# Args: $1 = stage_number
# Returns: 0 if should run, 1 if should skip
should_run_stage() {
    local stage="$1"
    local trigger=""
    
    case "$stage" in
        1)
            trigger="$STAGE_1_TRIGGER"
            ;;
        2)
            trigger="$STAGE_2_TRIGGER"
            ;;
        3)
            trigger="$STAGE_3_TRIGGER"
            ;;
        *)
            return 1
            ;;
    esac
    
    evaluate_stage_trigger "$trigger" "$stage"
}

# Evaluate stage trigger condition
# Args: $1 = trigger_expression, $2 = stage_number
# Returns: 0 if trigger met, 1 otherwise
evaluate_stage_trigger() {
    local trigger="$1"
    local stage="$2"
    
    # Always run
    [[ "$trigger" == "always" ]] && return 0
    
    # Never run
    [[ "$trigger" == "never" ]] && return 1
    
    # Parse complex trigger
    # Support: AND, OR, NOT, parentheses
    
    # Handle AND conditions
    if [[ "$trigger" =~ AND ]]; then
        # Split on AND and evaluate all conditions
        local IFS=' AND '
        local conditions=($trigger)
        
        for condition in "${conditions[@]}"; do
            condition=$(echo "$condition" | xargs)  # Trim whitespace
            
            if ! evaluate_single_trigger "$condition" "$stage"; then
                return 1  # Any false -> whole AND is false
            fi
        done
        return 0  # All true -> AND is true
    fi
    
    # Handle OR conditions
    if [[ "$trigger" =~ OR ]]; then
        local IFS=' OR '
        local conditions=($trigger)
        
        for condition in "${conditions[@]}"; do
            condition=$(echo "$condition" | xargs)
            
            if evaluate_single_trigger "$condition" "$stage"; then
                return 0  # Any true -> whole OR is true
            fi
        done
        return 1  # All false -> OR is false
    fi
    
    # Single condition
    evaluate_single_trigger "$trigger" "$stage"
}

# Evaluate single trigger condition
# Args: $1 = condition, $2 = stage_number
# Returns: 0 if true, 1 if false
evaluate_single_trigger() {
    local condition="$1"
    local stage="$2"
    
    # Remove parentheses if present
    condition=$(echo "$condition" | tr -d '()')
    
    case "$condition" in
        "always")
            return 0
            ;;
        "never")
            return 1
            ;;
        "manual")
            # Check if manual trigger flag is set
            [[ "${MANUAL_TRIGGER:-false}" == "true" ]]
            return $?
            ;;
        "high_impact")
            # Check if changes are high impact
            is_high_impact_change
            return $?
            ;;
        "docs_changes")
            # Check if documentation changed
            has_docs_changes
            return $?
            ;;
        "script_changes")
            # Check if scripts changed
            has_script_changes
            return $?
            ;;
        "structure_changes")
            # Check if directory structure changed
            has_structure_changes
            return $?
            ;;
        "code_changes")
            # Check if source code changed
            has_code_changes
            return $?
            ;;
        stage_*_success)
            # Check if previous stage succeeded
            local prev_stage=$(echo "$condition" | grep -oP 'stage_\K\d+')
            [[ "${STAGE_STATUS[$prev_stage]:-}" == "success" ]]
            return $?
            ;;
        *)
            # Unknown condition - default to true (safe)
            return 0
            ;;
    esac
}

# ==============================================================================
# CHANGE DETECTION HELPERS
# ==============================================================================

# Check if changes are high impact
# Returns: 0 if high impact, 1 otherwise
is_high_impact_change() {
    # High impact if:
    # - Core library files changed
    # - Configuration files changed
    # - Security-sensitive files changed
    # - More than 10 files changed
    
    local modified=$(get_modified_files 2>/dev/null || echo "")
    [[ -z "$modified" ]] && return 1
    
    local count=$(echo "$modified" | wc -l)
    [[ $count -gt 10 ]] && return 0
    
    # Check for high-impact patterns
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        case "$file" in
            src/workflow/lib/*|src/workflow/steps/*|src/workflow/execute_tests_docs_workflow.sh)
                return 0  # Core workflow files
                ;;
            *config*.yaml|*config*.json|.workflow-config.yaml)
                return 0  # Configuration files
                ;;
            *auth*|*secret*|*password*|*token*)
                return 0  # Security-sensitive
                ;;
        esac
    done <<< "$modified"
    
    return 1
}

# Check if documentation changed
has_docs_changes() {
    modified_files_contain "docs/" || modified_files_contain "*.md"
}

# Check if scripts changed
has_script_changes() {
    modified_files_contain "*.sh"
}

# Check if directory structure changed
has_structure_changes() {
    local new_dirs=$(get_new_dirs_count 2>/dev/null || echo "0")
    local deleted_dirs=$(get_deleted_dirs_count 2>/dev/null || echo "0")
    
    [[ $new_dirs -gt 0 ]] || [[ $deleted_dirs -gt 0 ]]
}

# Check if source code changed
has_code_changes() {
    modified_files_contain "src/" || modified_files_contain "lib/" || modified_files_contain "*.js" || modified_files_contain "*.ts"
}

# ==============================================================================
# STAGE EXECUTION
# ==============================================================================

# Execute a pipeline stage
# Args: $1 = stage_number
# Returns: 0 on success, 1 on failure
execute_stage() {
    local stage="$1"
    
    # Get stage configuration
    local stage_name=""
    local stage_steps=()
    local stage_target=0
    
    case "$stage" in
        1)
            stage_name="$STAGE_FAST_VALIDATION_NAME"
            stage_steps=("${STAGE_FAST_VALIDATION[@]}")
            stage_target=$STAGE_FAST_VALIDATION_TARGET
            ;;
        2)
            stage_name="$STAGE_TARGETED_CHECKS_NAME"
            stage_steps=("${STAGE_TARGETED_CHECKS[@]}")
            stage_target=$STAGE_TARGETED_CHECKS_TARGET
            ;;
        3)
            stage_name="$STAGE_FULL_VALIDATION_NAME"
            stage_steps=("${STAGE_FULL_VALIDATION[@]}")
            stage_target=$STAGE_FULL_VALIDATION_TARGET
            ;;
        *)
            print_error "Unknown stage: $stage"
            return 1
            ;;
    esac
    
    # Display stage header
    print_stage_header "$stage" "$stage_name" "$stage_target"
    
    local start_time=$(date +%s)
    local stage_success=true
    
    # Execute each step in stage
    for step in "${stage_steps[@]}"; do
        if ! execute_step "$step"; then
            stage_success=false
            print_error "Step $step failed in stage $stage"
            
            # Decide if we should continue or abort
            if [[ "${FAIL_FAST:-false}" == "true" ]]; then
                break
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Record stage results
    STAGE_DURATIONS[$stage]=$duration
    
    if [[ "$stage_success" == "true" ]]; then
        STAGE_STATUS[$stage]="success"
        STAGE_RESULTS[$stage]="✅ PASSED"
        
        # Check if stage met target time
        if [[ $duration -le $stage_target ]]; then
            print_success "✅ Stage $stage completed in ${duration}s (target: ${stage_target}s)"
        else
            local overage=$((duration - stage_target))
            print_warning "⚠️  Stage $stage completed in ${duration}s (${overage}s over target)"
        fi
        
        return 0
    else
        STAGE_STATUS[$stage]="failure"
        STAGE_RESULTS[$stage]="❌ FAILED"
        print_error "❌ Stage $stage failed after ${duration}s"
        return 1
    fi
}

# ==============================================================================
# PIPELINE ORCHESTRATION
# ==============================================================================

# Execute multi-stage pipeline
# Returns: 0 on success, 1 on failure
execute_pipeline() {
    print_header "Multi-Stage Pipeline Execution"
    
    # Stage 1: Fast Validation (always runs)
    if should_run_stage 1; then
        if ! execute_stage 1; then
            print_error "Pipeline failed at Stage 1 (Fast Validation)"
            display_pipeline_summary
            return 1
        fi
    else
        print_info "Stage 1 skipped (should never happen)"
    fi
    
    # Stage 2: Targeted Checks (conditional)
    if should_run_stage 2; then
        print_info "Stage 2 triggered: Changes detected requiring targeted validation"
        
        if ! execute_stage 2; then
            print_error "Pipeline failed at Stage 2 (Targeted Checks)"
            display_pipeline_summary
            return 1
        fi
    else
        print_success "✓ Stage 2 skipped: No docs/script/structure changes detected"
        STAGE_STATUS[2]="skipped"
        STAGE_RESULTS[2]="⏭️  SKIPPED"
    fi
    
    # Stage 3: Full Validation (conditional)
    if should_run_stage 3; then
        # Determine why Stage 3 was triggered
        if [[ "${MANUAL_TRIGGER:-false}" == "true" ]]; then
            print_info "Stage 3 triggered: Manual trigger requested"
        elif is_high_impact_change; then
            print_info "Stage 3 triggered: High-impact changes detected"
        elif has_code_changes; then
            print_info "Stage 3 triggered: Code changes detected"
        fi
        
        if ! execute_stage 3; then
            print_error "Pipeline failed at Stage 3 (Full Validation)"
            display_pipeline_summary
            return 1
        fi
    else
        print_success "✓ Stage 3 skipped: No high-impact or code changes (or manual trigger)"
        STAGE_STATUS[3]="skipped"
        STAGE_RESULTS[3]="⏭️  SKIPPED"
    fi
    
    # Pipeline completed successfully
    print_success "🎉 Pipeline completed successfully!"
    display_pipeline_summary
    return 0
}

# ==============================================================================
# DISPLAY AND REPORTING
# ==============================================================================

# Display stage header
# Args: $1 = stage_number, $2 = stage_name, $3 = target_seconds
print_stage_header() {
    local stage="$1"
    local name="$2"
    local target="$3"
    
    local target_min=$((target / 60))
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Stage $stage: $name (Target: ${target_min} minutes)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Display pipeline execution summary
display_pipeline_summary() {
    echo ""
    print_header "Pipeline Execution Summary"
    
    # Calculate total duration
    local total_duration=0
    for stage in 1 2 3; do
        local duration=${STAGE_DURATIONS[$stage]:-0}
        total_duration=$((total_duration + duration))
    done
    
    local total_min=$((total_duration / 60))
    
    echo "Stage | Name              | Status   | Duration | Target"
    echo "─────────────────────────────────────────────────────────────"
    
    for stage in 1 2 3; do
        local status="${STAGE_STATUS[$stage]:-pending}"
        local result="${STAGE_RESULTS[$stage]:- PENDING}"
        local duration=${STAGE_DURATIONS[$stage]:-0}
        
        local name=""
        local target=0
        case "$stage" in
            1) name="Fast Validation"; target=$STAGE_FAST_VALIDATION_TARGET ;;
            2) name="Targeted Checks"; target=$STAGE_TARGETED_CHECKS_TARGET ;;
            3) name="Full Validation"; target=$STAGE_FULL_VALIDATION_TARGET ;;
        esac
        
        local duration_str="${duration}s"
        local target_str="${target}s"
        
        printf "  %d   | %-17s | %-8s | %8s | %6s\n" \
            "$stage" "$name" "$result" "$duration_str" "$target_str"
    done
    
    echo "─────────────────────────────────────────────────────────────"
    echo "Total Duration: ${total_min}m (${total_duration}s)"
    echo ""
    
    # Show efficiency metrics
    local stages_run=0
    local stages_skipped=0
    
    for stage in 1 2 3; do
        if [[ "${STAGE_STATUS[$stage]:-}" == "skipped" ]]; then
            ((stages_skipped++)) || true
        else
            ((stages_run++)) || true
        fi
    done
    
    print_info "Stages executed: $stages_run / 3"
    if [[ $stages_skipped -gt 0 ]]; then
        print_success "Stages skipped: $stages_skipped (efficiency optimization)"
    fi
}

# Display pipeline plan (dry-run)
display_pipeline_plan() {
    print_header "Pipeline Execution Plan"
    
    echo "Stage | Name              | Will Run? | Reason"
    echo "─────────────────────────────────────────────────────────────────"
    
    for stage in 1 2 3; do
        local name=""
        local trigger=""
        
        case "$stage" in
            1) name="Fast Validation"; trigger="$STAGE_1_TRIGGER" ;;
            2) name="Targeted Checks"; trigger="$STAGE_2_TRIGGER" ;;
            3) name="Full Validation"; trigger="$STAGE_3_TRIGGER" ;;
        esac
        
        if should_run_stage "$stage"; then
            printf "  %d   | %-17s | %-9s | %s\n" \
                "$stage" "$name" "YES ✅" "$trigger"
        else
            printf "  %d   | %-17s | %-9s | %s\n" \
                "$stage" "$name" "NO ⏭️" "Trigger not met"
        fi
    done
    
    echo "─────────────────────────────────────────────────────────────────"
}

# ==============================================================================
# MANUAL CONTROLS
# ==============================================================================

# Enable manual trigger for Stage 3
enable_manual_trigger() {
    export MANUAL_TRIGGER=true
    print_info "Manual trigger enabled - Stage 3 will execute"
}

# Disable manual trigger
disable_manual_trigger() {
    export MANUAL_TRIGGER=false
}

# Run only specific stage(s)
# Args: $@ = stage numbers (e.g., "1" or "1 2")
run_stages() {
    local stages=("$@")
    
    for stage in "${stages[@]}"; do
        execute_stage "$stage"
    done
}

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Set custom stage target times
# Args: $1 = stage_number, $2 = target_seconds
set_stage_target() {
    local stage="$1"
    local target="$2"
    
    case "$stage" in
        1) STAGE_FAST_VALIDATION_TARGET=$target ;;
        2) STAGE_TARGETED_CHECKS_TARGET=$target ;;
        3) STAGE_FULL_VALIDATION_TARGET=$target ;;
    esac
    
    print_info "Stage $stage target set to ${target}s ($(($target / 60))m)"
}

# Display pipeline configuration
display_pipeline_config() {
    print_header "Pipeline Configuration"
    
    echo "Stage 1: $STAGE_FAST_VALIDATION_NAME"
    echo "  Steps:   ${STAGE_FAST_VALIDATION[*]}"
    echo "  Target:  ${STAGE_FAST_VALIDATION_TARGET}s ($(($STAGE_FAST_VALIDATION_TARGET / 60))m)"
    echo "  Trigger: $STAGE_1_TRIGGER"
    echo ""
    
    echo "Stage 2: $STAGE_TARGETED_CHECKS_NAME"
    echo "  Steps:   ${STAGE_TARGETED_CHECKS[*]}"
    echo "  Target:  ${STAGE_TARGETED_CHECKS_TARGET}s ($(($STAGE_TARGETED_CHECKS_TARGET / 60))m)"
    echo "  Trigger: $STAGE_2_TRIGGER"
    echo ""
    
    echo "Stage 3: $STAGE_FULL_VALIDATION_NAME"
    echo "  Steps:   ${STAGE_FULL_VALIDATION[*]}"
    echo "  Target:  ${STAGE_FULL_VALIDATION_TARGET}s ($(($STAGE_FULL_VALIDATION_TARGET / 60))m)"
    echo "  Trigger: $STAGE_3_TRIGGER"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f should_run_stage
export -f evaluate_stage_trigger
export -f evaluate_single_trigger
export -f is_high_impact_change
export -f has_docs_changes
export -f has_script_changes
export -f has_structure_changes
export -f has_code_changes
export -f execute_stage
export -f execute_pipeline
export -f display_pipeline_summary
export -f display_pipeline_plan
export -f enable_manual_trigger
export -f disable_manual_trigger
export -f run_stages
export -f set_stage_target
export -f display_pipeline_config

################################################################################
# End of Multi-Stage Pipeline Module
################################################################################
