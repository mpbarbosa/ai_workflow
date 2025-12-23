#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Step 6: AI-Powered Test Generation (Refactored)
# Purpose: Generate new test code for untested modules
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0 (Refactored - High Cohesion, Low Coupling)
################################################################################

# Module version information
readonly STEP6_VERSION="2.0.0"
readonly STEP6_VERSION_MAJOR=2
readonly STEP6_VERSION_MINOR=0
readonly STEP6_VERSION_PATCH=0

# Get script directory for sourcing modules
STEP6_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular libraries
# shellcheck source=step_06_lib/gap_analysis.sh
source "${STEP6_DIR}/step_06_lib/gap_analysis.sh"

# shellcheck source=step_06_lib/test_generation.sh
source "${STEP6_DIR}/step_06_lib/test_generation.sh"

# shellcheck source=step_06_lib/ai_integration.sh
source "${STEP6_DIR}/step_06_lib/ai_integration.sh"

# shellcheck source=step_06_lib/reporting.sh
source "${STEP6_DIR}/step_06_lib/reporting.sh"

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

find_untested_files() { find_untested_files_step6 "$@"; }
count_untested_files() { count_untested_files_step6 "$@"; }
generate_test_stub() { generate_test_stub_step6 "$@"; }
build_test_generation_prompt() { build_test_generation_prompt_step6 "$@"; }
run_ai_test_generation_workflow() { run_ai_test_generation_workflow_step6 "$@"; }

# ==============================================================================
# VERSION INFORMATION
# ==============================================================================

step6_get_version() {
    local format="${1:---format=full}"
    format="${format#--format=}"
    
    case "$format" in
        simple)
            echo "$STEP6_VERSION"
            ;;
        semver)
            echo "${STEP6_VERSION_MAJOR}.${STEP6_VERSION_MINOR}.${STEP6_VERSION_PATCH}"
            ;;
        full|*)
            echo "Step 6: Test Generation v${STEP6_VERSION}"
            echo "  Modules: gap_analysis.sh, test_generation.sh, ai_integration.sh, reporting.sh"
            ;;
    esac
}

# ==============================================================================
# MAIN ORCHESTRATOR (Refactored - Slim & Focused)
# ==============================================================================

step6_generate_new_tests() {
    print_step "6" "Generate New Tests (if needed)"
    
    cd "$SRC_DIR" || return 1
    
    # Phase 1: Initialize
    local tests_generated=0
    local generation_log_file
    generation_log_file=$(mktemp)
    TEMP_FILES+=("$generation_log_file")
    
    # Phase 2: Analyze test coverage gaps
    print_info "Analyzing test coverage gaps..."
    local untested_files
    untested_files=$(find_untested_files)
    local untested_count
    untested_count=$(count_untested_files "$untested_files")
    
    if [[ $untested_count -eq 0 ]]; then
        print_success "All code has test coverage ✅"
    else
        print_warning "Found $untested_count untested files"
        echo "$untested_files" | head -10
        [[ $untested_count -gt 10 ]] && print_info "... and $((untested_count - 10)) more"
    fi
    
    # Phase 3: AI-powered test generation (if needed)
    if [[ $untested_count -gt 0 ]]; then
        print_info "Running AI test generation workflow..."
        run_ai_test_generation_workflow "$untested_count" "$untested_files"
    fi
    
    # Phase 4: Save results
    print_info "Saving test generation results..."
    save_test_generation_results_step6 "$untested_count" "$tests_generated"
    
    return 0
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f step6_generate_new_tests
export -f step6_get_version
export -f find_untested_files
export -f count_untested_files
export -f generate_test_stub
export -f build_test_generation_prompt
export -f run_ai_test_generation_workflow
