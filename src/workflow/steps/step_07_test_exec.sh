#!/bin/bash
set -euo pipefail

################################################################################
# Step 7: AI-Powered Test Execution and Analysis
# Purpose: Execute test suite and analyze results with AI (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.4.1
# Version: 2.2.0 (Phase 3 - Adaptive + Regression Prevention)
################################################################################

# Module version information
readonly STEP7_VERSION="2.2.0"
readonly STEP7_VERSION_MAJOR=2
readonly STEP7_VERSION_MINOR=2
readonly STEP7_VERSION_PATCH=0

# Source test validation library
STEP7_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STEP7_DIR}/../lib/test_validation.sh"

# Main step function - executes tests and analyzes results with AI
# Returns: 0 for success (or user override), 1 for failure
step7_execute_test_suite() {
    print_step "7" "Execute Full Test Suite with AI Analysis"
    
    # Use TARGET_DIR for test execution (where package.json typically lives)
    local test_dir="${TARGET_DIR:-$PROJECT_ROOT}"
    cd "$test_dir" || {
        print_error "Cannot navigate to test directory: $test_dir"
        return 1
    }
    
    local test_failures=0
    local test_results_file
    local coverage_summary_file
    
    test_results_file=$(mktemp)
    coverage_summary_file=$(mktemp)
    TEMP_FILES+=("$test_results_file" "$coverage_summary_file")
    
    # PHASE 1: Automated test execution (ADAPTIVE - Phase 3)
    local test_cmd=""
    local language_name="${PRIMARY_LANGUAGE:-javascript}"
    
    # Get test command from tech stack (Phase 3 integration)
    if command -v get_test_command &>/dev/null; then
        test_cmd=$(get_test_command)
    else
        # Fallback to TEST_COMMAND variable
        # Prefer fast tests (exclude slow E2E) if available
        if [[ -f "${TARGET_DIR}/package.json" ]] && grep -q '"test:fast"' "${TARGET_DIR}/package.json" 2>/dev/null; then
            test_cmd="${TEST_COMMAND:-npm run test:fast}"
            print_info "Using fast test suite (E2E tests excluded)"
        else
            test_cmd="${TEST_COMMAND:-npm test}"
        fi
    fi
    
    # Validate that test command is available
    if [[ -z "$test_cmd" ]]; then
        print_warning "No test command configured for ${language_name}"
        print_info "Please run with --init-config to configure project"
        
        # Try to skip gracefully for languages without tests
        if [[ "$language_name" == "bash" ]]; then
            print_info "Bash project - skipping test execution"
            save_step_summary "7" "Test_Execution" "No tests configured for bash project" "⚠️"
            return 0
        fi
        
        return 1
    fi
    
    print_info "Phase 1: Executing ${language_name} test suite..."
    print_info "Test command: $test_cmd"
    
    # Check 1: Run full test suite
    print_info "Running tests with coverage..."
    local test_exit_code=0
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would execute: $test_cmd"
        test_exit_code=0
    else
        # Run tests with live output to show progress
        print_info "Test execution in progress (this may take several minutes)..."
        print_info "Streaming test output:"
        echo ""
        
        # Run tests with tee to both display and capture output
        if eval "$test_cmd" 2>&1 | tee "$test_results_file"; then
            test_exit_code=0
            echo ""
            print_success "All tests passed ✅"
        else
            test_exit_code=$?
            test_failures=1
            echo ""
            print_warning "Some tests failed - analyzing results..."
        fi
    fi
    
    # Check 2: Parse test results
    print_info "Parsing test results..."
    local tests_total=0
    local tests_passed=0
    local tests_failed=0
    
    if [[ -f "$test_results_file" ]]; then
        # Parse based on test framework
        case "${TEST_FRAMEWORK:-unknown}" in
            jest)
                # Extract Jest summary
                tests_total=$(grep -oP 'Tests:.*\K\d+(?= total)' "$test_results_file" 2>/dev/null || echo "0")
                tests_passed=$(grep -oP 'Tests:.*\K\d+(?= passed)' "$test_results_file" 2>/dev/null || echo "0")
                tests_failed=$(grep -oP 'Tests:.*\K\d+(?= failed)' "$test_results_file" 2>/dev/null || echo "0")
                ;;
            bats)
                # Extract BATS summary
                # BATS format: "X tests, Y failures"
                tests_total=$(grep -oP '\K\d+(?= tests?)' "$test_results_file" 2>/dev/null | head -1 || echo "0")
                tests_failed=$(grep -oP '\K\d+(?= failures?)' "$test_results_file" 2>/dev/null | head -1 || echo "0")
                tests_passed=$((tests_total - tests_failed))
                ;;
            pytest)
                # Extract pytest summary
                tests_passed=$(grep -oP '\K\d+(?= passed)' "$test_results_file" 2>/dev/null || echo "0")
                tests_failed=$(grep -oP '\K\d+(?= failed)' "$test_results_file" 2>/dev/null || echo "0")
                tests_total=$((tests_passed + tests_failed))
                ;;
            *)
                # Generic extraction - use exit code
                if [[ $test_exit_code -eq 0 ]]; then
                    tests_passed=1
                    tests_total=1
                else
                    tests_failed=1
                    tests_total=1
                fi
                ;;
        esac
        
        print_info "Test Results: $tests_passed passed, $tests_failed failed, $tests_total total"
    fi
    
    # Check 3: Extract coverage metrics
    print_info "Analyzing coverage report..."
    local coverage_statements=0
    local coverage_branches=0
    local coverage_functions=0
    local coverage_lines=0
    
    # Check coverage in multiple possible locations
    local coverage_file=""
    if [[ -f "coverage/coverage-summary.json" ]]; then
        coverage_file="coverage/coverage-summary.json"
    elif [[ -f "$test_dir/coverage/coverage-summary.json" ]]; then
        coverage_file="$test_dir/coverage/coverage-summary.json"
    fi
    
    if [[ -n "$coverage_file" ]]; then
        cp "$coverage_file" "$coverage_summary_file"
        
        # Extract total coverage percentages
        if command -v jq &> /dev/null; then
            coverage_statements=$(jq '.total.statements.pct' "$coverage_summary_file" 2>/dev/null || echo "0")
            coverage_branches=$(jq '.total.branches.pct' "$coverage_summary_file" 2>/dev/null || echo "0")
            coverage_functions=$(jq '.total.functions.pct' "$coverage_summary_file" 2>/dev/null || echo "0")
            coverage_lines=$(jq '.total.lines.pct' "$coverage_summary_file" 2>/dev/null || echo "0")
            
            print_info "Coverage: Statements: ${coverage_statements}%, Branches: ${coverage_branches}%, Functions: ${coverage_functions}%, Lines: ${coverage_lines}%"
        else
            print_warning "jq not found - detailed coverage parsing unavailable"
        fi
    else
        print_warning "Coverage report not found"
    fi
    
    # Check 4: Identify failed tests
    local failed_test_list=""
    if [[ $tests_failed -gt 0 ]] && [[ -f "$test_results_file" ]]; then
        # Extract failed test names
        failed_test_list=$(grep -A 5 "FAIL" "$test_results_file" 2>/dev/null || echo "Unable to extract failed tests")
    fi
    
    # PHASE 2: AI-powered test results analysis
    print_info "Phase 2: Preparing AI-powered test results analysis..."
    
    # Build test execution summary
    local execution_summary="Test Execution Summary:
