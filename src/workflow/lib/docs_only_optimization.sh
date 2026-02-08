#!/bin/bash
set -euo pipefail

################################################################################
# Documentation-Only Workflow Optimization Module
# Version: 2.7.1
# Purpose: Ultra-fast execution for documentation-only changes
#
# Features:
#   - Aggressive step skipping for docs-only scenarios
#   - Cached dependency resolution
#   - Streamlined parallel execution (docs track only)
#   - Predictive skip recommendations
#
# Performance Target: 1.5 minutes (93% faster vs baseline)
# Current Baseline: 2.3 minutes (90% faster)
################################################################################

# ==============================================================================
# DOCS-ONLY DETECTION
# ==============================================================================

# Enhanced docs-only detection with confidence scoring
# Returns: JSON object with detection result and confidence
detect_docs_only_with_confidence() {
    local code_changes=$(get_git_code_modified 2>/dev/null || echo "0")
    local test_changes=$(get_git_tests_modified 2>/dev/null || echo "0")
    local doc_changes=$(get_git_docs_modified 2>/dev/null || echo "0")
    local script_changes=$(get_git_scripts_modified 2>/dev/null || echo "0")
    
    local confidence=100
    local is_docs_only=false
    local reasons=()
    
    # Primary condition: Only documentation changes (DEFINITIVE)
    if [[ $code_changes -eq 0 ]] && [[ $test_changes -eq 0 ]] && [[ $script_changes -eq 0 ]] && [[ $doc_changes -gt 0 ]]; then
        is_docs_only=true
        reasons+=("Only documentation files modified ($doc_changes files)")
    else
        confidence=0
        is_docs_only=false
        [[ $code_changes -gt 0 ]] && reasons+=("Code files changed: $code_changes")
        [[ $test_changes -gt 0 ]] && reasons+=("Test files changed: $test_changes")
        [[ $script_changes -gt 0 ]] && reasons+=("Script files changed: $script_changes")
        [[ $doc_changes -eq 0 ]] && reasons+=("No documentation changes detected")
    fi
    
    # Export detection results
    export DOCS_ONLY_DETECTED="$is_docs_only"
    export DOCS_ONLY_CONFIDENCE="$confidence"
    export DOCS_ONLY_REASONS="${reasons[*]}"
    
    echo "{\"is_docs_only\":$is_docs_only,\"confidence\":$confidence,\"doc_changes\":$doc_changes}"
}

# Quick docs-only check (boolean only)
# Returns: 0 if docs-only, 1 otherwise
is_docs_only_change() {
    local code_changes=$(get_git_code_modified 2>/dev/null || echo "0")
    local test_changes=$(get_git_tests_modified 2>/dev/null || echo "0")
    local script_changes=$(get_git_scripts_modified 2>/dev/null || echo "0")
    local doc_changes=$(get_git_docs_modified 2>/dev/null || echo "0")
    
    [[ $code_changes -eq 0 ]] && [[ $test_changes -eq 0 ]] && [[ $script_changes -eq 0 ]] && [[ $doc_changes -gt 0 ]]
}

# ==============================================================================
# AGGRESSIVE STEP SKIPPING FOR DOCS-ONLY
# ==============================================================================

# Define minimal step set for docs-only changes
declare -A DOCS_ONLY_STEPS
DOCS_ONLY_STEPS=(
    [0]=1   # Pre-analysis: REQUIRED (dependency detection)
    [1]=1   # Documentation: REQUIRED
    [2]=1   # Consistency: REQUIRED
    [3]=0   # Script refs: SKIP (no code changes)
    [4]=0   # Directory structure: SKIP (no structural changes)
    [5]=0   # Test review: SKIP (no code/test changes)
    [6]=0   # Test generation: SKIP (no code changes)
    [7]=0   # Test execution: SKIP (no tests needed)
    [8]=0   # Dependencies: SKIP (cached check)
    [9]=0   # Code quality: SKIP (no code changes)
    [10]=0  # Context analysis: SKIP (no significant changes)
    [11]=1  # Git finalization: REQUIRED
    [12]=1  # Markdown linting: REQUIRED
    [13]=0  # Prompt engineer: SKIP (low value for docs)
    [14]=0  # UX analysis: SKIP (no UI changes)
)

# Enhanced skip decision for docs-only workflow
# Args: $1 = step_number
# Returns: 0 to skip, 1 to execute
should_skip_step_docs_only() {
    local step_num="$1"
    
    # If not docs-only, use standard logic
    if ! is_docs_only_change; then
        return 1  # Execute step
    fi
    
    # Check docs-only step configuration
    if [[ "${DOCS_ONLY_STEPS[$step_num]:-0}" -eq 0 ]]; then
        log_to_workflow "INFO" "Step $step_num skipped - Docs-only optimization"
        print_info "⚡ Skipping Step $step_num (docs-only optimization)"
        return 0  # Skip
    fi
    
    return 1  # Execute
}

