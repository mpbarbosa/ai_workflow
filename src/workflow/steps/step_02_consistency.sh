#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2: AI-Powered Documentation Consistency Analysis (Refactored)
# Purpose: Check documentation for broken references and consistency issues
# Part of: Tests & Documentation Workflow Automation v3.0.0
# Version: 3.0.0 (Refactored - High Cohesion, Low Coupling)
################################################################################

# Module version information
readonly STEP2_VERSION="3.0.0"
readonly STEP2_VERSION_MAJOR=2
readonly STEP2_VERSION_MINOR=0
readonly STEP2_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP2_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular libraries
# shellcheck source=step_02_lib/validation.sh
source "${STEP2_DIR}/step_02_lib/validation.sh"

# shellcheck source=step_02_lib/link_checker.sh
source "${STEP2_DIR}/step_02_lib/link_checker.sh"

# shellcheck source=step_02_lib/ai_integration.sh
source "${STEP2_DIR}/step_02_lib/ai_integration.sh"

# shellcheck source=step_02_lib/reporting.sh
source "${STEP2_DIR}/step_02_lib/reporting.sh"

# Source incremental analysis optimization (v2.7.0)
LIB_DIR="$(cd "${STEP2_DIR}/../lib" && pwd)"
# shellcheck source=../lib/incremental_analysis.sh
source "${LIB_DIR}/incremental_analysis.sh"

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

# Validation module aliases
validate_semver() { validate_semver_step2 "$@"; }
extract_versions_from_file() { extract_versions_from_file_step2 "$@"; }
check_version_consistency() { check_version_consistency_step2; }

# Link checker aliases
extract_absolute_refs() { extract_absolute_refs_step2 "$@"; }
check_file_refs() { check_file_refs_step2 "$@"; }
check_all_documentation_links() { check_all_documentation_links_step2 "$@"; }

# AI integration aliases
build_consistency_prompt() { build_consistency_prompt_step2 "$@"; }
execute_consistency_analysis() { execute_consistency_analysis_step2 "$@"; }
run_ai_consistency_workflow() { run_ai_consistency_workflow_step2 "$@"; }

# Reporting aliases
create_consistency_issue_report() { create_consistency_report_step2 "$@"; }
save_consistency_results() { save_consistency_results_step2 "$@"; }

# ==============================================================================
# VERSION INFORMATION
# ==============================================================================

# Get module version information
# Usage: step2_get_version [--format=simple|full|semver]
step2_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP2_VERSION"
            ;;
        semver)
            echo "${STEP2_VERSION_MAJOR}.${STEP2_VERSION_MINOR}.${STEP2_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 2: Consistency Analysis v${STEP2_VERSION}"
            echo "  Modules: validation.sh, link_checker.sh, ai_integration.sh, reporting.sh"
            echo "  Total Lines: ~600 (refactored from 373)"
            ;;
    esac
}

# ==============================================================================
# MAIN ORCHESTRATOR (Refactored - Slim & Focused)
# ==============================================================================

# Main step function - High-level workflow coordination only
# Returns: 0 for success, 1 for failure
step2_check_consistency() {
    print_step "2" "Check Documentation Consistency"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Phase 1: Initialize tracking variables
    local issues_found=0
    local version_issues=0
    local metrics_issues=0
    local broken_refs_file
    broken_refs_file=$(mktemp)
    TEMP_FILES+=("$broken_refs_file")
    
    # Phase 2: Run automated validation checks
    print_info "Running automated validation checks..."
    
    # Check version consistency
    check_version_consistency || version_issues=$?
    if [[ $version_issues -gt 0 ]]; then
        print_warning "Found $version_issues semantic versioning issue(s)"
        ((issues_found += version_issues))
    else
        print_success "All version numbers follow semantic versioning format ✅"
    fi
    
    # Check metrics consistency
    if ! check_metrics_consistency_step2; then
        metrics_issues=1
        ((issues_found++)) || true
    fi
    
    # Check for broken links
    local broken_links
    check_all_documentation_links_step2 "$broken_refs_file" || broken_links=$?
    if [[ ${broken_links:-0} -gt 0 ]]; then
        ((issues_found += broken_links))
    fi
    
    # Phase 3: Gather documentation inventory
    local doc_files
    local doc_count
    local total_doc_count
    
    # Check if incremental analysis is applicable (client_spa projects)
    local project_kind="${PROJECT_KIND:-unknown}"
    if should_use_incremental_analysis "$project_kind"; then
        print_info "Using incremental analysis for ${project_kind} project"
        
        # Get only changed documentation files
        local changed_docs
        if changed_docs=$(get_incremental_doc_inventory "HEAD~1"); then
            doc_files="$changed_docs"
            doc_count=$(echo "$doc_files" | wc -l)
            total_doc_count=$(count_documentation_files_step2)
            
            # Report savings
            report_incremental_stats "2" "$total_doc_count" "$doc_count"
        else
            # No changes - use full inventory
            doc_files=$(get_documentation_inventory_step2)
            doc_count=$(count_documentation_files_step2)
            total_doc_count=$doc_count
        fi
    else
        # Full analysis for non-client_spa projects
        doc_files=$(get_documentation_inventory_step2)
        doc_count=$(count_documentation_files_step2)
        total_doc_count=$doc_count
    fi
    
    # Phase 4: AI-powered consistency analysis (if no dry run)
    local broken_refs_content
    broken_refs_content=$(cat "$broken_refs_file" 2>/dev/null || echo "   No broken references detected")
    
    if run_ai_consistency_workflow_step2 "$doc_count" "$broken_refs_content" "$doc_files"; then
        print_success "AI consistency analysis completed"
    else
        print_info "AI analysis skipped or unavailable"
    fi
    
    # Phase 5: Generate reports and save results
    if [[ "$issues_found" -gt 0 ]]; then
        print_info "Generating comprehensive consistency issue report..."
        create_consistency_issue_report "$issues_found" "$broken_refs_file" "$version_issues" "$metrics_issues" "$doc_count"
        print_warning "Found ${issues_found} consistency issue(s) - review backlog for details"
    else
        print_success "No consistency issues detected ✅"
    fi
    
    # Save step results
    save_consistency_results_step2 "$issues_found" "$broken_refs_file" "$doc_count"
    
    # Update workflow status
    update_step2_status_step2 "✅"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

# Export primary step functions
export -f step2_check_consistency
export -f step2_get_version

# Export backward compatibility aliases
export -f validate_semver
export -f extract_versions_from_file
export -f check_version_consistency
export -f extract_absolute_refs
export -f check_file_refs
export -f check_all_documentation_links
export -f build_consistency_prompt
export -f execute_consistency_analysis
export -f run_ai_consistency_workflow
export -f create_consistency_issue_report
export -f save_consistency_results

