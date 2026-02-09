#!/bin/bash
# Integration Example: Using Step Validation Cache in Workflow Steps
# This demonstrates how to integrate validation caching into actual workflow steps

# ==============================================================================
# CLEANUP MANAGEMENT
# ==============================================================================

# Track temporary files for cleanup
declare -a STEP_VAL_INT_TEMP_FILES=()

# Register temp file for cleanup
track_step_val_int_temp() {
    local temp_file="$1"
    [[ -n "$temp_file" ]] && STEP_VAL_INT_TEMP_FILES+=("$temp_file")
}

# Cleanup handler for step validation cache integration
cleanup_step_val_int_files() {
    local file
    for file in "${STEP_VAL_INT_TEMP_FILES[@]}"; do
        [[ -d "$file" ]] && rm -rf "$file" 2>/dev/null
        [[ -f "$file" ]] && rm -f "$file" 2>/dev/null
    done
    STEP_VAL_INT_TEMP_FILES=()
}

################################################################################
# EXAMPLE 1: Step 9 - Code Quality Validation with Caching
################################################################################

integrate_step9_with_cache() {
    # Source the validation cache module
    source "${WORKFLOW_HOME}/src/workflow/lib/step_validation_cache.sh"
    
    # Initialize cache at step start
    init_validation_cache
    
    # Original Step 9 logic: Find and lint JavaScript files
    local source_files=$(find . -type f \( -name "*.js" -o -name "*.mjs" \) ! -path "*/node_modules/*" 2>/dev/null)
    
    local lint_failures=0
    local cached_count=0
    local validated_count=0
    
    while IFS= read -r file; do
        [[ -z "${file}" ]] && continue
        
        # NEW: Use validation cache instead of always running eslint
        # Generate cache key
        local cache_key=$(generate_validation_cache_key "step9" "eslint" "${file}")
        local file_hash=$(calculate_file_hash "${file}")
        
        # Check if validation result is cached
        if check_validation_cache "${cache_key}" "${file_hash}"; then
            # Cache hit - skip validation
            ((cached_count++))
            print_info "✓ ${file} (cached)"
            continue
        fi
        
        # Cache miss - run validation
        ((validated_count++))
        local lint_output=$(npx eslint "${file}" 2>&1)
        local lint_result=$?
        
        if [[ ${lint_result} -eq 0 ]]; then
            # Validation passed - cache the result
            save_validation_result "${cache_key}" "${file_hash}" "pass" "OK"
            print_success "✓ ${file}"
        else
            # Validation failed - cache the failure too
            save_validation_result "${cache_key}" "${file_hash}" "fail" "$(echo "${lint_output}" | head -c 200)"
            print_error "✗ ${file}: ${lint_output}"
            ((lint_failures++))
        fi
    done <<< "${source_files}"
    
    # Report cache performance
    print_info "Cache Performance: ${cached_count} cached, ${validated_count} validated"
    
    return ${lint_failures}
}

################################################################################
# EXAMPLE 2: Step 12 - Markdown Linting with Caching
################################################################################

integrate_step12_with_cache() {
    # Source the validation cache module
    source "${WORKFLOW_HOME}/src/workflow/lib/step_validation_cache.sh"
    
    # Initialize cache
    init_validation_cache
    
    # Find all markdown files
    local md_files=$(find . -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null)
    
    # Use batch validation for better performance
    local failed_count=0
    batch_validate_files_cached \
        "step12" \
        "markdownlint" \
        "npx markdownlint {file}" \
        ${md_files} || failed_count=$?
    
    # Display statistics
    get_validation_cache_stats
    
    return ${failed_count}
}

################################################################################
# EXAMPLE 3: Step 4 - Directory Structure Validation with Caching
################################################################################

integrate_step4_with_cache() {
    # Source the validation cache module
    source "${WORKFLOW_HOME}/src/workflow/lib/step_validation_cache.sh"
    
    # Initialize cache
    init_validation_cache
    
    # Validate directory structure using directory hash
    local directories=("src" "tests" "docs" "examples")
    
    for dir in "${directories[@]}"; do
        [[ ! -d "${dir}" ]] && continue
        
        # Use directory validation cache
        if ! validate_directory_cached \
            "step4" \
            "structure" \
            "${dir}" \
            "verify_directory_structure '${dir}'"; then
            print_warning "Directory structure issues in ${dir}/"
        fi
    done
    
    # Display cache statistics
    get_validation_cache_stats
}

################################################################################
# INTEGRATION PATTERN: Wrapper Functions
################################################################################

# Pattern 1: Simple file validation wrapper
cached_lint_file() {
    local file="$1"
    local lint_command="$2"
    
    validate_file_cached "step9" "lint" "${file}" "${lint_command}"
}

# Pattern 2: Batch validation wrapper
cached_lint_all_files() {
    local file_pattern="$1"
    local lint_command_template="$2"
    
    local files=$(find . -type f -name "${file_pattern}" ! -path "*/node_modules/*" 2>/dev/null)
    
    batch_validate_files_cached \
        "step9" \
        "lint" \
        "${lint_command_template}" \
        ${files}
}

# Pattern 3: Directory validation wrapper
cached_validate_directory() {
    local dir="$1"
    local validation_command="$2"
    
    validate_directory_cached "step4" "structure" "${dir}" "${validation_command}"
}

################################################################################
# USAGE EXAMPLES
################################################################################