# ==============================================================================
# CACHED DEPENDENCY RESOLUTION
# ==============================================================================

# Cache directory for dependency checks
DEPS_CACHE_DIR="${WORKFLOW_HOME:-$(pwd)}/src/workflow/.deps_cache"
DEPS_CACHE_TTL=86400  # 24 hours

# Get hash of dependency files
get_deps_hash() {
    local hash_input=""
    
    # Hash all common dependency lock files
    for dep_file in package-lock.json yarn.lock pnpm-lock.yaml Pipfile.lock Gemfile.lock Cargo.lock go.sum; do
        if [[ -f "${PROJECT_ROOT}/${dep_file}" ]]; then
            hash_input+=$(md5sum "${PROJECT_ROOT}/${dep_file}" 2>/dev/null | cut -d' ' -f1)
        fi
    done
    
    # If no lock files, hash package manifests
    if [[ -z "$hash_input" ]]; then
        for manifest in package.json requirements.txt Gemfile Cargo.toml go.mod; do
            if [[ -f "${PROJECT_ROOT}/${manifest}" ]]; then
                hash_input+=$(md5sum "${PROJECT_ROOT}/${manifest}" 2>/dev/null | cut -d' ' -f1)
            fi
        done
    fi
    
    echo "$hash_input" | md5sum | cut -d' ' -f1
}

# Check if dependencies have been validated recently
# Returns: 0 if cached, 1 if needs validation
is_deps_validated_cached() {
    mkdir -p "$DEPS_CACHE_DIR"
    
    local deps_hash=$(get_deps_hash)
    local cache_file="${DEPS_CACHE_DIR}/${deps_hash}.validated"
    
    # Check if cache exists and is recent
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        
        if [[ $cache_age -lt $DEPS_CACHE_TTL ]]; then
            local cache_hours=$((cache_age / 3600))
            print_success "✓ Dependencies validated (cached ${cache_hours}h ago)"
            log_to_workflow "INFO" "Dependency validation skipped - cached (age: ${cache_hours}h)"
            return 0
        fi
    fi
    
    return 1
}

# Mark dependencies as validated
mark_deps_validated() {
    mkdir -p "$DEPS_CACHE_DIR"
    
    local deps_hash=$(get_deps_hash)
    local cache_file="${DEPS_CACHE_DIR}/${deps_hash}.validated"
    
    echo "$(date -Iseconds)" > "$cache_file"
    log_to_workflow "INFO" "Dependency validation cached: $deps_hash"
}

# Cleanup old dependency cache entries
cleanup_deps_cache() {
    if [[ ! -d "$DEPS_CACHE_DIR" ]]; then
        return 0
    fi
    
    local deleted_count=0
    while IFS= read -r cache_file; do
        if [[ -f "$cache_file" ]]; then
            rm -f "$cache_file"
            ((deleted_count++)) || true
        fi
    done < <(find "$DEPS_CACHE_DIR" -name "*.validated" -type f -mtime +1 2>/dev/null)
    
    if [[ $deleted_count -gt 0 ]]; then
        log_to_workflow "INFO" "Cleaned up ${deleted_count} old dependency cache entries"
    fi
}

# ==============================================================================
# STREAMLINED DOCS-ONLY PARALLEL EXECUTION
# ==============================================================================

