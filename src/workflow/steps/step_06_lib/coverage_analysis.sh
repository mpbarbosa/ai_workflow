#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 6 Coverage Analysis Module
# Purpose: Test coverage report analysis
# Part of: Step 6 Refactoring - High Cohesion, Low Coupling
# Version: 2.0.7
################################################################################

# ==============================================================================
# COVERAGE REPORT DETECTION
# ==============================================================================

# Check for coverage reports
# Usage: find_coverage_reports_step6
# Returns: 0 if found, 1 if not
find_coverage_reports_step6() {
    # Common coverage report locations
    if [[ -f "coverage/lcov-report/index.html" ]] || \
       [[ -f "coverage/index.html" ]] || \
       [[ -f "htmlcov/index.html" ]] || \
       [[ -f "target/site/jacoco/index.html" ]]; then
        return 0
    fi
    
    return 1
}

# Get coverage summary
# Usage: get_coverage_summary_step6
# Returns: Coverage summary text
get_coverage_summary_step6() {
    local summary=""
    
    # JavaScript/TypeScript (Jest/Istanbul)
    if [[ -f "coverage/lcov-report/index.html" ]]; then
        summary="JavaScript coverage report found: coverage/lcov-report/index.html"
    elif [[ -f "coverage/index.html" ]]; then
        summary="Coverage report found: coverage/index.html"
    # Python (pytest-cov)
    elif [[ -f "htmlcov/index.html" ]]; then
        summary="Python coverage report found: htmlcov/index.html"
    # Java (JaCoCo)
    elif [[ -f "target/site/jacoco/index.html" ]]; then
        summary="Java coverage report found: target/site/jacoco/index.html"
    # Go
    elif [[ -f "coverage.html" ]]; then
        summary="Go coverage report found: coverage.html"
    else
        summary="No coverage report found"
        return 1
    fi
    
    echo "$summary"
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f find_coverage_reports_step6
export -f get_coverage_summary_step6
