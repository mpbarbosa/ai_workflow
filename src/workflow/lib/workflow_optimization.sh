#!/bin/bash
set -euo pipefail


################################################################################
# Workflow Optimization Library
# Version: 1.0.3
# Purpose: Advanced workflow features for performance and reliability
#
# Functions:
#   - should_skip_step_by_impact()     - Conditional step execution based on change impact
#   - execute_parallel_validation()    - Run validation steps (1-4) in parallel
#   - save_checkpoint()                - Save workflow checkpoint for resume capability
#   - load_checkpoint()                - Load and validate checkpoint for resume
#   - cleanup_old_checkpoints()        - Remove checkpoints older than 7 days
################################################################################

# Set defaults for required variables if not already set
PROJECT_ROOT=${PROJECT_ROOT:-$(pwd)}
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
WORKFLOW_RUN_ID=${WORKFLOW_RUN_ID:-workflow_$(date +%Y%m%d_%H%M%S)}

# Checkpoint directory - must use WORKFLOW_HOME not PROJECT_ROOT for --target compatibility
CHECKPOINT_DIR="${WORKFLOW_HOME}/src/workflow/.checkpoints"
CHECKPOINT_FILE="${CHECKPOINT_DIR}/${WORKFLOW_RUN_ID}.checkpoint"

# ==============================================================================
# CONDITIONAL STEP EXECUTION
# ==============================================================================

# Determine if a step should be skipped based on change impact analysis
# Args: $1 = step_number, $2 = change_impact (Low/Medium/High)
# Returns: 0 if should skip, 1 if should execute
should_skip_step_by_impact() {
    local step_num="$1"
    local impact="${2:-Unknown}"
    
    # Never skip if impact is Unknown (safety first)
    if [[ "$impact" == "Unknown" ]]; then
        return 1  # Execute step
    fi
    
    # Define skip rules for Low impact changes
    if [[ "$impact" == "Low" ]]; then
        case "$step_num" in
            5)  # Test Review - skip if only docs changed
                if [[ $(get_git_code_modified) -eq 0 ]] && [[ $(get_git_tests_modified) -eq 0 ]]; then
                    print_info "Skipping Step 5 (Test Review) - No code/test changes detected"
                    log_to_workflow "INFO" "Step 5 skipped - Low impact (docs only)"
                    return 0
                fi
                ;;
            6)  # Test Generation - skip if only docs changed
                if [[ $(get_git_code_modified) -eq 0 ]] && [[ $(get_git_tests_modified) -eq 0 ]]; then
                    print_info "Skipping Step 6 (Test Generation) - No code changes detected"
                    log_to_workflow "INFO" "Step 6 skipped - Low impact (docs only)"
                    return 0
                fi
                ;;
            7)  # Test Execution - skip if no code/test changes
                if [[ $(get_git_code_modified) -eq 0 ]] && [[ $(get_git_tests_modified) -eq 0 ]]; then
                    print_info "Skipping Step 7 (Test Execution) - No code/test changes detected"
                    log_to_workflow "INFO" "Step 7 skipped - Low impact (docs only)"
                    return 0
                fi
                ;;
            8)  # Dependency Validation - skip if package.json unchanged
                if ! is_deps_modified; then
                    print_info "Skipping Step 8 (Dependency Validation) - No dependency changes"
                    log_to_workflow "INFO" "Step 8 skipped - Low impact (dependencies unchanged)"
                    return 0
                fi
                ;;
            9)  # Code Quality - skip if only docs changed
                if [[ $(get_git_code_modified) -eq 0 ]]; then
                    print_info "Skipping Step 9 (Code Quality) - No code changes detected"
                    log_to_workflow "INFO" "Step 9 skipped - Low impact (docs only)"
                    return 0
                fi
                ;;
        esac
    fi
    
    # Default: execute step
    return 1
}

