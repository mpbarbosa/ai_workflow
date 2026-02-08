#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 2 Reporting Module
# Purpose: Generate comprehensive consistency issue reports
# Part of: Step 2 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# REPORT GENERATION
# ==============================================================================

# Create comprehensive consistency issue report
# Usage: create_consistency_report_step2 <issues_found> <broken_refs_file> <version_issues> <metrics_issues> <doc_count>
# Returns: 0 for success
create_consistency_report_step2() {
    local issues_found="$1"
    local broken_refs_file="$2"
    local version_issues="$3"
    local metrics_issues="$4"
    local doc_count="$5"
    
    # Only create report if issues were found
    if [[ "$issues_found" -eq 0 ]]; then
        return 0
    fi
    
    local report="## Documentation Consistency Issues\n\n"
    report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
    report+="**Documentation Files Checked**: ${doc_count}\n"
    report+="**Total Issues Found**: ${issues_found}\n\n"
    
    # Add broken references section if any found
    if [[ -s "$broken_refs_file" ]]; then
        local broken_count
        broken_count=$(wc -l < "$broken_refs_file")
        report+="### Broken References (${broken_count} found)\n\n"
        
        while IFS=': ' read -r source_file broken_path; do
            [[ -z "$source_file" ]] && continue
            report+="⚠️  **BROKEN LINK**: \`${source_file}\` references missing file\n"
            report+="   - Reference: \`${broken_path}\`\n"
            report+="   - Action: Update reference or restore missing file\n\n"
        done < "$broken_refs_file"
    fi
    
    # Add version inconsistencies section if any found
    if [[ "$version_issues" -gt 0 ]]; then
        report+="### Version Inconsistencies (${version_issues} found)\n\n"
        report+="⚠️  **VERSION MISMATCH**: Files contain inconsistent version formats\n"
        report+="   - Check semantic versioning compliance (MAJOR.MINOR.PATCH)\n"
        report+="   - Action: Standardize all version numbers to valid semver format\n"
        report+="   - Review version_map output for details\n\n"
    fi
    
    # Add metrics validation section if any found
    if [[ "$metrics_issues" -gt 0 ]]; then
        report+="### Metrics Validation (${metrics_issues} found)\n\n"
        report+="⚠️  **METRICS MISMATCH**: Cross-document metrics inconsistency detected\n"
        report+="   - Action: Reconcile metrics across documentation\n"
        report+="   - Review metrics validation output for specific discrepancies\n\n"
    fi
    
    # Add recommended actions
    report+="### Recommended Actions\n\n"
    if [[ -s "$broken_refs_file" ]]; then
        report+="1. **Fix Broken References**: Update paths or restore missing files\n"
    fi
    if [[ "$version_issues" -gt 0 ]]; then
        report+="2. **Standardize Versions**: Ensure all version numbers follow semantic versioning\n"
    fi
    if [[ "$metrics_issues" -gt 0 ]]; then
        report+="3. **Validate Metrics**: Cross-check and update metrics for consistency\n"
    fi
    report+="4. **Re-run Consistency Check**: Verify all issues are resolved\n"
    
    # Automatically save report to backlog
    if command -v save_step_issues &>/dev/null; then
        save_step_issues "2" "Consistency_Analysis" "$(echo -e "$report")"
        print_info "Consistency issues report saved to backlog"
    else
        print_warning "Could not save report - save_step_issues function not available"
        echo -e "$report"
    fi
    
    return 0
}

# ==============================================================================
# RESULT SAVING
# ==============================================================================

# Save step results with proper success/failure messages
# Usage: save_consistency_results_step2 <issues_found> <broken_refs_file> <doc_count>
# Returns: 0 for success
save_consistency_results_step2() {
    local issues_found="$1"
    local broken_refs_file="$2"
    local doc_count="$3"
    
    local success_msg="No consistency issues found in automated checks"
    local failure_msg="Found ${issues_found} consistency issue(s) requiring attention. Review backlog report for details."
    
    # Use library function if available
    if command -v save_step_results &>/dev/null; then
        save_step_results \
            "2" \
            "Consistency_Analysis" \
            "$issues_found" \
            "$success_msg" \
            "$failure_msg" \
            "$broken_refs_file" \
            "$doc_count"
    else
        # Fallback - just print results
        if [[ "$issues_found" -eq 0 ]]; then
            print_success "$success_msg"
        else
            print_warning "$failure_msg"
        fi
    fi
    
    return 0
}

# ==============================================================================
# STATUS UPDATE
# ==============================================================================

# Update workflow status for Step 2
# Usage: update_step2_status_step2 <status>
# Returns: 0 for success
update_step2_status_step2() {
    local status="${1:-✅}"
    
    if command -v update_workflow_status &>/dev/null; then
        update_workflow_status "step2" "$status"
    fi
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f create_consistency_report_step2
export -f save_consistency_results_step2
export -f update_step2_status_step2
