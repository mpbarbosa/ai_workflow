#!/bin/bash
set -euo pipefail

################################################################################
# Performance Optimization Module
# Purpose: Parallel execution, caching, and optimized operations
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# ==============================================================================
# PARALLEL EXECUTION
# ==============================================================================

# Execute commands in parallel with job control
# Usage: parallel_execute <max_jobs> <command1> <command2> ...
# Returns: 0 if all succeed, 1 if any fail
parallel_execute() {
    local max_jobs="$1"
    shift
    local commands=("$@")
    
    local pids=()
    local results=()
    local job_count=0
    
    for cmd in "${commands[@]}"; do
        # Wait if we've hit max parallel jobs
        while [[ $job_count -ge $max_jobs ]]; do
            # Wait for any job to complete
            wait -n
            ((job_count--))
        done
        
        # Start command in background
        eval "$cmd" &
        pids+=($!)
        ((job_count++))
    done
    
    # Wait for all remaining jobs
    local failed=0
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            ((failed++))
        fi
    done
    
    return $failed
}

# Execute workflow steps in parallel (safe subset)
# Usage: parallel_workflow_steps <step1_func> <step2_func> ...
parallel_workflow_steps() {
    local steps=("$@")
    local pids=()
    local failed=0
    
    print_info "Executing ${#steps[@]} steps in parallel..."
    
    for step_func in "${steps[@]}"; do
        $step_func &
        pids+=($!)
    done
    
    # Wait and track failures
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        print_success "All parallel steps completed successfully"
        return 0
    else
        print_error "$failed parallel step(s) failed"
        return 1
    fi
}

# ==============================================================================
# OPTIMIZED FIND OPERATIONS
# ==============================================================================

# Fast find with optimal filters
# Usage: fast_find <directory> <pattern> [max_depth] [exclude_dirs...]
fast_find() {
    local dir="$1"
    local pattern="$2"
    local max_depth="${3:-5}"
    shift 3
    local excludes=("$@")
    
    # Build exclusion list
    local exclude_args=()
    for exclude in "${excludes[@]}"; do
        exclude_args+=(-path "*/$exclude" -prune -o)
    done
    
    # Optimized find with pruning
    find "$dir" -maxdepth "$max_depth" \
        "${exclude_args[@]}" \
        -type f -name "$pattern" -print 2>/dev/null
}

# Find modified files faster using git
# Usage: fast_find_modified [since_commit]
fast_find_modified() {
    local since="${1:-HEAD~1}"
    
    # Use git ls-files for tracked files (much faster than find)
    if [[ -d .git ]]; then
        git diff --name-only "$since" 2>/dev/null
    else
        # Fallback to find for non-git directories
        find . -type f -mtime -1 2>/dev/null
    fi
}

# ==============================================================================
# OPTIMIZED GREP OPERATIONS
# ==============================================================================

# Fast grep with smart filtering
# Usage: fast_grep <pattern> <directory> [file_pattern] [exclude_dirs...]
fast_grep() {
    local pattern="$1"
    local dir="${2:-.}"
    local file_pattern="${3:-*}"
    shift 3
    local excludes=("$@")
    
    # Build exclusion arguments
    local exclude_args=()
    for exclude in "${excludes[@]}"; do
        exclude_args+=(--exclude-dir="$exclude")
    done
    
    # Use ripgrep if available (10-100x faster)
    if command -v rg &>/dev/null; then
        rg --no-heading --line-number "$pattern" \
            --glob "$file_pattern" \
            "${exclude_args[@]}" \
            "$dir" 2>/dev/null
    else
        # Fallback to GNU grep with optimizations
        grep -r -n \
            --include="$file_pattern" \
            "${exclude_args[@]}" \
            "$pattern" \
            "$dir" 2>/dev/null
    fi
}

# Count pattern matches efficiently
# Usage: fast_grep_count <pattern> <directory> [file_pattern]
fast_grep_count() {
    local pattern="$1"
    local dir="${2:-.}"
    local file_pattern="${3:-*}"
    
    if command -v rg &>/dev/null; then
        rg --count-matches "$pattern" \
            --glob "$file_pattern" \
            "$dir" 2>/dev/null | \
            awk -F: '{sum+=$2} END {print sum+0}'
    else
        grep -r --include="$file_pattern" \
            -c "$pattern" "$dir" 2>/dev/null | \
            awk -F: '{sum+=$2} END {print sum+0}'
    fi
}

# ==============================================================================
# CACHING MECHANISMS
# ==============================================================================

# Simple file-based cache with TTL
# Usage: cache_get <key>
# Returns: cached value if exists and not expired
cache_get() {
    local key="$1"
    local cache_file="/tmp/workflow_cache_${key//\//_}"
    local ttl="${CACHE_TTL:-300}"  # 5 minutes default
    
    if [[ -f "$cache_file" ]]; then
        local age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))
        
        if [[ $age -lt $ttl ]]; then
            cat "$cache_file"
            return 0
        else
            # Expired
            rm -f "$cache_file"
        fi
    fi
    
    return 1
}