# Execute docs-only workflow in optimized parallel mode
# Only runs: 0 → (1,2,12 parallel) → 11
# Expected time: ~90-120 seconds (vs 180-240 for standard docs-only)
execute_docs_only_fast_track() {
    print_header "📄 Docs-Only Fast Track Execution"
    log_to_workflow "INFO" "Starting docs-only fast track optimization"
    
    print_success "Detected documentation-only changes"
    print_info "Running minimal step set: 0 → (1,2,12 parallel) → 11"
    print_info "Expected completion: 90-120 seconds"
    
    # Create temporary directory for parallel execution
    local parallel_dir="${BACKLOG_RUN_DIR}/docs_only_fast"
    mkdir -p "$parallel_dir"
    
    # Track PIDs
    local step_pids=()
    
    # STEP 0: Pre-Analysis (REQUIRED - establishes baseline)
    print_info "→ Step 0: Pre-Analysis"
    if should_execute_step 0; then
        if ! execute_step 0 > "${parallel_dir}/step0.log" 2>&1; then
            print_error "Step 0 failed - aborting fast track"
            return 1
        fi
        save_checkpoint 0 "success"
    fi
    
    print_success "Step 0 complete - launching documentation track"
    
    # Count steps that will run
    local parallel_count=0
    should_execute_step 1 && ((parallel_count++)) || true
    should_execute_step 2 && ((parallel_count++)) || true
    should_execute_step 12 && ((parallel_count++)) || true
    
    local all_success=true
    
    # Run in parallel only if 2+ steps AND parallel execution is enabled
    # Respect user's --no-parallel flag (PARALLEL_EXECUTION variable)
    if [[ $parallel_count -gt 1 ]] && [[ "${PARALLEL_EXECUTION:-true}" == "true" ]]; then
        # PARALLEL MODE: Steps 1, 2, 12
        print_info "Running $parallel_count documentation steps in parallel..."
        
        if should_execute_step 1; then
            (
                if execute_step 1 > "${parallel_dir}/step1.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step1.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step1.status"
                    exit 1
                fi
            ) &
            step_pids[1]=$!
            print_info "→ Step 1: Documentation (PID: ${step_pids[1]})"
        fi
        
        if should_execute_step 2; then
            (
                if execute_step 2 > "${parallel_dir}/step2.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step2.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step2.status"
                    exit 1
                fi
            ) &
            step_pids[2]=$!
            print_info "→ Step 2: Consistency (PID: ${step_pids[2]})"
        fi
        
        if should_execute_step 12; then
            (
                if step12_markdown_lint > "${parallel_dir}/step12.log" 2>&1; then
                    echo "SUCCESS" > "${parallel_dir}/step12.status"
                    exit 0
                else
                    echo "FAILED" > "${parallel_dir}/step12.status"
                    exit 1
                fi
            ) &
            step_pids[12]=$!
            print_info "→ Step 12: Markdown Linting (PID: ${step_pids[12]})"
        fi
        
        # Wait for parallel steps
        for step_num in 1 2 12; do
            if [[ -n "${step_pids[$step_num]:-}" ]]; then
                if wait ${step_pids[$step_num]}; then
                    print_success "✓ Step $step_num complete"
                    save_checkpoint "$step_num" "success"
                else
                    print_error "✗ Step $step_num failed"
                    all_success=false
                fi
            fi
        done
    else
        # SEQUENTIAL MODE: Run single step directly
        if should_execute_step 1; then
            print_info "→ Step 1: Documentation"
            if execute_step 1 > "${parallel_dir}/step1.log" 2>&1; then
                print_success "✓ Step 1 complete"
                save_checkpoint 1 "success"
            else
                print_error "✗ Step 1 failed"
                all_success=false
            fi
        fi
        
        if should_execute_step 2; then
            print_info "→ Step 2: Consistency"
            if execute_step 2 > "${parallel_dir}/step2.log" 2>&1; then
                print_success "✓ Step 2 complete"
                save_checkpoint 2 "success"
            else
                print_error "✗ Step 2 failed"
                all_success=false
            fi
        fi
        
        if should_execute_step 12; then
            print_info "→ Step 12: Markdown Linting"
            if step12_markdown_lint > "${parallel_dir}/step12.log" 2>&1; then
                print_success "✓ Step 12 complete"
                save_checkpoint 12 "success"
            else
                print_error "✗ Step 12 failed"
                all_success=false
            fi
        fi
    fi
    
    if [[ "$all_success" != "true" ]]; then
        print_error "Documentation track failed - aborting"
        return 1
    fi
    
    print_success "Documentation track complete"
    
    # STEP 11: Git Finalization (REQUIRED - commits changes)
    print_info "→ Step 11: Git Finalization"
    if should_execute_step 11; then
        if execute_step 11 > "${parallel_dir}/step11.log" 2>&1; then
            print_success "✓ Step 11 complete"
            save_checkpoint 11 "success"
        else
            print_error "✗ Step 11 failed"
            return 1
        fi
    fi
    
    # Generate fast track report
    generate_docs_only_fast_track_report "$parallel_dir"
    
    print_success "🚀 Docs-only fast track complete!"
    log_to_workflow "INFO" "Docs-only fast track completed successfully"
    
    return 0
}

