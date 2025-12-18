#!/usr/bin/env bash

################################################################################
# Test Orchestrator
# Version: 2.4.0
# Purpose: Orchestrate test review, generation, and execution (Steps 5-7)
# Part of: Workflow Automation Modularization Phase 3
################################################################################

set -euo pipefail

# ==============================================================================
# TEST PHASE EXECUTION
# ==============================================================================

execute_test_phase() {
    print_header "Test Phase (Steps 5-7)"
    log_to_workflow "INFO" "Starting test phase"
    
    local start_time
    start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Check for resume point
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step 5: Test Review
    if [[ $resume_from -le 5 ]] && should_execute_step 5; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 5 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 5 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 5 skipped - ${CHANGE_IMPACT} impact"
            ((skipped_steps++)) || true
        else
            log_step_start 5 "Test Review"
            if step5_review_existing_tests; then
                ((executed_steps++)) || true
                save_checkpoint 5
            else
                failed_step="Step 5"
            fi
        fi
    elif [[ $resume_from -le 5 ]]; then
        print_info "Skipping Step 5 (not selected)"
        ((skipped_steps++)) || true
    else
        print_info "Skipping Step 5 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 6: Test Generation
    if [[ -z "$failed_step" && $resume_from -le 6 ]] && should_execute_step 6; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 6 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 6 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 6 skipped - ${CHANGE_IMPACT} impact"
            ((skipped_steps++)) || true
        else
            log_step_start 6 "Test Generation"
            if step6_generate_new_tests; then
                ((executed_steps++)) || true
                save_checkpoint 6
            else
                failed_step="Step 6"
            fi
        fi
    elif [[ -z "$failed_step" && $resume_from -le 6 ]]; then
        print_info "Skipping Step 6 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 6 ]]; then
        print_info "Skipping Step 6 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 7: Test Execution
    if [[ -z "$failed_step" && $resume_from -le 7 ]] && should_execute_step 7; then
        if [[ "${SMART_EXECUTION}" == "true" ]] && should_skip_step_by_impact 7 "${CHANGE_IMPACT}"; then
            print_info "⚡ Step 7 skipped (smart execution - ${CHANGE_IMPACT} impact)"
            log_to_workflow "INFO" "Step 7 skipped - ${CHANGE_IMPACT} impact"
            ((skipped_steps++)) || true
        else
            log_step_start 7 "Test Execution"
            if step7_execute_test_suite; then
                ((executed_steps++)) || true
                save_checkpoint 7
            else
                failed_step="Step 7"
            fi
        fi
    elif [[ -z "$failed_step" && $resume_from -le 7 ]]; then
        print_info "Skipping Step 7 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 7 ]]; then
        print_info "Skipping Step 7 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Test phase completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "Test phase completed: ${duration}s, executed: $executed_steps, skipped: $skipped_steps"
        return 0
    else
        print_error "Test phase failed at $failed_step"
        log_to_workflow "ERROR" "Test phase failed at $failed_step"
        return 1
    fi
}
