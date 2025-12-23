#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 1 Validation Module
# Purpose: Documentation validation logic for Step 1
# Part of: Step 1 Refactoring - Phase 3
# Version: 1.0.0
################################################################################

# Prevent double-loading
if [[ "${STEP1_VALIDATION_MODULE_LOADED:-}" == "true" ]]; then
    return 0
fi

# Module version
readonly STEP1_VALIDATION_VERSION="1.0.0"

################################################################################
# PUBLIC API - File Count Validation
################################################################################

# Validate documentation file counts match actual counts
# Checks that documented file counts are accurate
# Usage: validate_documentation_file_counts_step1
# Returns: 0 if consistent, count of inconsistencies otherwise
validate_documentation_file_counts_step1() {
    local inconsistencies=0
    
    if command -v print_info &>/dev/null; then
        print_info "Validating documentation file counts..."
    fi
    
    # Parallel execution of both checks
    {
        # Check src/workflow documentation
        if [[ -f "src/workflow/README.md" ]]; then
            # Use cached script count if available
            local actual_scripts
            if command -v get_or_cache_step1 &>/dev/null; then
                actual_scripts=$(get_or_cache_step1 "workflow_script_count" bash -c 'find src/workflow/steps -name "step_*.sh" 2>/dev/null | wc -l')
            else
                actual_scripts=$(find src/workflow/steps -name "step_*.sh" 2>/dev/null | wc -l)
            fi
            
            local documented_scripts
            documented_scripts=$(grep -o "step [0-9]\+ steps" src/workflow/README.md 2>/dev/null | grep -o "[0-9]\+" | head -1 || echo "0")
            
            if [[ "$actual_scripts" != "$documented_scripts" ]] && [[ "$documented_scripts" != "0" ]]; then
                if command -v print_warning &>/dev/null; then
                    print_warning "src/workflow/README.md: Documented $documented_scripts steps, actual: $actual_scripts"
                fi
                ((inconsistencies++))
            fi
        fi
    } &
    local pid1=$!
    
    {
        # Check main README.md
        if [[ -f "README.md" ]]; then
            local actual_docs
            if command -v get_or_cache_step1 &>/dev/null; then
                actual_docs=$(get_or_cache_step1 "docs_count" bash -c 'find docs -name "*.md" 2>/dev/null | wc -l')
            else
                actual_docs=$(find docs -name "*.md" 2>/dev/null | wc -l)
            fi
            
            # Check if README mentions document count
            if grep -q "documentation files\?" README.md 2>/dev/null; then
                local documented_count
                documented_count=$(grep -o "[0-9]\+ documentation files\?" README.md 2>/dev/null | grep -o "[0-9]\+" | head -1 || echo "0")
                
                if [[ "$actual_docs" != "$documented_count" ]] && [[ "$documented_count" != "0" ]]; then
                    if command -v print_warning &>/dev/null; then
                        print_warning "README.md: Documented $documented_count docs, actual: $actual_docs"
                    fi
                    ((inconsistencies++))
                fi
            fi
        fi
    } &
    local pid2=$!
    
    # Wait for both parallel checks
    wait $pid1 $pid2
    
    if [[ $inconsistencies -eq 0 ]]; then
        if command -v print_success &>/dev/null; then
            print_success "Documentation file counts are consistent"
        fi
    fi
    
    return $inconsistencies
}

################################################################################
# PUBLIC API - Cross-Reference Validation
################################################################################

# Validate submodule cross-references in documentation
# Checks that all submodule references are valid
# Usage: validate_submodule_cross_references_step1
# Returns: count of broken references
validate_submodule_cross_references_step1() {
    local issues=0
    
    if command -v print_info &>/dev/null; then
        print_info "Validating submodule cross-references..."
    fi
    
    # Get list of actual submodules
    local actual_submodules
    actual_submodules=$(grep 'path = ' .gitmodules 2>/dev/null | awk '{print $3}' || true)
    
    if [[ -z "$actual_submodules" ]]; then
        if command -v print_info &>/dev/null; then
            print_info "No submodules found in .gitmodules"
        fi
        return 0
    fi
    
    # Check README.md for submodule references
    if [[ -f "README.md" ]]; then
        while IFS= read -r submodule; do
            [[ -z "$submodule" ]] && continue
            
            if ! grep -q "$submodule" README.md 2>/dev/null; then
                if command -v print_warning &>/dev/null; then
                    print_warning "README.md: Missing reference to submodule '$submodule'"
                fi
                ((issues++))
            fi
        done <<< "$actual_submodules"
    fi
    
    # Check .github/copilot-instructions.md
    if [[ -f ".github/copilot-instructions.md" ]]; then
        while IFS= read -r submodule; do
            [[ -z "$submodule" ]] && continue
            
            if ! grep -q "$submodule" .github/copilot-instructions.md 2>/dev/null; then
                if command -v print_warning &>/dev/null; then
                    print_warning "copilot-instructions.md: Missing reference to submodule '$submodule'"
                fi
                ((issues++))
            fi
        done <<< "$actual_submodules"
    fi
    
    if [[ $issues -eq 0 ]]; then
        if command -v print_success &>/dev/null; then
            print_success "All submodule cross-references are valid"
        fi
    fi
    
    return $issues
}

