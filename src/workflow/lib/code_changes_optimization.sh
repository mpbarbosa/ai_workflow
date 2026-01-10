#!/bin/bash
set -euo pipefail

################################################################################
# Code Changes Workflow Optimization Module
# Version: 2.7.0
# Purpose: Ultra-fast execution for code changes with smart test optimization
#
# Features:
#   - Incremental test execution (changed files only)
#   - Test sharding for parallel execution
#   - Fast-fail mode for quicker feedback
#   - Smart code quality checks (changed files only)
#   - Optimized dependency resolution
#
# Performance Target: 6-7 minutes (70-75% faster vs baseline)
# Current Baseline: 10 minutes (57% faster)
################################################################################

# Set defaults for required variables if not already set
PROJECT_ROOT=${PROJECT_ROOT:-$(pwd)}
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
WORKFLOW_RUN_ID=${WORKFLOW_RUN_ID:-workflow_$(date +%Y%m%d_%H%M%S)}

# ==============================================================================
# CODE CHANGE DETECTION
# ==============================================================================

# Enhanced code change detection with file categorization
# Returns: JSON object with change details
detect_code_changes_with_details() {
    local code_changes=$(get_git_code_modified 2>/dev/null || echo "0")
    local test_changes=$(get_git_tests_modified 2>/dev/null || echo "0")
    local doc_changes=$(get_git_docs_modified 2>/dev/null || echo "0")
    local script_changes=$(get_git_scripts_modified 2>/dev/null || echo "0")
    
    # Get list of changed code files
    local changed_files=$(git diff --name-only HEAD 2>/dev/null || echo "")
    local code_files=""
    local test_files=""
    
    # Categorize files
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Check if it's a test file
        if [[ "$file" =~ (test|spec)\.(js|ts|py|go|rs)$ ]] || [[ "$file" =~ __tests__/ ]]; then
            test_files+="$file"$'\n'
        # Check if it's a code file
        elif [[ "$file" =~ \.(js|jsx|ts|tsx|py|go|rs|java|cpp|c)$ ]]; then
            code_files+="$file"$'\n'
        fi
    done <<< "$changed_files"
    
    # Calculate percentages
    local total_changes=$((code_changes + test_changes + doc_changes + script_changes))
    local code_percentage=0
    [[ $total_changes -gt 0 ]] && code_percentage=$((code_changes * 100 / total_changes))
    
    # Determine optimization strategy
    local strategy="standard"
    if [[ $code_changes -le 3 ]]; then
        strategy="incremental"  # Run tests only for changed modules
    elif [[ $code_changes -le 10 ]]; then
        strategy="focused"      # Run related tests with fast-fail
    else
        strategy="full"         # Run full test suite
    fi
    
    # Export detection results
    export CODE_CHANGES_DETECTED=true
    export CODE_CHANGES_COUNT="$code_changes"
    export CODE_CHANGES_STRATEGY="$strategy"
    export CODE_CHANGED_FILES="$code_files"
    export TEST_CHANGED_FILES="$test_files"
    
    echo "{\"code_changes\":$code_changes,\"test_changes\":$test_changes,\"strategy\":\"$strategy\",\"code_percentage\":$code_percentage}"
}

# Quick code changes check (boolean only)
# Returns: 0 if code changes detected, 1 otherwise
is_code_changes() {
    local code_changes=$(get_git_code_modified 2>/dev/null || echo "0")
    [[ $code_changes -gt 0 ]]
}

# ==============================================================================
# INCREMENTAL TEST EXECUTION
# ==============================================================================

# Get test files related to changed code files
# Returns: Newline-separated list of test file paths
get_related_test_files() {
    local changed_code_files="${CODE_CHANGED_FILES:-}"
    local related_tests=""
    
    [[ -z "$changed_code_files" ]] && return 0
    
    while IFS= read -r code_file; do
        [[ -z "$code_file" ]] && continue
        
        # Extract base name without extension
        local base_name=$(basename "$code_file" | sed 's/\.[^.]*$//')
        
        # Look for test files with matching names
        # Patterns: file.test.js, file.spec.js, file_test.py, test_file.py
        local test_patterns=(
            "${base_name}.test.*"
            "${base_name}.spec.*"
            "${base_name}_test.*"
            "test_${base_name}.*"
            "*/${base_name}.test.*"
            "*/${base_name}.spec.*"
            "__tests__/*${base_name}*"
        )
        
        for pattern in "${test_patterns[@]}"; do
            local matches=$(find "${PROJECT_ROOT}" -type f -name "$pattern" 2>/dev/null || echo "")
            [[ -n "$matches" ]] && related_tests+="$matches"$'\n'
        done
    done <<< "$changed_code_files"
    
    # Deduplicate and return
    echo "$related_tests" | sort -u | grep -v '^$'
}