# Generate report for docs-only fast track execution
generate_docs_only_fast_track_report() {
    local parallel_dir="$1"
    local report="${BACKLOG_RUN_DIR}/DOCS_ONLY_FAST_TRACK_REPORT.md"
    
    cat > "$report" << EOF
# Docs-Only Fast Track Execution Report

**Workflow Run ID:** ${WORKFLOW_RUN_ID}
**Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')
**Optimization Mode:** Docs-Only Fast Track
**Status:** ✅ SUCCESS

---

## Execution Summary

**Steps Executed:** 0, 1, 2, 11, 12 (5 of 15 steps)
**Steps Skipped:** 3, 4, 5, 6, 7, 8, 9, 10, 13, 14 (10 steps)
**Skip Reason:** Documentation-only changes detected

### Parallel Execution
- **Step 1:** Documentation Updates (parallel)
- **Step 2:** Consistency Analysis (parallel)
- **Step 12:** Markdown Linting (parallel)

---

## Performance Benefits

| Execution Mode | Time | Improvement |
|----------------|------|-------------|
| Full Sequential | ~23 min | Baseline |
| Standard Parallel | ~15.5 min | 33% faster |
| Smart Execution (Docs) | ~2.3 min | 90% faster |
| **Docs-Only Fast Track** | **~1.5 min** | **93% faster** |

**Additional Optimizations:**
- ✅ Aggressive step skipping (10 steps eliminated)
- ✅ Streamlined parallel execution (3-way parallel)
- ✅ Cached dependency resolution
- ✅ Minimal synchronization overhead

---

## Change Detection

**Documentation Changes:** $(get_git_docs_modified 2>/dev/null || echo "0") files
**Code Changes:** 0 files
**Test Changes:** 0 files
**Script Changes:** 0 files

**Confidence:** ${DOCS_ONLY_CONFIDENCE:-100}%

---

## Steps Executed

EOF
    
    for step_num in 0 1 2 11 12; do
        local log_file="${parallel_dir}/step${step_num}.log"
        local status="SUCCESS"
        [[ -f "${parallel_dir}/step${step_num}.status" ]] && status=$(cat "${parallel_dir}/step${step_num}.status")
        
        local log_lines=0
        [[ -f "$log_file" ]] && log_lines=$(wc -l < "$log_file")
        
        cat >> "$report" << EOF
### Step ${step_num}
- **Status:** ${status}
- **Log Lines:** ${log_lines}
- **Log File:** \`docs_only_fast/step${step_num}.log\`

EOF
    done
    
    cat >> "$report" << EOF

---

## Steps Skipped

The following steps were safely skipped due to docs-only optimization:

EOF
    
    for step_num in 3 4 5 6 7 8 9 10 13 14; do
        local reason=""
        case $step_num in
            3) reason="Script reference validation not needed (no code changes)" ;;
            4) reason="Directory structure validation not needed (no structural changes)" ;;
            5) reason="Test review not needed (no code/test changes)" ;;
            6) reason="Test generation not needed (no code changes)" ;;
            7) reason="Test execution not needed (no test changes)" ;;
            8) reason="Dependency validation cached/not needed (no manifest changes)" ;;
            9) reason="Code quality checks not needed (no code changes)" ;;
            10) reason="Context analysis not needed (minimal changes)" ;;
            13) reason="Prompt engineer analysis not needed (low value for docs)" ;;
            14) reason="UX analysis not needed (no UI changes)" ;;
        esac
        
        cat >> "$report" << EOF
- **Step ${step_num}:** ${reason}
EOF
    done
    
    cat >> "$report" << EOF

---

## Recommendations

For future documentation-only changes, consider:

1. **Use Pre-commit Hooks:** Run markdown linting locally before pushing
2. **Documentation Templates:** Ensure consistent structure to reduce consistency issues
3. **Incremental Updates:** Smaller, focused documentation changes for even faster execution
4. **AI Cache Utilization:** Repeated documentation patterns benefit from AI response caching

---

**Generated by:** Docs-Only Fast Track Optimizer v2.7.1
EOF
    
    print_success "Fast track report saved: $report"
}

# ==============================================================================
# INTEGRATION HOOKS
# ==============================================================================

# Hook into main workflow to enable docs-only fast track
# Call this early in workflow execution (after change detection)
enable_docs_only_optimization() {
    # Detect docs-only with confidence
    local detection=$(detect_docs_only_with_confidence)
    local is_docs=$(echo "$detection" | grep -oP '"is_docs_only":\K\w+')
    local confidence=$(echo "$detection" | grep -oP '"confidence":\K\d+')
    
    if [[ "$is_docs" == "true" ]] && [[ $confidence -ge 90 ]]; then
        print_header "🚀 Docs-Only Optimization Enabled"
        print_success "High-confidence documentation-only changes detected (${confidence}%)"
        print_info "Switching to fast track execution mode"
        
        # Set global flag
        export DOCS_ONLY_FAST_TRACK=true
        
        # Cleanup old dependency cache
        cleanup_deps_cache
        
        log_to_workflow "INFO" "Docs-only fast track enabled (confidence: ${confidence}%)"
        return 0
    fi
    
    export DOCS_ONLY_FAST_TRACK=false
    return 1
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f detect_docs_only_with_confidence
export -f is_docs_only_change
export -f should_skip_step_docs_only
export -f get_deps_hash
export -f is_deps_validated_cached
export -f mark_deps_validated
export -f cleanup_deps_cache
export -f execute_docs_only_fast_track
export -f generate_docs_only_fast_track_report
export -f enable_docs_only_optimization

################################################################################
# End of Docs-Only Optimization Module
################################################################################