################################################################################
# PUBLIC API - Architecture Change Validation
################################################################################

# Validate submodule architecture changes
# Detects if submodule-related changes require documentation updates
# Usage: validate_submodule_architecture_changes_step1
# Returns: 0 if no action needed, 1 if documentation update required
validate_submodule_architecture_changes_step1() {
    local doc_update_required=0
    
    if command -v print_info &>/dev/null; then
        print_info "Validating submodule architecture changes..."
    fi
    
    # Get changed files from git cache
    local changed_files
    if command -v get_git_diff_files_output &>/dev/null; then
        changed_files=$(get_git_diff_files_output)
    elif command -v git &>/dev/null; then
        changed_files=$(git diff --name-only 2>/dev/null || true)
    else
        return 0
    fi
    
    # Check if .gitmodules was modified
    if echo "$changed_files" | grep -q "^\.gitmodules$"; then
        if command -v print_warning &>/dev/null; then
            print_warning ".gitmodules modified - documentation update REQUIRED"
            echo "  → Update README.md with new submodule information"
            echo "  → Update .github/copilot-instructions.md"
        fi
        doc_update_required=1
    fi
    
    # Check if submodule directories were added/removed
    local submodule_dirs
    submodule_dirs=$(grep 'path = ' .gitmodules 2>/dev/null | awk '{print $3}' || true)
    
    while IFS= read -r submodule_dir; do
        [[ -z "$submodule_dir" ]] && continue
        
        if echo "$changed_files" | grep -q "^${submodule_dir}/"; then
            if command -v print_info &>/dev/null; then
                print_info "Submodule directory modified: $submodule_dir"
            fi
            
            # Check if it's a structural change (new files, directory structure)
            if echo "$changed_files" | grep -qE "^${submodule_dir}/(README\.md|package\.json|\.gitmodules)"; then
                if command -v print_warning &>/dev/null; then
                    print_warning "Submodule structure modified: $submodule_dir - documentation update recommended"
                fi
                doc_update_required=1
            fi
        fi
    done <<< "$submodule_dirs"
    
    if [[ $doc_update_required -eq 0 ]]; then
        if command -v print_success &>/dev/null; then
            print_success "No submodule architecture changes requiring documentation updates"
        fi
    fi
    
    return $doc_update_required
}

################################################################################
# PUBLIC API - Version Reference Validation
################################################################################

# Check version references in documentation
# Validates that version numbers are consistent
# Usage: check_version_references_step1 <version_to_check>
# Returns: outputs any inconsistencies found
check_version_references_step1() {
    local version_to_check="${1:-1.5.0}"
    
    # Single grep pass for both files with parallel execution
    {
        if [[ -f "README.md" ]]; then
            grep -n "workflow.*v1\.[0-9]\.0\|automation.*v1\.[0-9]\.0\|execute_tests_docs_workflow.*v1\.[0-9]\.0" README.md 2>/dev/null | \
                grep -v "v${version_to_check}" | \
                while IFS=: read -r line content; do
                    echo "README.md:${line}:${content}"
                done
        fi
    } &
    local pid1=$!
    
    {
        if [[ -f ".github/copilot-instructions.md" ]]; then
            grep -n "workflow.*v1\.[0-9]\.0\|automation.*v1\.[0-9]\.0\|execute_tests_docs_workflow.*v1\.[0-9]\.0" .github/copilot-instructions.md 2>/dev/null | \
                grep -v "v${version_to_check}" | \
                while IFS=: read -r line content; do
                    echo ".github/copilot-instructions.md:${line}:${content}"
                done
        fi
    } &
    local pid2=$!
    
    # Wait for both parallel checks
    wait $pid1 $pid2 2>/dev/null || true
    
    return 0
}

################################################################################
# EXPORTS
################################################################################

# Export all public functions
export -f validate_documentation_file_counts_step1
export -f validate_submodule_cross_references_step1
export -f validate_submodule_architecture_changes_step1
export -f check_version_references_step1

# Module loaded indicator
readonly STEP1_VALIDATION_MODULE_LOADED=true
export STEP1_VALIDATION_MODULE_LOADED
