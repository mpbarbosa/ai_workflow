#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 5: AI-Powered Test Review (Refactored)
# Purpose: Review existing tests and identify coverage gaps
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0 (Refactored - High Cohesion, Low Coupling)
################################################################################

# Module version information
readonly STEP5_VERSION="2.0.0"
readonly STEP5_VERSION_MAJOR=2
readonly STEP5_VERSION_MINOR=0
readonly STEP5_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP5_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular libraries
# shellcheck source=step_05_lib/test_discovery.sh
source "${STEP5_DIR}/step_05_lib/test_discovery.sh"

# shellcheck source=step_05_lib/coverage_analysis.sh
source "${STEP5_DIR}/step_05_lib/coverage_analysis.sh"

# shellcheck source=step_05_lib/ai_integration.sh
source "${STEP5_DIR}/step_05_lib/ai_integration.sh"

# shellcheck source=step_05_lib/reporting.sh
source "${STEP5_DIR}/step_05_lib/reporting.sh"

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

discover_test_files() { discover_test_files_step5 "$@"; }
count_test_files() { count_test_files_step5 "$@"; }
create_test_inventory() { create_test_inventory_step5 "$@"; }
find_coverage_reports() { find_coverage_reports_step5; }
get_coverage_summary() { get_coverage_summary_step5; }
build_test_review_prompt() { build_test_review_prompt_step5 "$@"; }
run_ai_test_review_workflow() { run_ai_test_review_workflow_step5 "$@"; }

# ==============================================================================
# VERSION INFORMATION
# ==============================================================================

step5_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP5_VERSION"
            ;;
        semver)
            echo "${STEP5_VERSION_MAJOR}.${STEP5_VERSION_MINOR}.${STEP5_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 5: Test Review v${STEP5_VERSION}"
            echo "  Modules: test_discovery.sh, coverage_analysis.sh, ai_integration.sh, reporting.sh"
            ;;
    esac
}

# ==============================================================================
# MAIN ORCHESTRATOR (Refactored - Slim & Focused)
# ==============================================================================

step5_review_existing_tests() {
    print_step "5" "Review Existing Tests"
    
    cd "$SRC_DIR" || return 1
    
    # Phase 1: Initialize
    local issues=0
    local test_issues_file
    test_issues_file=$(mktemp)
    TEMP_FILES+=("$test_issues_file")
    
    # Phase 2: Discover tests
    print_info "Discovering test files..."
    local test_files
    test_files=$(discover_test_files)
    local test_count
    test_count=$(count_test_files "$test_files")
    
    if [[ $test_count -eq 0 ]]; then
        print_warning "No test files found!"
        echo "CRITICAL: No test files exist" >> "$test_issues_file"
        ((issues++))
    else
        print_success "Found $test_count test files"
    fi
    
    # Phase 3: Analyze coverage
    print_info "Checking for coverage reports..."
    local coverage_summary
    if find_coverage_reports; then
        coverage_summary=$(get_coverage_summary)
        print_success "$coverage_summary"
    else
        coverage_summary="No coverage report found"
        print_warning "$coverage_summary"
    fi
    
    # Phase 4: AI-powered test review
    if [[ $test_count -gt 0 ]]; then
        print_info "Running AI-powered test review..."
        run_ai_test_review_workflow "$test_count" "$test_files" "$coverage_summary" "$issues"
    fi
    
    # Phase 5: Generate reports
    print_info "Saving test review results..."
    save_test_review_results_step5 "$test_count" "$issues" "$test_issues_file"
    update_step5_status_step5 "✅"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f step5_review_existing_tests
export -f step5_get_version
export -f discover_test_files
export -f count_test_files
export -f find_coverage_reports
export -f get_coverage_summary
export -f build_test_review_prompt
export -f run_ai_test_review_workflow