# Analyze change impact to determine workflow optimization strategy
# Returns: Sets CHANGE_IMPACT global variable (Low/Medium/High)
analyze_change_impact() {
    local code_changes=$(get_git_code_modified)
    local test_changes=$(get_git_tests_modified)
    local doc_changes=$(get_git_docs_modified)
    local script_changes=$(get_git_scripts_modified)
    local deps_changed=$(is_deps_modified && echo "true" || echo "false")
    local total_changes=$(get_git_total_changes)
    
    print_header "Change Impact Analysis"
    log_to_workflow "INFO" "Analyzing change impact for optimization"
    
    print_info "Code changes: $code_changes"
    print_info "Test changes: $test_changes"
    print_info "Doc changes: $doc_changes"
    print_info "Script changes: $script_changes"
    print_info "Dependencies changed: $deps_changed"
    print_info "Total changes: $total_changes"
    
    # Determine impact level
    local impact="Medium"  # Default
    
    # High impact: Code changes + dependency changes, or many files
    if [[ $code_changes -gt 5 ]] || [[ "$deps_changed" == "true" && $code_changes -gt 0 ]]; then
        impact="High"
        print_warning "Change Impact: HIGH - Full workflow recommended"
        log_to_workflow "INFO" "Change impact: HIGH (code=$code_changes, deps=$deps_changed)"
    # Low impact: Only documentation or very few files
    elif [[ $code_changes -eq 0 && $test_changes -eq 0 && $script_changes -eq 0 ]]; then
        impact="Low"
        print_success "Change Impact: LOW - Some steps can be skipped"
        log_to_workflow "INFO" "Change impact: LOW (docs only)"
    # Medium impact: Some code changes but not extensive
    else
        impact="Medium"
        print_info "Change Impact: MEDIUM - Standard workflow execution"
        log_to_workflow "INFO" "Change impact: MEDIUM (code=$code_changes, tests=$test_changes)"
    fi
    
    # Set global variable for use throughout workflow
    CHANGE_IMPACT="$impact"
    export CHANGE_IMPACT
    
    # Save to backlog
    local impact_report="${BACKLOG_RUN_DIR}/CHANGE_IMPACT_ANALYSIS.md"
    cat > "$impact_report" << EOF
# Change Impact Analysis

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Impact Level:** ${impact}

---

## Change Metrics

- **Code Changes:** ${code_changes} files
- **Test Changes:** ${test_changes} files
- **Documentation Changes:** ${doc_changes} files
- **Script Changes:** ${script_changes} files
- **Dependencies Changed:** ${deps_changed}
- **Total Changes:** ${total_changes} files

---

## Impact Assessment

**Level:** ${impact}

EOF
    
    case "$impact" in
        "High")
            cat >> "$impact_report" << EOF
**Reasoning:** Extensive code changes and/or dependency modifications detected.

**Recommendation:** Execute full workflow with all validation steps.

**Optimizations:**
- No steps skipped
- Full test suite execution required
- Complete code quality validation needed
- Dependency security scan essential

EOF
            ;;
        "Medium")
            cat >> "$impact_report" << EOF
**Reasoning:** Moderate code changes without dependency modifications.

**Recommendation:** Execute standard workflow with selective optimizations.

**Optimizations:**
- Test-related steps execute normally
- Code quality checks run on changed files
- Dependency validation may be optimized

EOF
            ;;
        "Low")
            cat >> "$impact_report" << EOF
**Reasoning:** Documentation-only changes with no code modifications.

**Recommendation:** Execute documentation-focused workflow with test skip.

**Optimizations:**
- Test Review (Step 5) can be skipped
- Test Generation (Step 6) can be skipped
- Test Execution (Step 7) can be skipped
- Dependency Validation (Step 8) can be skipped
- Code Quality (Step 9) can be skipped

**Focus Areas:**
- Documentation updates (Step 1)
- Consistency analysis (Step 2)
- Script reference validation (Step 3)
- Directory structure validation (Step 4)
- Markdown linting (Step 12)

EOF
            ;;
    esac
    
    cat >> "$impact_report" << EOF

---

**Generated by:** Change Impact Analyzer v1.0.3
EOF
    
    print_success "Change impact analysis saved: $impact_report"
}

# ==============================================================================
# PARALLEL STEP PROCESSING
# ==============================================================================