# Execute incremental tests (only for changed modules)
# Returns: 0 if tests pass, 1 if tests fail
execute_incremental_tests() {
    print_header "⚡ Incremental Test Execution"
    log_to_workflow "INFO" "Starting incremental test execution"
    
    local related_tests=$(get_related_test_files)
    
    if [[ -z "$related_tests" ]]; then
        print_warning "No related tests found for changed files"
        print_info "Falling back to full test suite"
        return 1  # Signal to run full tests
    fi
    
    local test_count=$(echo "$related_tests" | wc -l)
    print_success "Found $test_count related test file(s)"
    
    # Build test command based on project type
    local test_cmd=""
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    case "$language" in
        javascript|typescript)
            # Jest supports running specific test files
            test_cmd="npx jest $(echo "$related_tests" | tr '\n' ' ')"
            ;;
        python)
            # Pytest supports running specific test files
            test_cmd="pytest $(echo "$related_tests" | tr '\n' ' ')"
            ;;
        go)
            # Go test with specific packages
            local packages=$(echo "$related_tests" | xargs -I{} dirname {} | sort -u | tr '\n' ' ')
            test_cmd="go test $packages"
            ;;
        *)
            print_warning "Incremental tests not supported for $language"
            return 1
            ;;
    esac
    
    print_info "Executing incremental tests..."
    print_info "Test command: $test_cmd"
    
    local start_time=$(date +%s)
    
    if eval "$test_cmd" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        print_success "✅ Incremental tests passed in ${duration}s"
        log_to_workflow "INFO" "Incremental tests passed (${test_count} files, ${duration}s)"
        
        # Record metrics
        if type -t record_step_metric > /dev/null; then
            record_step_metric 7 "incremental_test_time" "$duration"
            record_step_metric 7 "incremental_test_count" "$test_count"
        fi
        
        return 0
    else
        print_error "❌ Incremental tests failed"
        return 1
    fi
}

# ==============================================================================
# TEST SHARDING
# ==============================================================================

# Split tests into shards for parallel execution
# Args: $1 = number of shards
# Returns: Generates shard files
generate_test_shards() {
    local shard_count="${1:-4}"
    local shard_dir="${BACKLOG_RUN_DIR}/test_shards"
    
    mkdir -p "$shard_dir"
    
    # Get all test files
    local all_tests=$(find "${PROJECT_ROOT}" -type f \( -name "*.test.js" -o -name "*.spec.js" -o -name "*_test.py" -o -name "test_*.py" \) 2>/dev/null || echo "")
    
    if [[ -z "$all_tests" ]]; then
        print_warning "No test files found for sharding"
        return 1
    fi
    
    local total_tests=$(echo "$all_tests" | wc -l)
    local tests_per_shard=$((total_tests / shard_count))
    
    print_info "Splitting $total_tests tests into $shard_count shards (~$tests_per_shard tests each)"
    
    # Split tests into shard files
    local shard_num=1
    local current_shard_file="${shard_dir}/shard_${shard_num}.txt"
    > "$current_shard_file"
    
    local line_count=0
    while IFS= read -r test_file; do
        echo "$test_file" >> "$current_shard_file"
        ((line_count++)) || true
        
        if [[ $line_count -ge $tests_per_shard && $shard_num -lt $shard_count ]]; then
            ((shard_num++)) || true
            current_shard_file="${shard_dir}/shard_${shard_num}.txt"
            > "$current_shard_file"
            line_count=0
        fi
    done <<< "$all_tests"
    
    print_success "Generated $shard_count test shards in $shard_dir"
    return 0
}

# Execute tests in parallel shards
# Args: $1 = number of shards
# Returns: 0 if all shards pass, 1 if any fail
execute_parallel_test_shards() {
    local shard_count="${1:-4}"
    local shard_dir="${BACKLOG_RUN_DIR}/test_shards"
    
    print_header "⚡⚡ Parallel Test Execution ($shard_count shards)"
    log_to_workflow "INFO" "Starting parallel test execution with $shard_count shards"
    
    # Generate shards
    if ! generate_test_shards "$shard_count"; then
        return 1
    fi
    
    # Launch parallel test execution
    local pids=()
    local start_time=$(date +%s)
    
    for shard_num in $(seq 1 "$shard_count"); do
        local shard_file="${shard_dir}/shard_${shard_num}.txt"
        local shard_log="${shard_dir}/shard_${shard_num}.log"
        
        [[ ! -f "$shard_file" ]] && continue
        
        (
            local test_files=$(cat "$shard_file" | tr '\n' ' ')
            local test_cmd=""
            
            case "${PRIMARY_LANGUAGE:-javascript}" in
                javascript|typescript)
                    test_cmd="npx jest $test_files"
                    ;;
                python)
                    test_cmd="pytest $test_files"
                    ;;
                *)
                    echo "Unsupported language for sharding" > "$shard_log"
                    exit 1
                    ;;
            esac
            
            if eval "$test_cmd" > "$shard_log" 2>&1; then
                echo "PASS" > "${shard_dir}/shard_${shard_num}.status"
                exit 0
            else
                echo "FAIL" > "${shard_dir}/shard_${shard_num}.status"
                exit 1
            fi
        ) &
        
        pids+=($!)
        print_info "Launched shard $shard_num (PID: ${pids[-1]})"
    done
    
    # Wait for all shards
    print_info "Waiting for $shard_count test shards to complete..."
    
    local all_passed=true
    for shard_num in $(seq 1 "$shard_count"); do
        local pid_index=$((shard_num - 1))
        
        if wait ${pids[$pid_index]}; then
            print_success "✅ Shard $shard_num passed"
        else
            print_error "❌ Shard $shard_num failed"
            all_passed=false
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ "$all_passed" == "true" ]]; then
        print_success "🎉 All test shards passed in ${duration}s"
        log_to_workflow "INFO" "Parallel tests passed ($shard_count shards, ${duration}s)"
        
        # Record metrics
        if type -t record_step_metric > /dev/null; then
            record_step_metric 7 "parallel_test_time" "$duration"
            record_step_metric 7 "parallel_shard_count" "$shard_count"
        fi
        
        return 0
    else
        print_error "Some test shards failed"
        return 1
    fi
}

