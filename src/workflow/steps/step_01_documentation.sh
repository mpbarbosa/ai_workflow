#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1: AI-Powered Documentation Updates (Refactored)
# Purpose: Update documentation based on code changes with AI assistance  
# Part of: Tests & Documentation Workflow Automation v1.5.0
# Version: 1.5.0 (Refactored - Phases 1-3 Complete)
################################################################################

# Module version information
readonly STEP1_VERSION="1.5.0"
readonly STEP1_VERSION_MAJOR=1
readonly STEP1_VERSION_MINOR=5
readonly STEP1_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP1_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular libraries (Phases 1-3)
# shellcheck source=step_01_lib/cache.sh
source "${STEP1_DIR}/step_01_lib/cache.sh"

# shellcheck source=step_01_lib/file_operations.sh
source "${STEP1_DIR}/step_01_lib/file_operations.sh"

# shellcheck source=step_01_lib/validation.sh
source "${STEP1_DIR}/step_01_lib/validation.sh"

# Backward compatibility aliases (maintain old function names)
init_performance_cache() { init_step1_cache; }
get_or_cache() { get_or_cache_step1 "$@"; }
get_cached_git_diff() { get_cached_git_diff_step1; }
batch_file_check() { batch_file_check_step1 "$@"; }
optimized_multi_grep() { optimized_multi_grep_step1 "$@"; }
determine_doc_folder() { determine_doc_folder_step1 "$@"; }
save_ai_generated_docs() { save_ai_generated_docs_step1 "$@"; }
validate_documentation_file_counts() { validate_documentation_file_counts_step1; }
validate_submodule_cross_references() { validate_submodule_cross_references_step1; }
validate_submodule_architecture_changes() { validate_submodule_architecture_changes_step1; }
check_version_references_optimized() { check_version_references_step1 "$@"; }

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
    done < <(find . -name "$pattern" -type f 2>/dev/null || true)
    
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
            echo "  Modules: cache.sh, file_operations.sh, validation.sh"
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
        done < <(find . -name "*.md" -type f 2>/dev/null || true)
        
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

# Main step function
# Orchestrates documentation updates with AI assistance
step1_update_documentation() {
    print_section "Step 1: Update Related Documentation"
    
    # Initialize performance cache
    init_performance_cache
    
    # Get changed files (cached)
    local changed_files
    changed_files=$(get_cached_git_diff)
    
    if [[ -z "$changed_files" ]]; then
        print_info "No changes detected - skipping documentation update"
        return 0
    fi
    
    print_info "Changed files detected (from cache):"
    echo "$changed_files" | head -10
    
    if [[ $(echo "$changed_files" | wc -l) -gt 10 ]]; then
        print_info "... and $(($(echo "$changed_files" | wc -l) - 10)) more files"
    fi
    
    # Run consistency tests
    if ! test_documentation_consistency; then
        print_warning "Documentation consistency issues detected"
    fi
    
    # AI-powered documentation update
    print_info "Preparing GitHub Copilot CLI prompt for documentation updates..."
    
    # Build prompt with changed files
    local files_list
    files_list=$(echo "$changed_files" | tr '\n' ',' | sed 's/,$//')
    
    local prompt="Based on the recent changes to: ${files_list}, update documentation in: README.md, .github/copilot-instructions.md, and relevant docs/ files."
    
    # Execute AI prompt
    if command -v gh &>/dev/null && gh copilot --version &>/dev/null 2>&1; then
        print_info "Launching GitHub Copilot CLI for documentation updates..."
        gh copilot suggest "$prompt"
    else
        print_warning "GitHub Copilot CLI not available - skipping AI-powered updates"
        print_info "Please manually update documentation based on changes"
    fi
    
    prompt_for_continuation
}

# Export step functions
export -f step1_update_documentation
export -f step1_get_version
export -f test_documentation_consistency
export -f parallel_file_analysis

# Export backward compat functions
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