# Execute workflow in 3 parallel tracks for optimal performance
# Track 1: Analysis (0 → 3,4,13 → 10 → 11)
# Track 2: Validation (5 → 6 → 7 → 9 + 8)
# Track 3: Documentation (1 → 2 → 12)
# Returns: 0 if all succeed, 1 if any fail
execute_parallel_tracks() {
    print_header "Parallel Track Execution (3 Tracks)"
    log_to_workflow "INFO" "Starting 3-track parallel execution"
    
    # Create temporary directory for parallel execution
    local parallel_dir="${BACKLOG_RUN_DIR}/parallel_tracks"
    mkdir -p "$parallel_dir"
    
    # Track PIDs
    local track_pids=()
    
    print_info "Launching 3 parallel execution tracks..."
    
    # TRACK 1: Analysis Track
    # Steps: 0 → (3,4,13 parallel) → 10 → 11
    (
        echo "RUNNING" > "${parallel_dir}/track_analysis.status"
        log_to_workflow "INFO" "Track 1 (Analysis): Starting"
        
        # Step 0: Pre-Analysis
        if should_execute_step 0; then
            step0_analyze_changes > "${parallel_dir}/track1_step0.log" 2>&1 || {
                echo "FAILED:0" > "${parallel_dir}/track_analysis.status"
                exit 1
            }
        fi
        
        # Steps 3, 4, 13 in parallel (after Step 0)
        local step_pids=()
        
        if should_execute_step 3; then
            step3_validate_script_references > "${parallel_dir}/track1_step3.log" 2>&1 &
            step_pids[3]=$!
        fi
        
        if should_execute_step 4; then
            step4_validate_directory_structure > "${parallel_dir}/track1_step4.log" 2>&1 &
            step_pids[4]=$!
        fi
        
        if should_execute_step 13; then
            step13_prompt_engineer_analysis > "${parallel_dir}/track1_step13.log" 2>&1 &
            step_pids[13]=$!
        fi
        
        # Wait for parallel steps
        local step_failed=false
        for step_num in 3 4 13; do
            [[ -n "${step_pids[$step_num]}" ]] && {
                wait ${step_pids[$step_num]} || step_failed=true
            }
        done
        
        [[ "$step_failed" == true ]] && {
            echo "FAILED:3/4/13" > "${parallel_dir}/track_analysis.status"
            exit 1
        }
        
        # Step 10: Context Analysis (depends on other tracks)
        # Wait for Track 2 & 3 critical steps before proceeding
        while [[ ! -f "${parallel_dir}/track_validation_ready.flag" ]] || \
              [[ ! -f "${parallel_dir}/track_docs_ready.flag" ]]; do
            sleep 2
        done
        
        if should_execute_step 10; then
            step10_context_analysis > "${parallel_dir}/track1_step10.log" 2>&1 || {
                echo "FAILED:10" > "${parallel_dir}/track_analysis.status"
                exit 1
            }
        fi
        
        # Step 11: Git Finalization
        if should_execute_step 11; then
            step11_git_finalization > "${parallel_dir}/track1_step11.log" 2>&1 || {
                echo "FAILED:11" > "${parallel_dir}/track_analysis.status"
                exit 1
            }
        fi
        
        echo "SUCCESS" > "${parallel_dir}/track_analysis.status"
        log_to_workflow "INFO" "Track 1 (Analysis): Complete"
        exit 0
    ) &
    track_pids[1]=$!
    print_info "Track 1 (Analysis) launched (PID: ${track_pids[1]})"
    
    # TRACK 2: Validation Track
    # Steps: 5 → 6 → 7 → 9 (+ 8 parallel with 5)
    (
        echo "RUNNING" > "${parallel_dir}/track_validation.status"
        log_to_workflow "INFO" "Track 2 (Validation): Starting"
        
        # Wait for Step 0 from Track 1
        while [[ ! -f "${parallel_dir}/track1_step0.log" ]]; do
            sleep 1
        done
        
        # Step 5 & 8 in parallel
        local dep_pid=""
        if should_execute_step 5; then
            step5_review_existing_tests > "${parallel_dir}/track2_step5.log" 2>&1 || {
                echo "FAILED:5" > "${parallel_dir}/track_validation.status"
                exit 1
            }
        fi
        
        if should_execute_step 8; then
            step8_validate_dependencies > "${parallel_dir}/track2_step8.log" 2>&1 &
            dep_pid=$!
        fi
        
        # Step 6: Test Generation
        if should_execute_step 6; then
            step6_generate_new_tests > "${parallel_dir}/track2_step6.log" 2>&1 || {
                echo "FAILED:6" > "${parallel_dir}/track_validation.status"
                exit 1
            }
        fi
        
        # Step 7: Test Execution
        if should_execute_step 7; then
            step8_execute_test_suite > "${parallel_dir}/track2_step7.log" 2>&1 || {
                echo "FAILED:7" > "${parallel_dir}/track_validation.status"
                exit 1
            }
        fi
        
        # Wait for dependency check if running
        [[ -n "$dep_pid" ]] && wait $dep_pid
        
        # Step 9: Code Quality
        if should_execute_step 9; then
            step9_code_quality_validation > "${parallel_dir}/track2_step9.log" 2>&1 || {
                echo "FAILED:9" > "${parallel_dir}/track_validation.status"
                exit 1
            }
        fi
        
        # Signal readiness for Step 10
        touch "${parallel_dir}/track_validation_ready.flag"
        
        echo "SUCCESS" > "${parallel_dir}/track_validation.status"
        log_to_workflow "INFO" "Track 2 (Validation): Complete"
        exit 0
    ) &
    track_pids[2]=$!
    print_info "Track 2 (Validation) launched (PID: ${track_pids[2]})"
    
    # TRACK 3: Documentation Track
    # Steps: 1 → 2 → 12
    (
        echo "RUNNING" > "${parallel_dir}/track_docs.status"
        log_to_workflow "INFO" "Track 3 (Documentation): Starting"
        
        # Wait for Step 0 from Track 1
        while [[ ! -f "${parallel_dir}/track1_step0.log" ]]; do
            sleep 1
        done
        
        # Step 1: Documentation
        if should_execute_step 1; then
            step1_update_documentation > "${parallel_dir}/track3_step1.log" 2>&1 || {
                echo "FAILED:1" > "${parallel_dir}/track_docs.status"
                exit 1
            }
        fi
        
        # Step 2: Consistency
        if should_execute_step 2; then
            step2_check_consistency > "${parallel_dir}/track3_step2.log" 2>&1 || {
                echo "FAILED:2" > "${parallel_dir}/track_docs.status"
                exit 1
            }
        fi
        
        # Step 12: Markdown Linting
        if should_execute_step 12; then
            step12_markdown_linting > "${parallel_dir}/track3_step12.log" 2>&1 || {
                echo "FAILED:12" > "${parallel_dir}/track_docs.status"
                exit 1
            }
        fi
        
        # Signal readiness for Step 10
        touch "${parallel_dir}/track_docs_ready.flag"
        
        echo "SUCCESS" > "${parallel_dir}/track_docs.status"
        log_to_workflow "INFO" "Track 3 (Documentation): Complete"
        exit 0
    ) &
    track_pids[3]=$!
    print_info "Track 3 (Documentation) launched (PID: ${track_pids[3]})"
    
    # Wait for all tracks with progress indicator
    echo ""
    print_info "Waiting for all 3 tracks to complete..."
    
    local all_success=true
    local track_names=("" "Analysis" "Validation" "Documentation")
    
    for track_num in 1 2 3; do
        if [[ -n "${track_pids[$track_num]}" ]]; then
            if wait ${track_pids[$track_num]}; then
                print_success "Track $track_num (${track_names[$track_num]}) completed successfully"
            else
                print_error "Track $track_num (${track_names[$track_num]}) failed"
                all_success=false
            fi
            
            # Show track status
            local status_file="${parallel_dir}/track_${track_names[$track_num],,}.status"
            if [[ -f "$status_file" ]]; then
                local status=$(cat "$status_file")
                print_info "Track $track_num status: $status"
            fi
        fi
    done
    
    # Generate parallel execution report
    generate_parallel_tracks_report "$parallel_dir" "$all_success"
    
    if [[ "$all_success" == true ]]; then
        print_success "All tracks completed successfully"
        return 0
    else
        print_error "One or more tracks failed"
        return 1
    fi
}

