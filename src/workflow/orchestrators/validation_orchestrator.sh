#!/usr/bin/env bash

################################################################################
# Validation Orchestrator
# Version: 4.0.0
# Purpose: Orchestrate documentation and structure validation
# Part of: Workflow Automation v4.0 (Configuration-Driven Steps)
#
# Changes in v4.0:
#   - Uses step registry for step resolution
#   - Supports both step names and numeric indices
#   - Dynamic step execution with step_loader
#   - Backward compatible with v3.x
################################################################################

set -euo pipefail

# ==============================================================================
# VALIDATION PHASE EXECUTION
# ==============================================================================

execute_validation_phase() {
    print_header "Validation Phase"
    log_to_workflow "INFO" "Starting validation phase"
    
    local start_time
    start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Check for resume point
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step 0: Pre-Analysis (or by name: pre_analysis)
    local pre_analysis_step="0"
    if [[ "$STEP_REGISTRY_LOADED" == true ]]; then
        pre_analysis_step=$(get_step_by_index 2 2>/dev/null || echo "0")  # Index 2 = pre_analysis in v4.0
    fi
    
    if [[ $resume_from -le 0 ]] && should_execute_step "$pre_analysis_step"; then
        log_step_start 0 "Pre-Analysis"
        if execute_step "$pre_analysis_step"; then
            ((executed_steps++)) || true
            save_checkpoint 0
        else
            failed_step="Step 0 (Pre-Analysis)"
        fi
    elif [[ $resume_from -le 0 ]]; then
        print_info "Skipping Step 0 (not selected)"
        ((skipped_steps++)) || true
    else
        print_info "Skipping Step 0 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Steps 1-4: Parallel or Sequential
    if [[ -z "$failed_step" ]]; then
        execute_validation_steps "$resume_from"
        local result=$?
        
        if [[ $result -eq 0 ]]; then
            ((executed_steps+=4)) || true
        else
            failed_step="Validation Steps"
            return 1
        fi
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Validation phase completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "Validation phase completed: ${duration}s, executed: $executed_steps, skipped: $skipped_steps"
        return 0
    else
        print_error "Validation phase failed at $failed_step"
        log_to_workflow "ERROR" "Validation phase failed at $failed_step"
        return 1
    fi
}

# ==============================================================================
# VALIDATION STEPS EXECUTION
# ==============================================================================

execute_validation_steps() {
    local resume_from=$1
    
    # Check if parallel execution is possible and enabled
    local can_parallelize=false
    if [[ $resume_from -le 1 ]]; then
        if should_execute_step 1 && should_execute_step 2 && \
           should_execute_step 3 && should_execute_step 4; then
            can_parallelize=true
        fi
    fi
    
    # Parallel execution path
    if [[ "$can_parallelize" == true && "$DRY_RUN" != true && \
          "${PARALLEL_EXECUTION}" == "true" ]]; then
        print_info "⚡ Parallel execution enabled for validation steps"
        
        if execute_parallel_validation; then
            save_checkpoint 4
            return 0
        else
            return 1
        fi
    fi
    
    # Sequential execution path
    if [[ "$can_parallelize" == true && "${PARALLEL_EXECUTION}" != "true" ]]; then
        print_info "Parallel execution available (use --parallel flag)"
    fi
    
    # Step 1: Documentation Updates (or documentation_updates in v4.0)
    if [[ $resume_from -le 1 ]] && should_execute_step 1; then
        log_step_start 1 "Documentation Updates"
        if ! execute_step 1; then
            return 1
        fi
        save_checkpoint 1
    elif [[ $resume_from -le 1 ]]; then
        print_info "Skipping Step 1 (not selected)"
    else
        print_info "Skipping Step 1 (resuming from checkpoint)"
    fi
    
    # Step 2: Consistency Analysis (or consistency_analysis in v4.0)
    if [[ $resume_from -le 2 ]] && should_execute_step 2; then
        log_step_start 2 "Consistency Analysis"
        if ! execute_step 2; then
            return 1
        fi
        save_checkpoint 2
    elif [[ $resume_from -le 2 ]]; then
        print_info "Skipping Step 2 (not selected)"
    else
        print_info "Skipping Step 2 (resuming from checkpoint)"
    fi
    
    # Step 2.5: Documentation Optimization (or documentation_optimization in v4.0)
    if [[ $resume_from -le 2 ]] && should_execute_step 2; then
        log_step_start "2.5" "Documentation Optimization"
        # v4.0: Use step name if registry is loaded
        local doc_opt_step="2.5"
        if [[ "$STEP_REGISTRY_LOADED" == true ]]; then
            doc_opt_step=$(get_step_by_index 7 2>/dev/null || echo "2.5")  # documentation_optimization
        fi
        if ! execute_step "$doc_opt_step"; then
            return 1
        fi
        save_checkpoint "2.5"
    elif [[ $resume_from -le 2 ]]; then
        print_info "Skipping Step 2.5 (not selected)"
    else
        print_info "Skipping Step 2.5 (resuming from checkpoint)"
    fi
    
    # Step 3: Script Reference Validation (or script_reference_validation in v4.0)
    if [[ $resume_from -le 3 ]] && should_execute_step 3; then
        log_step_start 3 "Script Reference Validation"
        if ! execute_step 3; then
            return 1
        fi
        save_checkpoint 3
    elif [[ $resume_from -le 3 ]]; then
        print_info "Skipping Step 3 (not selected)"
    else
        print_info "Skipping Step 3 (resuming from checkpoint)"
    fi
    
    # Step 4: Directory Structure Validation (or directory_validation in v4.0)
    if [[ $resume_from -le 4 ]] && should_execute_step 4; then
        log_step_start 4 "Directory Structure Validation"
        if ! execute_step 4; then
            return 1
        fi
        save_checkpoint 4
    elif [[ $resume_from -le 4 ]]; then
        print_info "Skipping Step 4 (not selected)"
    else
        print_info "Skipping Step 4 (resuming from checkpoint)"
    fi
    
    return 0
}

