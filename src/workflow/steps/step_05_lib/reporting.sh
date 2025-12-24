#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 5 Reporting Module
# Purpose: Test review report generation and result saving
# Part of: Step 5 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.0
################################################################################

# ==============================================================================
# REPORT GENERATION
# ==============================================================================

# Create test review summary report
# Usage: create_test_review_report_step5 <test_count> <issues> <coverage_summary>
# Returns: Report text
create_test_review_report_step5() {
    local test_count="$1"
    local issues="$2"
    local coverage_summary="${3:-No coverage data}"
    
    local report=""
    
    report="## Test Review Summary\n\n"
    report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
    report+="**Test Files**: $test_count\n"
    report+="**Coverage**: $coverage_summary\n\n"
    
    if [[ "$issues" -gt 0 ]]; then
        report+="### Issues Found\n\n"
        report+="⚠️  $issues test quality issues detected\n"
        report+="Review Copilot analysis for detailed recommendations\n\n"
    else
        report+="### Status\n\n"
        report+="✅ No automated issues detected\n"
        report+="Test suite appears well-structured\n\n"
    fi
    
    report+="### Recommendations\n\n"
    report+="1. Review AI analysis for coverage gaps\n"
    report+="2. Address any identified test quality issues\n"
    report+="3. Consider adding edge case tests\n"
    report+="4. Maintain test documentation\n"
    
    echo -e "$report"
}

# Save test review results
# Usage: save_test_review_results_step5 <test_count> <issues> <test_issues_file>
# Returns: 0 on success
save_test_review_results_step5() {
    local test_count="$1"
    local issues="$2"
    local test_issues_file="$3"
    
    local success_msg="Test suite reviewed: $test_count test files analyzed"
    local failure_msg="Test review found $issues issues requiring attention"
    
    if command -v save_step_results &>/dev/null; then
        save_step_results \
            "5" \
            "Test_Review" \
            "$issues" \
            "$success_msg" \
            "$failure_msg" \
            "$test_issues_file" \
            "$test_count"
    else
        if [[ "$issues" -eq 0 ]]; then
            print_success "$success_msg"
        else
            print_warning "$failure_msg"
        fi
    fi
    
    return 0
}

# Update Step 5 workflow status
# Usage: update_step5_status_step5 [status]
# Returns: 0 on success
update_step5_status_step5() {
    local status="${1:-✅}"
    
    if command -v update_workflow_status &>/dev/null; then
        update_workflow_status "step5" "$status"
    fi
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f create_test_review_report_step5
export -f save_test_review_results_step5
export -f update_step5_status_step5
