#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1: AI-Powered Documentation Updates (Refactored)
# Purpose: Update documentation based on code changes with AI assistance  
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0 (Refactored - All Phases Complete)
################################################################################

# Module version information
readonly STEP1_VERSION="2.0.0"
readonly STEP1_VERSION_MAJOR=2
readonly STEP1_VERSION_MINOR=0
readonly STEP1_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP1_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core library modules
WORKFLOW_LIB_DIR="${STEP1_DIR}/../lib"

# Source third-party exclusion module
# shellcheck source=../lib/third_party_exclusion.sh
if [[ -f "${WORKFLOW_LIB_DIR}/third_party_exclusion.sh" ]]; then
    source "${WORKFLOW_LIB_DIR}/third_party_exclusion.sh"
fi

# Source modular libraries (All phases complete)
# shellcheck source=step_01_lib/cache.sh
source "${STEP1_DIR}/step_01_lib/cache.sh"

# shellcheck source=step_01_lib/file_operations.sh
source "${STEP1_DIR}/step_01_lib/file_operations.sh"

# shellcheck source=step_01_lib/validation.sh
source "${STEP1_DIR}/step_01_lib/validation.sh"

# shellcheck source=step_01_lib/ai_integration.sh
source "${STEP1_DIR}/step_01_lib/ai_integration.sh"

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

# Cache module aliases
init_performance_cache() { init_step1_cache; }
get_or_cache() { get_or_cache_step1 "$@"; }
get_cached_git_diff() { get_cached_git_diff_step1; }

# File operations aliases
batch_file_check() { batch_file_check_step1 "$@"; }
optimized_multi_grep() { optimized_multi_grep_step1 "$@"; }
determine_doc_folder() { determine_doc_folder_step1 "$@"; }
save_ai_generated_docs() { save_ai_generated_docs_step1 "$@"; }

# Validation module aliases
validate_documentation_file_counts() { validate_documentation_file_counts_step1; }
validate_submodule_cross_references() { validate_submodule_cross_references_step1; }
validate_submodule_architecture_changes() { validate_submodule_architecture_changes_step1; }
check_version_references_optimized() { check_version_references_step1 "$@"; }

# AI integration aliases
check_copilot_available() { check_copilot_available_step1; }
validate_copilot() { validate_copilot_step1; }
build_documentation_prompt() { build_documentation_prompt_step1 "$@"; }
execute_ai_documentation_analysis() { execute_ai_documentation_analysis_step1 "$@"; }
process_ai_response() { process_ai_response_step1 "$@"; }
run_ai_documentation_workflow() { run_ai_documentation_workflow_step1 "$@"; }

