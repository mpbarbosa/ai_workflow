#!/bin/bash
set -euo pipefail

################################################################################
# Step 5: AI-Powered Test Review (Language-Aware)
# Purpose: Review existing tests and identify coverage gaps (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.5.0
# Version: 2.1.0 (Phase 5 - Language-aware test review)
################################################################################

# Module version information
readonly STEP5_VERSION="2.1.0"
readonly STEP5_VERSION_MAJOR=2
readonly STEP5_VERSION_MINOR=1
readonly STEP5_VERSION_PATCH=0

# Main step function - reviews existing tests with AI assistance
# Returns: 0 for success, 1 for failure
step5_review_existing_tests() {
    print_step "5" "Review Existing Jest Tests"
    
    cd "$SRC_DIR" || return 1
    
    local issues=0
    local test_issues_file
    test_issues_file=$(mktemp)
    TEMP_FILES+=("$test_issues_file")
    
    # PHASE 1: Automated test analysis
    print_info "Phase 1: Automated test analysis..."
    
    # Check 1: Test file inventory (language-aware)
    print_info "Gathering test file inventory..."
    local test_files
    local test_count
    local language="${PRIMARY_LANGUAGE:-javascript}"
    
    # Get test file patterns based on language
    case "$language" in
        javascript|typescript)
            test_files=$(fast_find "." "*.test.js" 10 "node_modules" ".git" "coverage" && \
                        fast_find "." "*.spec.js" 10 "node_modules" ".git" "coverage" && \
                        fast_find "." "*.test.ts" 10 "node_modules" ".git" "coverage" | sort -u)
            test_count=$(echo "$test_files" | grep -c "test\|spec" || echo "0")
            ;;
        python)
            test_files=$(fast_find "." "test_*.py" 10 "__pycache__" ".git" "coverage" && \
                        fast_find "." "*_test.py" 10 "__pycache__" ".git" "coverage" | sort -u)
            test_count=$(echo "$test_files" | grep -c "test.*\.py" || echo "0")
            ;;
        go)
            test_files=$(fast_find "." "*_test.go" 10 "vendor" ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "_test\.go" || echo "0")
            ;;
        java)
            test_files=$(fast_find "." "*Test.java" 10 "target" ".git" && \
                        fast_find "." "*Tests.java" 10 "target" ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "Test.*\.java" || echo "0")
            ;;
        ruby)
            test_files=$(fast_find "." "*_spec.rb" 10 "vendor" ".git" && \
                        fast_find "." "*_test.rb" 10 "vendor" ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "spec\|test.*\.rb" || echo "0")
            ;;
        rust)
            # Rust tests are in same files or tests/ directory
            test_files=$(fast_find "tests" "*.rs" 10 "target" ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "\.rs" || echo "0")
            ;;
        cpp)
            test_files=$(fast_find "." "*_test.cpp" 10 "build" ".git" && \
                        fast_find "." "*_test.cc" 10 "build" ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "_test\." || echo "0")
            ;;
        bash)
            test_files=$(fast_find "." "*.bats" 10 ".git" && \
                        fast_find "tests" "test_*.sh" 10 ".git" | sort -u)
            test_count=$(echo "$test_files" | grep -c "bats\|test.*\.sh" || echo "0")
            ;;
        *)
            # Fallback to JavaScript
            test_files=$(fast_find "." "*.test.js" 10 "node_modules" ".git" "coverage" && \
                        fast_find "." "*.spec.js" 10 "node_modules" ".git" "coverage" | sort -u)
            test_count=$(echo "$test_files" | grep -c "test.js\|spec.js" || echo "0")
            ;;
    esac
    
    if [[ $test_count -eq 0 ]]; then
        print_warning "No test files found!"
        echo "CRITICAL: No test files exist" >> "$test_issues_file"
        ((issues++))
    else
        print_success "Found $test_count test files"
    fi
    
    # Check 2: Coverage report analysis (if available)
    print_info "Checking for coverage reports..."
    local coverage_exists=false
    local coverage_summary=""
    
    if [[ -f "coverage/coverage-summary.json" ]]; then
        coverage_exists=true
        coverage_summary=$(cat coverage/coverage-summary.json 2>/dev/null || echo "{}")
        print_success "Coverage report found"
        
        # Extract coverage percentage if available
        local coverage_percentage
        coverage_percentage=$(echo "$coverage_summary" | grep -o '"pct":[0-9.]*' | head -1 | cut -d':' -f2 || echo "unknown")
        if [[ "$coverage_percentage" != "unknown" ]]; then
            print_info "Overall coverage: ${coverage_percentage}%"
        fi
    else
        print_warning "No coverage report found - run 'npm run test:coverage' first"
        echo "Missing: Coverage report" >> "$test_issues_file"
        ((issues++))
    fi
    
    # Check 3: Identify untested code files
    print_info "Identifying potentially untested code..."
    local code_files
    code_files=$(fast_find "scripts" "*.js" 5 "node_modules" | wc -l)
    code_files=$((code_files + $(fast_find "scripts" "*.mjs" 5 "node_modules" | wc -l)))
    local untested_ratio=0
    local untested_count=0
    
    if [[ $code_files -gt 0 && $test_count -gt 0 ]]; then
        untested_ratio=$((code_files - test_count))
        untested_count=$untested_ratio
        if [[ $untested_ratio -gt 0 ]]; then
            print_warning "Potentially $untested_ratio code files without corresponding tests"
            echo "Untested files: ~$untested_ratio code files may lack tests" >> "$test_issues_file"
            ((issues++))
        fi
    fi
    
    # Check 4: Test organization validation
    print_info "Validating test organization..."
    local tests_in_tests_dir
    tests_in_tests_dir=$(fast_find "__tests__" "*.test.js" 5 | wc -l)
    local tests_colocated
    tests_colocated=$(fast_find "." "*.test.js" 10 "node_modules" ".git" "coverage" "__tests__" | wc -l)
    
    if [[ $tests_colocated -gt 0 ]]; then
        print_warning "Found $tests_colocated test files outside __tests__ directory"
        echo "Organization: $tests_colocated tests not in __tests__/" >> "$test_issues_file"
    fi
    
    # PHASE 2: AI-powered test strategy analysis
    print_info "Phase 2: Preparing AI-powered test strategy analysis..."
    
    # Gather test context
    local test_framework="Jest with ES Modules (experimental-vm-modules)"
    local test_env="jsdom"
    local test_issues_content
    test_issues_content=$(cat "$test_issues_file" 2>/dev/null || echo "   No automated issues detected")
    
    # Build comprehensive test analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step5_test_review_prompt \
        "$test_framework" \
        "$test_env" \
        "$test_count" \
        "$code_files" \
        "$tests_in_tests_dir" \
        "$tests_colocated" \
        "$coverage_exists" \
        "$test_issues_content" \
        "$test_files")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Test Review Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with test review prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to review existing tests?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step5_copilot_test_review_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            print_info "Extracting issues from Copilot log..."
            # Extract and save issues using library function
            extract_and_save_issues_from_log "5" "Test_Review" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Save step results using shared library
    save_step_results \
        "5" \
        "Test_Review" \
        "$issues" \
        "Test suite structure validated ($test_count test files found)" \
        "Found ${issues} test issues. ${untested_count} modules lack test coverage. Review and add missing tests." \
        "$test_issues_file" \
        "$test_count"
    
    cd "$PROJECT_ROOT" || return 1
    update_workflow_status "step5" "✅"
}

# Export step function
export -f step5_review_existing_tests