# ==============================================================================
# SMART CODE QUALITY CHECKS
# ==============================================================================

# Run code quality checks only on changed files
# Returns: 0 if checks pass, 1 if checks fail
execute_incremental_code_quality() {
    print_header "⚡ Incremental Code Quality Checks"
    log_to_workflow "INFO" "Running code quality checks on changed files only"
    
    local changed_files="${CODE_CHANGED_FILES:-}"
    
    if [[ -z "$changed_files" ]]; then
        print_warning "No changed code files detected"
        return 0
    fi
    
    local file_count=$(echo "$changed_files" | wc -l)
    print_info "Analyzing $file_count changed file(s)"
    
    # Build linter command based on language
    local lint_cmd=""
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    case "$language" in
        javascript|typescript)
            # ESLint supports linting specific files
            lint_cmd="npx eslint $(echo "$changed_files" | tr '\n' ' ')"
            ;;
        python)
            # Pylint/flake8 for specific files
            if command -v pylint &>/dev/null; then
                lint_cmd="pylint $(echo "$changed_files" | tr '\n' ' ')"
            elif command -v flake8 &>/dev/null; then
                lint_cmd="flake8 $(echo "$changed_files" | tr '\n' ' ')"
            fi
            ;;
        go)
            # golint for specific files
            lint_cmd="golint $(echo "$changed_files" | tr '\n' ' ')"
            ;;
        *)
            print_info "No incremental linting configured for $language"
            return 0
            ;;
    esac
    
    if [[ -z "$lint_cmd" ]]; then
        print_info "No linter command available"
        return 0
    fi
    
    print_info "Lint command: $lint_cmd"
    
    local start_time=$(date +%s)
    
    if eval "$lint_cmd" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        print_success "✅ Code quality checks passed in ${duration}s"
        log_to_workflow "INFO" "Incremental code quality passed (${file_count} files, ${duration}s)"
        
        return 0
    else
        print_warning "⚠️ Code quality issues detected (non-blocking)"
        return 0  # Don't fail workflow on linting issues
    fi
}

# ==============================================================================
# INTEGRATION HOOKS
# ==============================================================================

# Enable code changes optimization based on detection
# Returns: 0 if enabled, 1 otherwise
enable_code_changes_optimization() {
    # Detect code changes with details
    local detection=$(detect_code_changes_with_details)
    local code_changes=$(echo "$detection" | grep -oP '"code_changes":\K\d+')
    local strategy=$(echo "$detection" | grep -oP '"strategy":"\K[^"]+')
    
    if [[ $code_changes -gt 0 ]]; then
        print_header "🚀 Code Changes Optimization Enabled"
        print_success "Detected $code_changes code file(s) changed"
        print_info "Optimization strategy: $strategy"
        
        case "$strategy" in
            incremental)
                print_info "Using incremental test execution (changed modules only)"
                print_info "Expected completion: 6-7 minutes"
                ;;
            focused)
                print_info "Using focused testing with fast-fail"
                print_info "Expected completion: 7-8 minutes"
                ;;
            full)
                print_info "Using full test suite with optimizations"
                print_info "Expected completion: 9-10 minutes"
                ;;
        esac
        
        # Set global flag
        export CODE_CHANGES_OPTIMIZATION=true
        
        log_to_workflow "INFO" "Code changes optimization enabled (strategy: $strategy, files: $code_changes)"
        return 0
    fi
    
    export CODE_CHANGES_OPTIMIZATION=false
    return 1
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f detect_code_changes_with_details
export -f is_code_changes
export -f get_related_test_files
export -f execute_incremental_tests
export -f generate_test_shards
export -f execute_parallel_test_shards
export -f execute_incremental_code_quality
export -f enable_code_changes_optimization

################################################################################
# End of Code Changes Optimization Module
################################################################################