# Generate report for 3-track parallel execution
generate_parallel_tracks_report() {
    local parallel_dir="$1"
    local success="$2"
    
    local report="${BACKLOG_RUN_DIR}/PARALLEL_TRACKS_REPORT.md"
    
    cat > "$report" << EOF
# Parallel Track Execution Report

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Status:** $([ "$success" = true ] && echo "✅ SUCCESS" || echo "❌ FAILED")
**Execution Mode:** 3-Track Parallel

---

## Track Overview

### Track 1: Analysis Track
**Steps:** 0 → (3,4,13 parallel) → 10 → 11  
**Purpose:** Pre-analysis, structural validation, context analysis, git finalization  
**Status:** $(cat "${parallel_dir}/track_analysis.status" 2>/dev/null || echo "UNKNOWN")

- Step 0: Pre-Analysis
- Step 3: Script Reference Validation (parallel)
- Step 4: Directory Structure Validation (parallel)
- Step 13: Prompt Engineer Analysis (parallel)
- Step 10: Context Analysis (waits for Track 2 & 3)
- Step 11: Git Finalization

### Track 2: Validation Track
**Steps:** 5 → 6 → 7 → 9 (+ 8 parallel)  
**Purpose:** Test review, generation, execution, code quality, dependencies  
**Status:** $(cat "${parallel_dir}/track_validation.status" 2>/dev/null || echo "UNKNOWN")

- Step 5: Test Review
- Step 8: Dependency Validation (parallel with 5)
- Step 6: Test Generation
- Step 7: Test Execution
- Step 9: Code Quality

### Track 3: Documentation Track
**Steps:** 1 → 2 → 12  
**Purpose:** Documentation updates, consistency checks, markdown linting  
**Status:** $(cat "${parallel_dir}/track_docs.status" 2>/dev/null || echo "UNKNOWN")

- Step 1: Update Documentation
- Step 2: Consistency Analysis
- Step 12: Markdown Linting

---

## Performance Benefits

**3-Track Parallel Execution provides:**
- **~60-70% time reduction** vs sequential execution
- **3 independent work streams** running simultaneously
- **Optimized dependency management** with synchronization points
- **Better resource utilization** on multi-core systems

**Estimated Sequential Time:** ~23-25 minutes  
**Estimated Parallel Time:** ~8-10 minutes  
**Time Savings:** ~15 minutes (60-65% faster)

---

## Execution Details

EOF
    
    # Add log summaries for each track
    for track_num in 1 2 3; do
        local track_name=""
        case $track_num in
            1) track_name="analysis" ;;
            2) track_name="validation" ;;
            3) track_name="docs" ;;
        esac
        
        cat >> "$report" << EOF