- Total Tests: $tests_total
- Passed: $tests_passed
- Failed: $tests_failed
- Exit Code: $test_exit_code

Coverage Metrics:
- Statements: ${coverage_statements}%
- Branches: ${coverage_branches}%
- Functions: ${coverage_functions}%
- Lines: ${coverage_lines}%"
    
    local test_output
    # Increased from 100 to 200 lines (Dec 15, 2025) for better debugging visibility
    test_output=$(cat "$test_results_file" 2>/dev/null | head -200 || echo "Test output unavailable")
    
    # Build comprehensive test analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step7_test_exec_prompt \
        "$test_exit_code" \
        "$tests_total" \
        "$tests_passed" \
        "$tests_failed" \
        "$execution_summary" \
        "$test_output" \
        "$failed_test_list")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Test Results Analysis Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with test results analysis prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to analyze test results?" "y"; then
            # Save prompt to temporary file for tracking
            local temp_prompt_file
            temp_prompt_file=$(mktemp)
            TEMP_FILES+=("$temp_prompt_file")
            echo "$copilot_prompt" > "$temp_prompt_file"
            
            # Invoke Copilot CLI
            print_info "Starting Copilot CLI session..."
            
            # Create log file with unique timestamp
            local log_timestamp
            log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
            local log_file="${LOGS_RUN_DIR}/step7_copilot_test_analysis_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file" "step07" "test_execution_analyst"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function (only if log exists)
            if [[ -f "$log_file" ]]; then
                extract_and_save_issues_from_log "7" "Test_Execution" "$log_file"
            elif [[ "$AUTO_MODE" == true ]]; then
                print_info "Auto mode: Skipping issue extraction from AI analysis"
            else
                print_warning "Log file not found, skipping issue extraction"
            fi
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Handle test failure workflow continuation
    if [[ $test_failures -gt 0 ]]; then
        if ! confirm_action "Continue workflow despite test failures?"; then
            print_error "Workflow paused - fix test failures before continuing"
            return 1
        else
            test_exit_code=0
        fi
    else
        print_warning "GitHub Copilot CLI not found - manual analysis required"
        print_info "Install from: https://github.com/github/gh-copilot"
        
        # Still fail workflow if tests failed
        if [[ $test_failures -gt 0 ]] && [[ "$INTERACTIVE_MODE" == true ]]; then
            if ! confirm_action "Continue despite test failures?"; then
                return 1
            else
                test_exit_code=0
            fi
        fi
    fi
    
    # Summary
    echo ""
    if [[ $test_exit_code -eq 0 ]]; then
        if [[ $tests_failed -gt 0 ]]; then
            # Tests failed but user chose to continue
            print_warning "Test suite executed with failures ⚠️ ($tests_passed/$tests_total passed, $tests_failed failed)"
            print_info "Continuing workflow as requested - review failures later"
            print_success "Coverage: Lines ${coverage_lines}%, Branches ${coverage_branches}%"
            save_step_summary "7" "Test_Execution" "${tests_failed} of ${tests_total} tests failed, but continuing workflow. Coverage: ${coverage_lines}% lines." "⚠️"
        else
            # All tests passed
            print_success "Test suite executed successfully ✅ ($tests_passed/$tests_total passed)"
            print_success "Coverage: Lines ${coverage_lines}%, Branches ${coverage_branches}%"
            save_step_summary "7" "Test_Execution" "All ${tests_total} tests passed. Coverage: ${coverage_lines}% lines, ${coverage_branches}% branches. Test suite healthy." "✅"
        fi
    else
        print_error "Test suite failed ❌ ($tests_failed/$tests_total failed)"
        if [[ "$AUTO_MODE" == false ]]; then
            print_warning "Review failures before continuing workflow"
        fi
        save_step_summary "7" "Test_Execution" "${tests_failed} of ${tests_total} tests failed. Review failures and fix broken tests. Coverage: ${coverage_lines}% lines." "❌"
    fi
    
    # Save to backlog
    local step_issues="### Test Execution Results