# ==============================================================================
# PARALLEL VALIDATION EXECUTION
# ==============================================================================

execute_parallel_validation() {
    print_info "Starting parallel validation..."
    log_to_workflow "INFO" "Parallel validation started"
    
    local temp_dir="${LOGS_RUN_DIR}/parallel_validation"
    mkdir -p "$temp_dir"
    
    # v4.0: Use execute_step instead of direct function calls
    # This works with both numeric indices and step names
    
    # Launch steps in background
    (
        log_step_start 1 "Documentation Updates"
        execute_step 1
        echo $? > "${temp_dir}/step1_exit.txt"
    ) &
    local pid1=$!
    
    (
        log_step_start 2 "Consistency Analysis"
        execute_step 2
        echo $? > "${temp_dir}/step2_exit.txt"
    ) &
    local pid2=$!
    
    (
        log_step_start 3 "Script Reference Validation"
        execute_step 3
        echo $? > "${temp_dir}/step3_exit.txt"
    ) &
    local pid3=$!
    
    (
        log_step_start 4 "Directory Structure Validation"
        execute_step 4
        echo $? > "${temp_dir}/step4_exit.txt"
    ) &
    local pid4=$!
    
    # Wait for all steps
    print_info "Waiting for parallel steps to complete..."
    wait $pid1 $pid2 $pid3 $pid4
    
    # Check exit codes
    local step1_exit step2_exit step3_exit step4_exit
    step1_exit=$(cat "${temp_dir}/step1_exit.txt" 2>/dev/null || echo "1")
    step2_exit=$(cat "${temp_dir}/step2_exit.txt" 2>/dev/null || echo "1")
    step3_exit=$(cat "${temp_dir}/step3_exit.txt" 2>/dev/null || echo "1")
    step4_exit=$(cat "${temp_dir}/step4_exit.txt" 2>/dev/null || echo "1")
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Check results
    if [[ $step1_exit -eq 0 && $step2_exit -eq 0 && \
          $step3_exit -eq 0 && $step4_exit -eq 0 ]]; then
        print_success "Parallel validation completed successfully"
        log_to_workflow "SUCCESS" "Parallel validation completed"
        return 0
    else
        print_error "Parallel validation failed (exit codes: $step1_exit $step2_exit $step3_exit $step4_exit)"
        log_to_workflow "ERROR" "Parallel validation failed"
        return 1
    fi
}