# Store value in cache
# Usage: cache_set <key> <value>
cache_set() {
    local key="$1"
    local value="$2"
    local cache_file="/tmp/workflow_cache_${key//\//_}"
    
    echo "$value" > "$cache_file"
}

# Clear cache for key or all
# Usage: cache_clear [key]
cache_clear() {
    local key="${1:-}"
    
    if [[ -n "$key" ]]; then
        local cache_file="/tmp/workflow_cache_${key//\//_}"
        rm -f "$cache_file"
    else
        rm -f /tmp/workflow_cache_* 2>/dev/null
    fi
}

# Memoize function results
# Usage: memoize <function_name> [args...]
memoize() {
    local func="$1"
    shift
    local args="$*"
    local cache_key="${func}_$(echo "$args" | md5sum | cut -d' ' -f1)"
    
    # Check cache
    if result=$(cache_get "$cache_key"); then
        echo "$result"
        return 0
    fi
    
    # Execute and cache
    local result
    result=$($func "$@")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        cache_set "$cache_key" "$result"
    fi
    
    echo "$result"
    return $exit_code
}

# ==============================================================================
# COMMAND OPTIMIZATION
# ==============================================================================

# Batch multiple git commands
# Usage: batch_git_commands <command1> <command2> ...
batch_git_commands() {
    local commands=("$@")
    local results=()
    
    # Execute all git commands in rapid succession
    for cmd in "${commands[@]}"; do
        results+=("$(git $cmd 2>/dev/null || echo '')")
    done
    
    # Return results as array
    for result in "${results[@]}"; do
        echo "$result"
    done
}

# Optimized file counting
# Usage: fast_file_count <directory> [pattern]
fast_file_count() {
    local dir="$1"
    local pattern="${2:-*}"
    
    # Use find with -printf for count (faster than wc)
    find "$dir" -type f -name "$pattern" -printf '.' 2>/dev/null | wc -c
}

# Optimized directory size
# Usage: fast_dir_size <directory>
fast_dir_size() {
    local dir="$1"
    
    # Use du with optimizations
    du -sh "$dir" 2>/dev/null | cut -f1
}

# ==============================================================================
# PERFORMANCE MONITORING
# ==============================================================================

# Measure command execution time
# Usage: time_command <command> [args...]
time_command() {
    local start_time=$(date +%s%N)
    
    "$@"
    local exit_code=$?
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    print_verbose "Command '$1' took ${duration}ms"
    
    return $exit_code
}

# Profile workflow section
# Usage: profile_section <section_name> <command>
profile_section() {
    local section="$1"
    shift
    local command="$@"
    
    local start=$(date +%s%N)
    
    eval "$command"
    local exit_code=$?
    
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    
    # Log to performance file
    local perf_file="/tmp/workflow_perf_${WORKFLOW_RUN_ID}.log"
    echo "${section},${duration}" >> "$perf_file"
    
    if [[ $duration -gt 1000 ]]; then
        print_warning "Section '$section' took ${duration}ms (>1s)"
    fi
    
    return $exit_code
}

# Generate performance report
# Usage: generate_perf_report
generate_perf_report() {
    local perf_file="/tmp/workflow_perf_${WORKFLOW_RUN_ID}.log"
    
    if [[ ! -f "$perf_file" ]]; then
        print_info "No performance data available"
        return 0
    fi
    
    print_header "Performance Report"
    
    echo -e "${CYAN}Section Performance:${NC}"
    while IFS=',' read -r section duration; do
        local seconds=$(echo "scale=2; $duration / 1000" | bc)
        echo -e "  ${YELLOW}${section}:${NC} ${seconds}s"
    done < "$perf_file" | sort -t: -k2 -rn
    
    local total=$(awk -F',' '{sum+=$2} END {print sum}' "$perf_file")
    local total_seconds=$(echo "scale=2; $total / 1000" | bc)
    
    echo ""
    echo -e "${GREEN}Total Time:${NC} ${total_seconds}s"
}

# ==============================================================================
# BATCH OPERATIONS
# ==============================================================================

