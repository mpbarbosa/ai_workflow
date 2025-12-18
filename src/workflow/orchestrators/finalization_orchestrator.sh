#!/usr/bin/env bash

################################################################################
# Finalization Orchestrator
# Version: 2.4.0
# Purpose: Orchestrate context analysis, git operations, and cleanup (Steps 10-12)
# Part of: Workflow Automation Modularization Phase 3
################################################################################

set -euo pipefail

# ==============================================================================
# FINALIZATION PHASE EXECUTION
# ==============================================================================

execute_finalization_phase() {
    print_header "Finalization Phase (Steps 10-12)"
    log_to_workflow "INFO" "Starting finalization phase"
    
    local start_time
    start_time=$(date +%s)
    local failed_step=""
    local executed_steps=0
    local skipped_steps=0
    
    # Check for resume point
    local resume_from=${RESUME_FROM_STEP:-0}
    
    # Step 10: Context Analysis
    if [[ $resume_from -le 10 ]] && should_execute_step 10; then
        log_step_start 10 "Context Analysis"
        if step10_context_analysis; then
            ((executed_steps++)) || true
            save_checkpoint 10
        else
            failed_step="Step 10"
        fi
    elif [[ $resume_from -le 10 ]]; then
        print_info "Skipping Step 10 (not selected)"
        ((skipped_steps++)) || true
    else
        print_info "Skipping Step 10 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 11: Git Finalization
    if [[ -z "$failed_step" && $resume_from -le 11 ]] && should_execute_step 11; then
        log_step_start 11 "Git Finalization"
        if step11_git_finalization; then
            ((executed_steps++)) || true
            save_checkpoint 11
        else
            failed_step="Step 11"
        fi
    elif [[ -z "$failed_step" && $resume_from -le 11 ]]; then
        print_info "Skipping Step 11 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 11 ]]; then
        print_info "Skipping Step 11 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    # Step 12: Markdown Linting
    if [[ -z "$failed_step" && $resume_from -le 12 ]] && should_execute_step 12; then
        log_step_start 12 "Markdown Linting"
        if step12_markdown_linting; then
            ((executed_steps++)) || true
            save_checkpoint 12
        else
            failed_step="Step 12"
        fi
    elif [[ -z "$failed_step" && $resume_from -le 12 ]]; then
        print_info "Skipping Step 12 (not selected)"
        ((skipped_steps++)) || true
    elif [[ $resume_from -gt 12 ]]; then
        print_info "Skipping Step 12 (resuming from checkpoint)"
        ((skipped_steps++)) || true
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ -z "$failed_step" ]]; then
        print_success "Finalization phase completed in ${duration}s (executed: $executed_steps, skipped: $skipped_steps)"
        log_to_workflow "SUCCESS" "Finalization phase completed: ${duration}s, executed: $executed_steps, skipped: $skipped_steps"
        return 0
    else
        print_error "Finalization phase failed at $failed_step"
        log_to_workflow "ERROR" "Finalization phase failed at $failed_step"
        return 1
    fi
}