usage_example_simple() {
    # Initialize once at step start
    init_validation_cache
    
    # Validate individual files with caching
    for file in src/*.js; do
        cached_lint_file "${file}" "npx eslint '${file}'"
    done
    
    # Show cache performance
    get_validation_cache_stats
}

usage_example_batch() {
    # Initialize once at step start
    init_validation_cache
    
    # Batch validate all JavaScript files
    cached_lint_all_files "*.js" "npx eslint {file}"
    
    # Show cache performance
    echo "Validation cache metrics:"
    export_validation_cache_metrics | jq '.'
}

usage_example_invalidation() {
    # Initialize cache
    init_validation_cache
    
    # Invalidate cache for all changed files (Git integration)
    invalidate_changed_files_cache
    
    # Now run validations - changed files will be re-validated
    cached_lint_all_files "*.js" "npx eslint {file}"
}

################################################################################
# PERFORMANCE OPTIMIZATION TIPS
################################################################################

# TIP 1: Invalidate only changed files before workflow run
pre_workflow_cache_optimization() {
    init_validation_cache
    invalidate_changed_files_cache
}

# TIP 2: Clear cache periodically (already automatic with TTL=24h)
manual_cache_cleanup() {
    init_validation_cache
    cleanup_validation_cache_old_entries
}

# TIP 3: Monitor cache hit rate
monitor_cache_performance() {
    init_validation_cache
    
    # ... run validations ...
    
    # Get metrics
    local total=$((VALIDATION_CACHE_HITS + VALIDATION_CACHE_MISSES))
    if [[ ${total} -gt 0 ]]; then
        local hit_rate=$(awk "BEGIN {printf \"%.1f\", (${VALIDATION_CACHE_HITS} / ${total}) * 100}")
        echo "Cache Hit Rate: ${hit_rate}%"
        echo "Files Skipped: ${VALIDATION_CACHE_SKIPPED_FILES}"
    fi
}

################################################################################
# MIGRATION GUIDE
################################################################################

# BEFORE (Without Caching):
step9_original() {
    for file in src/*.js; do
        npx eslint "${file}" || ((failures++))
    done
}

# AFTER (With Caching):
step9_with_cache() {
    init_validation_cache
    
    for file in src/*.js; do
        validate_file_cached "step9" "eslint" "${file}" "npx eslint '${file}'" || ((failures++))
    done
    
    get_validation_cache_stats
}

################################################################################
# EXPECTED PERFORMANCE GAINS
################################################################################

# Scenario 1: Documentation-only changes
# - Before: Validates all 100 source files (~2 minutes)
# - After: Validates 0 files, 100 cache hits (~5 seconds)
# - Improvement: 95% faster (1:55 saved)

# Scenario 2: Single file change
# - Before: Validates all 100 source files (~2 minutes)  
# - After: Validates 1 file, 99 cache hits (~8 seconds)
# - Improvement: 93% faster (1:52 saved)

# Scenario 3: 10% of files changed
# - Before: Validates all 100 source files (~2 minutes)
# - After: Validates 10 files, 90 cache hits (~25 seconds)
# - Improvement: 79% faster (1:35 saved)

# Scenario 4: First run or cache expired
# - Before: Validates all 100 source files (~2 minutes)
# - After: Validates all 100 files, builds cache (~2:05 minutes)
# - Improvement: -5 seconds overhead (acceptable for future gains)

################################################################################
# INTEGRATION CHECKLIST
################################################################################

# For Step Maintainers:
# [√] 1. Source step_validation_cache.sh at top of step script
# [√] 2. Call init_validation_cache() at step start
# [√] 3. Replace direct validation calls with validate_file_cached() or batch_validate_files_cached()
# [√] 4. Call get_validation_cache_stats() at step end (optional, for monitoring)
# [√] 5. Test with --no-cache flag to ensure validation still works
# [√] 6. Document cache behavior in step README

################################################################################
# TESTING INTEGRATION
################################################################################

test_step9_integration() {
    # Setup test environment
    local test_dir=$(mktemp -d)
    track_step_val_int_temp "$test_dir"
    cd "${test_dir}"
    
    # Create test files
    echo "console.log('test');" > test1.js
    echo "console.log('test2');" > test2.js
    
    # First run - all cache misses
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    integrate_step9_with_cache
    
    echo "First run: ${VALIDATION_CACHE_MISSES} misses"
    
    # Second run - all cache hits
    VALIDATION_CACHE_HITS=0
    VALIDATION_CACHE_MISSES=0
    integrate_step9_with_cache
    
    echo "Second run: ${VALIDATION_CACHE_HITS} hits, ${VALIDATION_CACHE_MISSES} misses"
    
    # Cleanup
    cd -
    rm -rf "${test_dir}"
}

################################################################################
# COMMAND-LINE FLAG INTEGRATION
################################################################################

# Add to execute_tests_docs_workflow.sh argument parser:
# --no-validation-cache    Disable validation result caching
# --clear-validation-cache Clear validation cache before run
# --validation-cache-stats Show detailed cache statistics

handle_cache_flags() {
    case "$1" in
        --no-validation-cache)
            export USE_VALIDATION_CACHE=false
            ;;
        --clear-validation-cache)
            clear_validation_cache
            ;;
        --validation-cache-stats)
            get_validation_cache_stats
            ;;
    esac
}

################################################################################
# MODULE EXPORTS
################################################################################

# Export cleanup handlers
export -f track_step_val_int_temp
export -f cleanup_step_val_int_files

# Export integration functions for use in steps
export -f integrate_step9_with_cache
export -f integrate_step12_with_cache
export -f integrate_step4_with_cache
export -f cached_lint_file
export -f cached_lint_all_files
export -f cached_validate_directory

# ==============================================================================
# CLEANUP TRAP
# ==============================================================================

# Ensure cleanup runs on exit
trap cleanup_step_val_int_files EXIT INT TERM