### Track $track_num Logs

EOF
        
        for log_file in "${parallel_dir}"/track${track_num}_step*.log; do
            [[ -f "$log_file" ]] || continue
            local step_num=$(basename "$log_file" | grep -oP 'step\K[0-9]+')
            local log_lines=$(wc -l < "$log_file")
            cat >> "$report" << EOF
- **Step ${step_num}:** ${log_lines} lines → \`parallel_tracks/$(basename "$log_file")\`
EOF
        done
    done
    
    cat >> "$report" << EOF

---

**Generated by:** Parallel Track Executor v2.3.1
EOF
    
    print_success "Parallel tracks report saved: $report"
}

# Execute validation steps (1-4) in parallel for faster execution
# NOTE: This is the legacy function, prefer execute_parallel_tracks() for full workflow
# Returns: 0 if all succeed, 1 if any fail
execute_parallel_validation() {
    print_header "Validation Execution"
    log_to_workflow "INFO" "Starting validation steps (1-4)"
    
    # Create temporary directory for execution
    local parallel_dir="${BACKLOG_RUN_DIR}/parallel_validation"
    mkdir -p "$parallel_dir"
    
    # Count steps that will run
    local step_count=0
    should_execute_step 1 && ((step_count++)) || true
    should_execute_step 2 && ((step_count++)) || true
    should_execute_step 3 && ((step_count++)) || true
    should_execute_step 4 && ((step_count++)) || true
    
    # Track PIDs and status
    local pids=()
    local step_names=("" "Update_Documentation" "Consistency_Analysis" "Script_Reference_Validation" "Directory_Structure_Validation")
    local all_success=true
    
    # Run in parallel only if 2+ steps, otherwise sequential
    if [[ $step_count -gt 1 ]]; then
        print_info "Running $step_count validation steps in parallel..."
        
        # Launch Step 1 in background
        if should_execute_step 1; then
            (
                log_step_start 1 "Documentation Updates"
                if step1_update_documentation > "${parallel_dir}/step1.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step1.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step1.status"
                    exit 1
                fi
            ) &
            pids[1]=$!
            print_info "Step 1 launched (PID: ${pids[1]})"
        fi
        
        # Launch Step 2 in background
        if should_execute_step 2; then
            (
                log_step_start 2 "Consistency Analysis"
                if step2_check_consistency > "${parallel_dir}/step2.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step2.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step2.status"
                    exit 1
                fi
            ) &
            pids[2]=$!
            print_info "Step 2 launched (PID: ${pids[2]})"
        fi
        
        # Launch Step 3 in background
        if should_execute_step 3; then
            (
                log_step_start 3 "Script Reference Validation"
                if step3_validate_script_references > "${parallel_dir}/step3.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step3.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step3.status"
                    exit 1
                fi
            ) &
            pids[3]=$!
            print_info "Step 3 launched (PID: ${pids[3]})"
        fi
        
        # Launch Step 4 in background
        if should_execute_step 4; then
            (
                log_step_start 4 "Directory Structure Validation"
                if step4_validate_directory_structure > "${parallel_dir}/step4.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step4.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step4.status"
                    exit 1
                fi
            ) &
            pids[4]=$!
            print_info "Step 4 launched (PID: ${pids[4]})"
        fi
        
        # Wait for parallel steps
        echo ""
        for step_num in 1 2 3 4; do
            if [[ -n "${pids[$step_num]:-}" ]]; then
                if wait ${pids[$step_num]}; then
                    log_step_complete $step_num "${step_names[$step_num]}"
                    print_success "Step $step_num completed successfully"
                else
                    print_error "Step $step_num failed"
                    all_success=false
                fi
                
                # Show log if exists
                if [[ -f "${parallel_dir}/step${step_num}.log" ]]; then
                    local log_lines=$(wc -l < "${parallel_dir}/step${step_num}.log")
                    print_info "Step $step_num log: $log_lines lines (see ${parallel_dir}/step${step_num}.log)"
                fi
            fi
        done
    else
        # SEQUENTIAL MODE: Run single step directly
        print_info "Running validation step sequentially..."
        
        if should_execute_step 1; then
            log_step_start 1 "Documentation Updates"
            if step1_update_documentation > "${parallel_dir}/step1.log" 2>&1; then
                log_step_complete 1 "${step_names[1]}"
                print_success "Step 1 completed successfully"
            else
                print_error "Step 1 failed"
                all_success=false
            fi
            
            if [[ -f "${parallel_dir}/step1.log" ]]; then
                local log_lines=$(wc -l < "${parallel_dir}/step1.log")
                print_info "Step 1 log: $log_lines lines (see ${parallel_dir}/step1.log)"
            fi
        fi
        
        if should_execute_step 2; then
            log_step_start 2 "Consistency Analysis"
            if step2_check_consistency > "${parallel_dir}/step2.log" 2>&1; then
                log_step_complete 2 "${step_names[2]}"
                print_success "Step 2 completed successfully"
            else
                print_error "Step 2 failed"
                all_success=false
            fi
            
            if [[ -f "${parallel_dir}/step2.log" ]]; then
                local log_lines=$(wc -l < "${parallel_dir}/step2.log")
                print_info "Step 2 log: $log_lines lines (see ${parallel_dir}/step2.log)"
            fi
        fi
        
        if should_execute_step 3; then
            log_step_start 3 "Script Reference Validation"
            if step3_validate_script_references > "${parallel_dir}/step3.log" 2>&1; then
                log_step_complete 3 "${step_names[3]}"
                print_success "Step 3 completed successfully"
            else
                print_error "Step 3 failed"
                all_success=false
            fi
            
            if [[ -f "${parallel_dir}/step3.log" ]]; then
                local log_lines=$(wc -l < "${parallel_dir}/step3.log")
                print_info "Step 3 log: $log_lines lines (see ${parallel_dir}/step3.log)"
            fi
        fi
        
        if should_execute_step 4; then
            log_step_start 4 "Directory Structure Validation"
            if step4_validate_directory_structure > "${parallel_dir}/step4.log" 2>&1; then
                log_step_complete 4 "${step_names[4]}"
                print_success "Step 4 completed successfully"
            else
                print_error "Step 4 failed"
                all_success=false
            fi
            
            if [[ -f "${parallel_dir}/step4.log" ]]; then
                local log_lines=$(wc -l < "${parallel_dir}/step4.log")
                print_info "Step 4 log: $log_lines lines (see ${parallel_dir}/step4.log)"
            fi
        fi
    fi
    
    # Generate parallel execution report
    local parallel_report="${BACKLOG_RUN_DIR}/PARALLEL_VALIDATION_REPORT.md"
    cat > "$parallel_report" << EOF
# Parallel Validation Execution Report

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Status:** $([ "$all_success" = true ] && echo "✅ SUCCESS" || echo "❌ FAILED")

---

## Execution Summary

EOF
    
    for step_num in 1 2 3 4; do
        if [[ -n "${pids[$step_num]}" ]]; then
            local status=$(cat "${parallel_dir}/step${step_num}.status" 2>/dev/null || echo "UNKNOWN")
            local log_lines=$(wc -l < "${parallel_dir}/step${step_num}.log" 2>/dev/null || echo "0")
            
            cat >> "$parallel_report" << EOF
### Step ${step_num}: ${step_names[$step_num]}
- **PID:** ${pids[$step_num]}
- **Status:** ${status}
- **Log Lines:** ${log_lines}
- **Log File:** \`parallel_validation/step${step_num}.log\`

EOF
        fi
    done
    
    cat >> "$parallel_report" << EOF

---

## Performance Benefits

Parallel execution reduces validation time by ~60-75% compared to sequential execution.

**Sequential Execution:** ~4-6 minutes (Steps 1-4 run one at a time)
**Parallel Execution:** ~1.5-2 minutes (Steps 1-4 run simultaneously)

---

**Generated by:** Parallel Validation Executor v1.0.3
EOF
    
    print_success "Parallel validation report saved: $parallel_report"
    log_to_workflow "INFO" "Parallel validation completed: $([ "$all_success" = true ] && echo "SUCCESS" || echo "FAILED")"
    
    if [ "$all_success" = true ]; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# CHECKPOINT & RESUME CAPABILITY
# ==============================================================================

# Save workflow checkpoint for resume capability
# Args: $1 = last_completed_step_number
# Note: All variables are properly quoted to prevent Bash interpretation errors (v2.3.1)
save_checkpoint() {
    local last_step="$1"
    local step_status="${2:-success}"  # Optional: success, failed, skipped (v2.6.0)
    
    mkdir -p "$CHECKPOINT_DIR"
    
    cat > "$CHECKPOINT_FILE" << EOF
# Workflow Checkpoint
# DO NOT EDIT MANUALLY

WORKFLOW_RUN_ID="${WORKFLOW_RUN_ID}"
LAST_COMPLETED_STEP="${last_step}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
CHANGE_IMPACT="${CHANGE_IMPACT:-Unknown}"
GIT_BRANCH="$(get_cached_git_branch)"
GIT_COMMIT="$(git rev-parse HEAD 2>/dev/null || echo "unknown")"

# Step Status
EOF
    
    # Save all step statuses
    for step_num in {0..12}; do
        local step_key="step${step_num}"
        local status="${WORKFLOW_STATUS[$step_key]:-NOT_EXECUTED}"
        echo "STEP_${step_num}_STATUS=\"${status}\"" >> "$CHECKPOINT_FILE"
    done
    
    # Save analysis variables
    cat >> "$CHECKPOINT_FILE" << EOF

# Analysis Data
ANALYSIS_COMMITS="${ANALYSIS_COMMITS}"
ANALYSIS_MODIFIED="${ANALYSIS_MODIFIED}"
CHANGE_SCOPE="${CHANGE_SCOPE}"
EOF
    
    log_to_workflow "INFO" "Checkpoint saved: Step ${last_step} completed"
    
    # Record metrics if function available (v2.6.0)
    if type -t stop_step_timer > /dev/null; then
        stop_step_timer "${last_step}" "${step_status}"
    fi
}

# Load checkpoint and validate it's safe to resume
# Returns: 0 if valid checkpoint found, 1 otherwise
# Sets: RESUME_FROM_STEP global variable
load_checkpoint() {
    print_header "Checkpoint Resume Capability"
    
    # Look for most recent checkpoint
    if [[ ! -d "$CHECKPOINT_DIR" ]]; then
        print_info "No checkpoint directory found"
        return 1
    fi
    
    local latest_checkpoint=$(find "$CHECKPOINT_DIR" -name "*.checkpoint" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    
    if [[ -z "$latest_checkpoint" || ! -f "$latest_checkpoint" ]]; then
        print_info "No valid checkpoint found"
        return 1
    fi
    
    # Load checkpoint
    source "$latest_checkpoint"
    
    # Reconstruct WORKFLOW_STATUS array from checkpoint variables
    for step_num in {0..13}; do
        local step_var="STEP_${step_num}_STATUS"
        if [[ -n "${!step_var:-}" ]]; then
            WORKFLOW_STATUS[$step_num]="${!step_var}"
        fi
    done
    
    local checkpoint_age=$(($(date +%s) - $(stat -c %Y "$latest_checkpoint" 2>/dev/null || echo 0)))
    local checkpoint_hours=$((checkpoint_age / 3600))
    
    print_info "Found checkpoint: $(basename "$latest_checkpoint")"
    print_info "Checkpoint age: ${checkpoint_hours} hours"
    print_info "Last completed step: ${LAST_COMPLETED_STEP}"
    print_info "Git branch: ${GIT_BRANCH}"
    
    # Validate checkpoint is recent (within 24 hours)
    if [[ $checkpoint_age -gt 86400 ]]; then
        print_warning "Checkpoint is older than 24 hours - skipping resume"
        log_to_workflow "WARNING" "Checkpoint too old (${checkpoint_hours}h) - fresh start"
        return 1
    fi
    
    # Validate we're on the same branch
    local current_branch=$(get_cached_git_branch)
    if [[ "$current_branch" != "$GIT_BRANCH" ]]; then
        print_warning "Branch changed (${GIT_BRANCH} → ${current_branch}) - skipping resume"
        log_to_workflow "WARNING" "Branch changed - fresh start"
        return 1
    fi
    
    # Validate git state hasn't changed significantly
    local current_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    if [[ "$current_commit" != "$GIT_COMMIT" ]]; then
        print_warning "New commits detected - skipping resume"
        log_to_workflow "WARNING" "Commits changed - fresh start"
        return 1
    fi
    
    # Valid checkpoint - offer resume
    print_success "Valid checkpoint found"
    
    local next_step=$((LAST_COMPLETED_STEP + 1))
    RESUME_FROM_STEP=$next_step
    export RESUME_FROM_STEP
    
    if [[ "$AUTO_MODE" != true ]]; then
        echo ""
        read -p "Resume from Step ${next_step}? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "User declined resume - starting fresh"
            log_to_workflow "INFO" "User declined checkpoint resume"
            unset RESUME_FROM_STEP
            return 1
        fi
    fi
    
    print_success "Resuming workflow from Step ${next_step}"
    log_to_workflow "INFO" "Resuming from checkpoint: Step ${next_step}"
    
    # Generate resume report
    local resume_report="${BACKLOG_RUN_DIR}/WORKFLOW_RESUME_REPORT.md"
    cat > "$resume_report" << EOF
# Workflow Resume Report

**Current Run ID:** ${WORKFLOW_RUN_ID}
**Original Run ID:** ${WORKFLOW_RUN_ID}
**Resume Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Resuming From:** Step ${next_step}

---

## Checkpoint Information

- **Checkpoint Age:** ${checkpoint_hours} hours
- **Last Completed Step:** ${LAST_COMPLETED_STEP}
- **Git Branch:** ${GIT_BRANCH}
- **Git Commit:** ${GIT_COMMIT}

---

## Completed Steps (from checkpoint)

EOF
    
    for step_num in $(seq 0 $LAST_COMPLETED_STEP); do
        local step_var="STEP_${step_num}_STATUS"
        local status="${!step_var:-UNKNOWN}"
        echo "- **Step ${step_num}:** ${status}" >> "$resume_report"
    done
    
    cat >> "$resume_report" << EOF

---

## Remaining Steps

EOF
    
    for step_num in $(seq $next_step 12); do
        echo "- **Step ${step_num}:** Pending execution" >> "$resume_report"
    done
    
    cat >> "$resume_report" << EOF

---

**Generated by:** Checkpoint Resume System v1.0.3
EOF
    
    print_success "Resume report saved: $resume_report"
    return 0
}

# Cleanup old checkpoints (older than 7 days)
cleanup_old_checkpoints() {
    if [[ ! -d "$CHECKPOINT_DIR" ]]; then
        return 0
    fi
    
    local deleted_count=0
    while IFS= read -r checkpoint_file; do
        if [[ -f "$checkpoint_file" ]]; then
            rm -f "$checkpoint_file"
            ((deleted_count++)) || true
        fi
    done < <(find "$CHECKPOINT_DIR" -name "*.checkpoint" -type f -mtime +7 2>/dev/null)
    
    if [[ $deleted_count -gt 0 ]]; then
        print_info "Cleaned up ${deleted_count} old checkpoint(s)"
        log_to_workflow "INFO" "Cleaned up ${deleted_count} checkpoints older than 7 days"
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export all optimization functions
export -f should_skip_step_by_impact
export -f analyze_change_impact
export -f execute_parallel_tracks
export -f generate_parallel_tracks_report
export -f execute_parallel_validation
export -f save_checkpoint
export -f load_checkpoint
export -f cleanup_old_checkpoints
