#!/usr/bin/env bash

################################################################################
# Quality Orchestrator
# Version: 2.4.0
# Purpose: Orchestrate dependency and code quality checks (Steps 8-9)
# Part of: Workflow Automation Modularization Phase 3
################################################################################

set -euo pipefail

# ==============================================================================
# QUALITY PHASE EXECUTION
# ==============================================================================

execute_quality_phase() {
    print_header "Quality Phase (Steps 8-9)"
    log_to_workflow "INFO" "Starting quality phase"
    
    local start_time
    start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Check for resume point
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step 8: Dependency Validation
    if [[ $resume_from -le 8 ]] && should_execute_step 8; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 8 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 8 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 8 skipped - ${CHANGE_IMPACT} impact"
            ((skipped_steps++)) || true
        else
            log_step_start 8 "Dependency Validation"
            if step8_validate_dependencies; then
                ((executed_steps++)) || true
                save_checkpoint 8
            else
                failed_step="Step 8"
            fi
        fi
    elif [[ $resume_from -le 8 ]]; then
        print_info "Skipping Step 8 (not selected)"
        ((skipped_steps++)) || true
    else
        print_info "Skipping Step 8 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 9: Code Quality Validation
    if [[ -z "$failed_step" && $resume_from -le 9 ]] && should_execute_step 9; then
        log_step_start 9 "Code Quality Validation"
        if step9_validate_code_quality; then
            ((executed_steps++)) || true
            save_checkpoint 9
        else
            failed_step="Step 9"
        fi
    elif [[ -z "$failed_step" && $resume_from -le 9 ]]; then
        print_info "Skipping Step 9 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 9 ]]; then
        print_info "Skipping Step 9 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Quality phase completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "Quality phase completed: ${duration}s, executed: $executed_steps, skipped: $skipped_steps"
        return 0
    else
        print_error "Quality phase failed at $failed_step"
        log_to_workflow "ERROR" "Quality phase failed at $failed_step"
        return 1
    fi
}