**Total Tests:** ${tests_total}
**Passed:** ${tests_passed}
**Failed:** ${tests_failed}
**Exit Code:** ${test_exit_code}

### Coverage Metrics

- **Statements:** ${coverage_statements}%
- **Branches:** ${coverage_branches}%
- **Functions:** ${coverage_functions}%
- **Lines:** ${coverage_lines}%

"
    if [[ $tests_failed -gt 0 ]] && [[ -f "$test_results_file" && -s "$test_results_file" ]]; then
        step_issues+="### Test Output

\`\`\`
$(cat "$test_results_file")
\`\`\`
"
    fi
    save_step_issues "7" "Test_Execution" "$step_issues"
    
    cd "$PROJECT_ROOT" || return 1
    
    # Use validation library to ensure visual status matches test outcome
    # However, if user chose to continue despite failures (test_exit_code=0), respect that
    if [[ $test_exit_code -eq 0 ]]; then
        # User chose to continue or tests passed
        if command -v update_workflow_status &>/dev/null; then
            if [[ $tests_failed -gt 0 ]]; then
                update_workflow_status "step7" "⚠️"  # Warning: continued despite failures
            else
                update_workflow_status "step7" "✅"  # All tests passed
            fi
        fi
        return 0
    else
        # Tests failed and user chose not to continue
        validate_and_update_test_status "7" "$test_exit_code" "$tests_total" "$tests_passed" "$tests_failed"
        return $?
    fi
}

# Export step function
export -f step7_execute_test_suite