# Process files in batches
# Usage: batch_process <batch_size> <command> <file1> <file2> ...
batch_process() {
    local batch_size="$1"
    local command="$2"
    shift 2
    local files=("$@")
    
    local batch=()
    local processed=0
    
    for file in "${files[@]}"; do
        batch+=("$file")
        
        if [[ ${#batch[@]} -ge $batch_size ]]; then
            # Process batch
            $command "${batch[@]}"
            processed=$((processed + ${#batch[@]}))
            batch=()
        fi
    done
    
    # Process remaining
    if [[ ${#batch[@]} -gt 0 ]]; then
        $command "${batch[@]}"
        processed=$((processed + ${#batch[@]}))
    fi
    
    print_info "Processed $processed files in batches of $batch_size"
}

# ==============================================================================
# LAZY EVALUATION
# ==============================================================================

# Lazy load expensive data
# Usage: lazy_load <variable_name> <command>
lazy_load() {
    local var_name="$1"
    local command="$2"
    
    # Check if already loaded
    if [[ -z "${!var_name}" ]]; then
        # Load and export
        eval "$var_name=\"$($command)\""
        export "$var_name"
    fi
    
    echo "${!var_name}"
}

# ==============================================================================
# PARALLEL FILE PROCESSING
# ==============================================================================

# Process files in parallel
# Usage: parallel_file_process <max_jobs> <command> <file1> <file2> ...
parallel_file_process() {
    local max_jobs="$1"
    local command="$2"
    shift 2
    local files=("$@")
    
    local pids=()
    local job_count=0
    
    for file in "${files[@]}"; do
        # Wait if at max jobs
        while [[ $job_count -ge $max_jobs ]]; do
            wait -n
            ((job_count--))
        done
        
        # Process file in background
        ($command "$file") &
        pids+=($!)
        ((job_count++))
    done
    
    # Wait for all
    local failed=0
    for pid in "${pids[@]}"; do
        wait "$pid" || ((failed++))
    done
    
    return $failed
}

# ==============================================================================
# SMART EXECUTION
# ==============================================================================

# Execute command only if needed (check prerequisites)
# Usage: execute_if_needed <check_command> <execute_command>
execute_if_needed() {
    local check_cmd="$1"
    local exec_cmd="$2"
    
    if eval "$check_cmd" 2>/dev/null; then
        print_verbose "Skipping: prerequisites already met"
        return 0
    fi
    
    print_verbose "Executing: $exec_cmd"
    eval "$exec_cmd"
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f parallel_execute parallel_workflow_steps
export -f fast_find fast_find_modified
export -f fast_grep fast_grep_count
export -f cache_get cache_set cache_clear memoize
export -f batch_git_commands fast_file_count fast_dir_size
export -f time_command profile_section generate_perf_report
export -f batch_process lazy_load parallel_file_process
export -f execute_if_needed

# ==============================================================================
# BATCH FILE OPERATIONS
# ==============================================================================

# Batch read multiple files efficiently
# Usage: batch_read_files <file1> <file2> <file3> ...
# Returns: Associative array FILE_CONTENTS with file paths as keys
# Example: 
#   batch_read_files "$audit_file" "$test_file" "$outdated_file"
#   echo "${FILE_CONTENTS[$audit_file]}"
declare -gA FILE_CONTENTS

batch_read_files() {
    local files=("$@")
    FILE_CONTENTS=()
    
    for file in "${files[@]}"; do
        if [[ -f "$file" && -r "$file" ]]; then
            FILE_CONTENTS[$file]=$(cat "$file" 2>/dev/null)
        else
            FILE_CONTENTS[$file]=""
        fi
    done
}

# Batch read files with line limits for optimization
# Usage: batch_read_files_limited <line_limit> <file1> <file2> ...
# Returns: Associative array FILE_CONTENTS_LIMITED with truncated content
declare -gA FILE_CONTENTS_LIMITED

batch_read_files_limited() {
    local line_limit="$1"
    shift
    local files=("$@")
    FILE_CONTENTS_LIMITED=()
    
    for file in "${files[@]}"; do
        if [[ -f "$file" && -r "$file" ]]; then
            FILE_CONTENTS_LIMITED[$file]=$(head -n "$line_limit" "$file" 2>/dev/null)
        else
            FILE_CONTENTS_LIMITED[$file]=""
        fi
    done
}

# Batch read and process multiple command outputs
# Usage: batch_command_outputs <cmd1> <cmd2> <cmd3> ...
# Returns: Associative array CMD_OUTPUTS with commands as keys
declare -gA CMD_OUTPUTS

batch_command_outputs() {
    local commands=("$@")
    CMD_OUTPUTS=()
    
    local pids=()
    local tmpfiles=()
    
    # Execute all commands in parallel
    for cmd in "${commands[@]}"; do
        local tmpfile=$(mktemp)
        tmpfiles+=("$tmpfile")
        eval "$cmd" > "$tmpfile" 2>&1 &
        pids+=($!)
    done
    
    # Wait for all commands to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Collect results
    for i in "${!commands[@]}"; do
        CMD_OUTPUTS[${commands[$i]}]=$(cat "${tmpfiles[$i]}")
        rm -f "${tmpfiles[$i]}"
    done
}

export -f batch_read_files batch_read_files_limited batch_command_outputs