# Parallel file analysis with job control
# Usage: parallel_file_analysis <file_pattern> <analysis_function>
# Returns: Combined output from parallel jobs
parallel_file_analysis() {
    local pattern="$1"
    local analysis_func="$2"
    local max_jobs=4
    local job_count=0
    local temp_dir
    temp_dir=$(mktemp -d)
    TEMP_FILES+=("$temp_dir")
    
    # Use find_with_exclusions if available, otherwise fall back to regular find
    local files
    if declare -f find_with_exclusions &>/dev/null; then
        files=$(find_with_exclusions "." "$pattern" 10)
    else
        files=$(find . -name "$pattern" -type f \
            ! -path "*/node_modules/*" \
            ! -path "*/.git/*" \
            ! -path "*/venv/*" \
            ! -path "*/vendor/*" \
            2>/dev/null || true)
    fi
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        {
            local output
            output=$("$analysis_func" "$file")
            echo "$output" > "${temp_dir}/$(basename "$file").result"
        } &
        
        ((job_count++))
        
        if [[ $job_count -ge $max_jobs ]]; then
            wait -n
            ((job_count--))
        fi
    done <<< "$files"
    
    wait
    cat "${temp_dir}"/*.result 2>/dev/null || true
}

# Get module version information
# Usage: step1_get_version [--format=simple|full|semver]
# Returns: Version string
step1_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP1_VERSION"
            ;;
        semver)
            echo "${STEP1_VERSION_MAJOR}.${STEP1_VERSION_MINOR}.${STEP1_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 1: Documentation Updates v${STEP1_VERSION}"
            echo "  Major: $STEP1_VERSION_MAJOR"
            echo "  Minor: $STEP1_VERSION_MINOR"
            echo "  Patch: $STEP1_VERSION_PATCH"
            echo "  Modules: cache.sh (141), file_operations.sh (212), validation.sh (278), ai_integration.sh (320)"
            echo "  Total Lines: ~950 (refactored from 1,020)"
            ;;
    esac
}

# NOTE: validate_documentation_file_counts(), validate_submodule_cross_references(),
# validate_submodule_architecture_changes(), check_version_references_optimized()
# are now in step_01_lib/validation.sh and accessed via backward compat aliases

# Documentation consistency testing (OPTIMIZED with parallel test execution)
# Runs automated tests to verify documentation consistency
# Returns: 0 if all tests pass, count of failed tests otherwise
test_documentation_consistency() {
    local failed_tests=0
    local test_results_file
    test_results_file=$(mktemp)
    TEMP_FILES+=("$test_results_file")
    
    # Log exclusion information if module is available
    if declare -f log_exclusions &>/dev/null; then
        log_exclusions
        local excluded_count
        excluded_count=$(count_excluded_dirs "." 2>/dev/null || echo "0")
        if [[ $excluded_count -gt 0 ]]; then
            print_info "Excluding $excluded_count third-party directories from analysis"
        fi
    fi
    
    print_info "Running documentation consistency tests (parallel execution)..."
    
    # Test 1: Verify all documented files exist (run in background)
    {
        print_info "Test 1: Verifying documented files exist..."
        local test1_failed=0
        
        # Check README.md references
        if [[ -f "README.md" ]]; then
            while IFS= read -r line; do
                # Extract file paths from markdown links
                if [[ "$line" =~ \[(.*)\]\((.*)\) ]]; then
                    local link_path="${BASH_REMATCH[2]}"
                    # Skip external links
                    [[ "$link_path" =~ ^https?:// ]] && continue
                    [[ "$link_path" =~ ^#  ]] && continue
                    
                    if [[ -n "$link_path" ]] && [[ ! -e "$link_path" ]]; then
                        print_warning "README.md references missing file: $link_path"
                        ((test1_failed++))
                    fi
                fi
            done < README.md
        fi
        
        echo "$test1_failed" > "${test_results_file}.test1"
    } &
    local test1_pid=$!
    
    # Test 2: Check for broken internal links (run in background)
    {
        print_info "Test 2: Checking for broken internal links..."
        local test2_failed=0
        
        # Check all markdown files for broken links
        while IFS= read -r doc_file; do
            while IFS= read -r line; do
                if [[ "$line" =~ \[.*\]\((.*)\) ]]; then
                    local link="${BASH_REMATCH[1]}"
                    # Skip external links and anchors
                    [[ "$link" =~ ^https?:// ]] && continue
                    [[ "$link" =~ ^# ]] && continue
                    [[ "$link" =~ ^mailto: ]] && continue
                    
                    # Resolve relative paths
                    local link_dir
                    link_dir=$(dirname "$doc_file")
                    local target_file="${link_dir}/${link}"
                    
                    if [[ -n "$link" ]] && [[ ! -e "$target_file" ]]; then
                        print_warning "$doc_file: Broken link to $link"
                        ((test2_failed++))
                    fi
                fi
            done < "$doc_file"
        done < <(
            # Use find_with_exclusions if available, otherwise use manual exclusions
            if declare -f find_with_exclusions &>/dev/null; then
                find_with_exclusions "." "*.md" 10
            else
                find . -name "*.md" -type f \
                    ! -path "*/node_modules/*" \
                    ! -path "*/.git/*" \
                    ! -path "*/venv/*" \
                    ! -path "*/vendor/*" \
                    ! -path "*/build/*" \
                    ! -path "*/dist/*" \
                    2>/dev/null || true
            fi
        )
        
        echo "$test2_failed" > "${test_results_file}.test2"
    } &
    local test2_pid=$!
    
    # Test 3: Verify version consistency (run in background)
    {
        print_info "Test 3: Verifying version consistency..."
        local test3_failed=0
        local version_issues
        
        version_issues=$(check_version_references_optimized "1.5.0" || true)
        
        if [[ -n "$version_issues" ]]; then
            print_warning "Version inconsistencies found:"
            echo "$version_issues"
            test3_failed=1
        fi
        
        echo "$test3_failed" > "${test_results_file}.test3"
    } &
    local test3_pid=$!
    
    # Test 4: Validate file counts (run in background)
    {
        print_info "Test 4: Validating file counts..."
        local test4_failed=0
        
        if ! validate_documentation_file_counts; then
            test4_failed=1
        fi
        
        echo "$test4_failed" > "${test_results_file}.test4"
    } &
    local test4_pid=$!
    
    # Test 5: Check submodule references (run in background)
    {
        print_info "Test 5: Checking submodule references..."
        local test5_failed=0
        
        if ! validate_submodule_cross_references; then
            test5_failed=$?
        fi
        
        echo "$test5_failed" > "${test_results_file}.test5"
    } &
    local test5_pid=$!
    
    # Test 6: Verify submodule architecture (run in background)
    {
        print_info "Test 6: Verifying submodule architecture..."
        local test6_failed=0
        
        if ! validate_submodule_architecture_changes; then
            test6_failed=1
        fi
        
        echo "$test6_failed" > "${test_results_file}.test6"
    } &
    local test6_pid=$!
    
    # Wait for all tests to complete
    wait $test1_pid $test2_pid $test3_pid $test4_pid $test5_pid $test6_pid 2>/dev/null || true
    
    # Collect results
    for i in {1..6}; do
        if [[ -f "${test_results_file}.test${i}" ]]; then
            local result
            result=$(cat "${test_results_file}.test${i}")
            failed_tests=$((failed_tests + result))
        fi
    done
    
    if [[ $failed_tests -eq 0 ]]; then
        print_success "All documentation consistency tests passed!"
    else
        print_warning "$failed_tests documentation consistency test(s) failed"
    fi
    
    return $failed_tests
}

# ==============================================================================
# MAIN ORCHESTRATOR (Phase 5 - Slim & Focused)
# ==============================================================================

# Main step function - High-level workflow coordination only
# Orchestrates documentation updates through sub-modules
# Returns: 0 on success, non-zero on failure
step1_update_documentation() {
    print_section "Step 1: Update Related Documentation"
    
    # Phase 1: Initialize
    init_performance_cache
    
    # Phase 2: Detect changes
    local changed_files
    changed_files=$(get_cached_git_diff)
    
    if [[ -z "$changed_files" ]]; then
        print_info "No changes detected - skipping documentation update"
        return 0
    fi
    
    print_info "Changed files detected: $(echo "$changed_files" | wc -l) files"
    echo "$changed_files" | head -5
    [[ $(echo "$changed_files" | wc -l) -gt 5 ]] && print_info "... and more (see logs)"
    
    # Phase 3: Run validation (parallel execution)
    print_info "Running documentation consistency validation..."
    local validation_results=""
    if ! test_documentation_consistency; then
        validation_results="Documentation validation found issues (see above)"
    fi
    
    # Phase 4: AI-powered analysis (if available)
    if check_copilot_available; then
        print_info "Running AI-powered documentation analysis..."
        
        # Determine output directory (use backlog if available)
        local output_dir="${BACKLOG_STEP_DIR:-.}"
        
        # Execute AI workflow
        if run_ai_documentation_workflow "$changed_files" "$validation_results" "$output_dir"; then
            print_success "AI documentation analysis completed"
        else
            print_warning "AI analysis not available - manual review recommended"
        fi
    else
        print_info "GitHub Copilot CLI not available"
        print_info "Skipping AI-powered documentation updates"
        print_info "Please manually review and update documentation"
    fi
    
    # Phase 5: User confirmation (if interactive)
    if [[ -n "${INTERACTIVE:-}" ]]; then
        prompt_for_continuation
    fi
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export primary step functions
export -f step1_update_documentation
export -f step1_get_version
export -f test_documentation_consistency
export -f parallel_file_analysis

# Export backward compatibility aliases
export -f init_performance_cache
export -f get_or_cache
export -f get_cached_git_diff
export -f batch_file_check
export -f optimized_multi_grep
export -f determine_doc_folder
export -f save_ai_generated_docs
export -f validate_documentation_file_counts
export -f validate_submodule_cross_references
export -f validate_submodule_architecture_changes
export -f check_version_references_optimized
export -f check_copilot_available
export -f validate_copilot
export -f build_documentation_prompt
export -f execute_ai_documentation_analysis
export -f process_ai_response
export -f run_ai_documentation_workflow
