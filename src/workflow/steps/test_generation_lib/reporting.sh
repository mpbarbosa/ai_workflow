#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 7 Reporting Module
# Purpose: Test generation report and result saving
# Part of: Step 7 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.7
################################################################################

# Save test generation results
# Usage: save_test_generation_results_step6 <untested_count> <tests_generated>
save_test_generation_results_step6() {
    local untested_count="$1"
    local tests_generated="$2"
    
    if [[ $untested_count -eq 0 ]]; then
        print_success "Test coverage is complete ✅"
        if command -v save_step_summary &>/dev/null; then
            save_step_summary "6" "Test_Generation" "All modules have test coverage. No new test generation required." "✅"
        fi
    else
        if [[ $tests_generated -gt 0 ]]; then
            print_success "Generated tests for untested code ✅"
        else
            print_warning "Test generation skipped - $untested_count files remain untested"
        fi
    fi
    
    if command -v update_workflow_status &>/dev/null; then
        update_workflow_status "step6" "✅"
    fi
    
    return 0
}

export -f save_test_generation_results_step6
