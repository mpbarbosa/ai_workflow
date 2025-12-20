#!/bin/bash
set -euo pipefail

################################################################################
# Step 6: AI-Powered Test Generation (Language-Aware)
# Purpose: Generate new test code for untested modules (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.5.0
# Version: 2.1.0 (Phase 5 - Language-aware test generation)
################################################################################

# Module version information
readonly STEP6_VERSION="2.1.0"
readonly STEP6_VERSION_MAJOR=2
readonly STEP6_VERSION_MINOR=1
readonly STEP6_VERSION_PATCH=0

# Main step function - generates new tests with AI assistance
# Returns: 0 for success, 1 for failure
step6_generate_new_tests() {
    print_step "6" "Generate New Tests (if needed)"
    
    cd "$SRC_DIR" || return 1
    
    local tests_generated=0
    local generation_log_file
    generation_log_file=$(mktemp)
    TEMP_FILES+=("$generation_log_file")
    
    # PHASE 1: Automated gap analysis
    print_info "Phase 1: Automated test gap analysis..."
    
    # Check 1: Identify code files without tests (language-aware)
    print_info "Analyzing code coverage gaps..."
    local untested_files=()
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local source_dir="."
    
    # Find source files based on language
    case "$language" in
        javascript|typescript)
            source_dir="scripts"
            if [[ -d "$source_dir" ]]; then
                while IFS= read -r code_file; do
                    [[ -z "$code_file" ]] && continue
                    
                    local file_name
                    file_name=$(basename "$code_file" .js)
                    local test_file_1="__tests__/${file_name}.test.js"
                    local test_file_2="__tests__/${file_name}.spec.js"
                    
                    if [[ ! -f "$test_file_1" ]] && [[ ! -f "$test_file_2" ]]; then
                        untested_files+=("$code_file")
                        echo "Untested: $code_file" >> "$generation_log_file"
                    fi
                done < <(fast_find "$source_dir" "*.js" 5 "node_modules" ".git" "coverage")
            fi
            ;;
        python)
            source_dir="src"
            [[ ! -d "$source_dir" ]] && source_dir="."
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                [[ "$code_file" == *"__init__.py" ]] && continue
                [[ "$code_file" == *"test_"* ]] && continue
                [[ "$code_file" == *"_test.py" ]] && continue
                
                local file_dir file_name
                file_dir=$(dirname "$code_file")
                file_name=$(basename "$code_file" .py)
                local test_file="${file_dir}/test_${file_name}.py"
                
                if [[ ! -f "$test_file" ]]; then
                    untested_files+=("$code_file")
                    echo "Untested: $code_file" >> "$generation_log_file"
                fi
            done < <(fast_find "$source_dir" "*.py" 10 "__pycache__" ".git")
            ;;
        go)
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                [[ "$code_file" == *"_test.go" ]] && continue
                
                local test_file="${code_file%.go}_test.go"
                if [[ ! -f "$test_file" ]]; then
                    untested_files+=("$code_file")
                    echo "Untested: $code_file" >> "$generation_log_file"
                fi
            done < <(fast_find "." "*.go" 10 "vendor" ".git")
            ;;
        java)
            source_dir="src/main/java"
            [[ ! -d "$source_dir" ]] && source_dir="src"
            while IFS= read -r code_file; do
                [[ -z "$code_file" ]] && continue
                
                local class_name
                class_name=$(basename "$code_file" .java)
                local test_file="src/test/java/${class_name}Test.java"
                
                if [[ ! -f "$test_file" ]]; then
                    untested_files+=("$code_file")
                    echo "Untested: $code_file" >> "$generation_log_file"
                fi
            done < <(fast_find "$source_dir" "*.java" 10 "target" ".git")
            ;;
        *)
            # Fallback to JavaScript
            source_dir="scripts"
            if [[ -d "$source_dir" ]]; then
                while IFS= read -r code_file; do
                    [[ -z "$code_file" ]] && continue
                    
                    local file_name
                    file_name=$(basename "$code_file" .js)
                    local test_file_1="__tests__/${file_name}.test.js"
                    local test_file_2="__tests__/${file_name}.spec.js"
                    
                    if [[ ! -f "$test_file_1" ]] && [[ ! -f "$test_file_2" ]]; then
                        untested_files+=("$code_file")
                        echo "Untested: $code_file" >> "$generation_log_file"
                    fi
                done < <(find scripts -name "*.js" -o -name "*.mjs" 2>/dev/null)
            fi
            ;;
    esac
    
    local untested_count=${#untested_files[@]}
    
    if [[ $untested_count -eq 0 ]]; then
        print_success "All code files have corresponding tests"
    else
        print_warning "Found $untested_count code files without tests"
    fi
    
    # Check 2: Analyze existing tests for missing edge cases
    print_info "Analyzing test completeness..."
    local edge_case_gaps=0
    
    # Look for common testing anti-patterns
    if [[ -d "__tests__" ]]; then
        # Check for tests that might be incomplete (very short test files)
        while IFS= read -r test_file; do
            local line_count
            line_count=$(wc -l < "$test_file")
            if [[ $line_count -lt 20 ]]; then
                print_warning "Potentially incomplete test: $test_file ($line_count lines)"
                echo "Short test file: $test_file" >> "$generation_log_file"
                ((edge_case_gaps++))
            fi
        done < <(find __tests__ -name "*.test.js" -o -name "*.spec.js" 2>/dev/null)
    fi
    
    # Check 3: Prioritize test generation targets
    print_info "Prioritizing test generation targets..."
    local high_priority=()
    local medium_priority=()
    
    # High priority: main application files, utilities
    for file in "${untested_files[@]}"; do
        if [[ "$file" =~ main\.js|utils\.js|helper ]]; then
            high_priority+=("$file")
        else
            medium_priority+=("$file")
        fi
    done
    
    local high_count=${#high_priority[@]}
    local medium_count=${#medium_priority[@]}
    
    if [[ $high_count -gt 0 ]]; then
        print_warning "High priority: $high_count critical files need tests"
    fi
    
    # PHASE 2: AI-powered test code generation
    print_info "Phase 2: Preparing AI-powered test generation..."
    
    # Build comprehensive list of generation needs
    local generation_needs=""
    if [[ $untested_count -gt 0 ]]; then
        generation_needs+="Untested Files ($untested_count):\n"
        for file in "${untested_files[@]}"; do
            generation_needs+="  - $file\n"
        done
    fi
    
    local generation_log_content
    generation_log_content=$(cat "$generation_log_file" 2>/dev/null || echo "   No gaps detected - all code has tests")
    
    # Build comprehensive test generation prompt
    local copilot_prompt
    copilot_prompt="**Role**: You are a senior test-driven development (TDD) expert and code generation specialist with expertise in Jest testing framework, test pattern generation, edge case analysis, mock creation, and automated test scaffolding.

**Task**: Generate comprehensive test code for untested modules based on analysis from Step 5 (Test Review).

**Context:**
- Project: MP Barbosa Personal Website (static HTML + JavaScript with ES Modules)
- Test Framework: Jest with ES Modules (experimental-vm-modules)
- Test Environment: jsdom (for DOM testing)
- Untested Files: $untested_count
- High Priority: $high_count files
- Medium Priority: $medium_count files
- Incomplete Tests: $edge_case_gaps potential gaps

**Phase 1 Gap Analysis:**
$generation_log_content

**Generation Targets:**
$(echo -e "$generation_needs")

**Generation Tasks:**

1. **Unit Test Generation:**
   - Create test file templates for each untested module
   - Generate describe blocks for each function/class
   - Create test cases covering:
     * Happy path scenarios
     * Edge cases and boundary conditions
     * Error handling and exceptions
     * Input validation
   - Use proper Jest matchers (toBe, toEqual, toThrow, etc.)
   - Follow AAA pattern (Arrange-Act-Assert)

2. **Integration Test Scaffolds:**
   - Create integration test templates for workflows
   - Generate test cases for module interactions
   - Include proper setup/teardown
   - Mock external dependencies appropriately

3. **Edge Case Test Scenarios:**
   - Generate tests for null/undefined handling
   - Create tests for empty inputs
   - Generate tests for boundary values
   - Include tests for async/promise edge cases

4. **Mock and Stub Patterns:**
   - Generate mock implementations for dependencies
   - Create stub data fixtures
   - Provide spy usage examples
   - Include jest.mock() patterns for modules

5. **Test Data Fixtures:**
   - Generate realistic test data objects
   - Create fixture files if needed
   - Provide test data builders/factories
   - Include both valid and invalid data examples

**Code Generation Requirements:**

1. **File Structure:**
   - Test files in __tests__/ directory
   - Name pattern: [module].test.js
   - Proper ES Module imports
   - Jest configuration compatible

2. **Test Structure:**
   \`\`\`javascript
   import { functionName } from '../scripts/module.js';
   
   describe('Module/Function Name', () => {
     describe('functionName', () => {
       it('should handle valid input correctly', () => {
         // Arrange
         const input = 'test';
         
         // Act
         const result = functionName(input);
         
         // Assert
         expect(result).toBe(expectedOutput);
       });
       
       it('should throw error for invalid input', () => {
         expect(() => functionName(null)).toThrow();
       });
     });
   });
   \`\`\`

3. **Best Practices:**
   - Clear, behavior-focused test descriptions
   - One assertion per test (when possible)
   - Test isolation (no dependencies between tests)
   - Proper async/await handling
   - Meaningful variable names
   - Comments explaining complex test setups

4. **Coverage Goals:**
   - Aim for 80%+ code coverage
   - Cover all public APIs
   - Test error paths
   - Include performance-critical paths

**Expected Output:**
- Complete, runnable test files for each untested module
- Proper Jest syntax and patterns
- ES Module compatible imports
- Clear test descriptions
- Comprehensive edge case coverage
- Mock/stub examples where needed
- Test data fixtures if applicable
- Comments explaining test intent
- Ready to save to __tests__/ directory

Please generate complete, production-ready test code for the identified untested modules."

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Test Generation Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # Check if Copilot CLI is available
    if is_copilot_available; then
        print_info "GitHub Copilot CLI detected - ready for test code generation..."
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would invoke: copilot -p with test generation prompt"
        else
            # Smart triggering: Only generate if there are gaps
            if [[ $untested_count -gt 0 ]] || [[ $edge_case_gaps -gt 0 ]]; then
                if confirm_action "Generate test code for $untested_count untested files using Copilot CLI?"; then
                    # Save prompt to temporary file for tracking
                    local temp_prompt_file
                    temp_prompt_file=$(mktemp)
                    TEMP_FILES+=("$temp_prompt_file")
                    echo "$copilot_prompt" > "$temp_prompt_file"
                    
                    print_info "Starting Copilot CLI test generation session..."
                    print_info "This will generate actual Jest test code for untested modules"
                    echo ""
                    
                    # Create log file with unique timestamp
                    local log_timestamp
                    log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
                    local log_file="${LOGS_RUN_DIR}/step6_copilot_test_generation_${log_timestamp}.log"
                    print_info "Logging output to: $log_file"
                    
                    # Execute Copilot prompt
                    execute_copilot_prompt "$copilot_prompt" "$log_file"
                    
                    print_success "Copilot CLI test generation completed"
                    print_info "Full session log saved to: $log_file"
                    echo ""
                    
                    # Extract and save issues using library function
                    extract_and_save_issues_from_log "6" "Test_Generation" "$log_file"
                    echo ""
                    
                    # User confirmation of generated tests
                    if confirm_action "Were test files generated successfully?"; then
                        print_info "Please save generated test files to src/__tests__/ directory"
                        
                        if confirm_action "Have you saved the generated test files?"; then
                            print_success "Test files saved - ready for execution in Step 7"
                            ((tests_generated++))
                        else
                            print_warning "Test files not saved yet - save before continuing"
                            if [[ "$INTERACTIVE_MODE" == true ]]; then
                                if ! confirm_action "Continue without saving tests?"; then
                                    print_error "Workflow paused - save test files first"
                                    return 1
                                fi
                            fi
                        fi
                    else
                        print_warning "Test generation had issues - review and retry if needed"
                    fi
                else
                    print_warning "Skipped test generation"
                fi
            else
                print_success "No test generation needed - all code has tests"
                if [[ "$INTERACTIVE_MODE" == true ]]; then
                    if confirm_action "Generate additional edge case tests anyway?"; then
                        # Save prompt to temporary file for tracking
                        local temp_prompt_file
                        temp_prompt_file=$(mktemp)
                        TEMP_FILES+=("$temp_prompt_file")
                        echo "$copilot_prompt" > "$temp_prompt_file"
                        
                        # Create log file with unique timestamp
                        local log_timestamp
                        log_timestamp=$(date +%Y%m%d_%H%M%S_%N | cut -c1-21)
                        local log_file="${LOGS_RUN_DIR}/step6_copilot_test_generation_${log_timestamp}.log"
                        print_info "Logging output to: $log_file"
                        
                        execute_copilot_prompt "$copilot_prompt" "$log_file"
                        
                        print_info "Full session log saved to: $log_file"
                        
                        # Ask user if they want to save issues from the Copilot session
                        if confirm_action "Do you want to save issues from the Copilot session to the backlog?" "n"; then
                            if [[ -f "$log_file" ]]; then
                                local log_content
                                log_content=$(cat "$log_file")
                                
                                # Build issue extraction prompt using helper function
                                local extract_prompt
                                extract_prompt=$(build_issue_extraction_prompt "$log_file" "$log_content")

                                echo -e "\n${CYAN}Issue Extraction Prompt:${NC}"
                                echo -e "${YELLOW}${extract_prompt}${NC}\n"
                                
                                if confirm_action "Run GitHub Copilot CLI to extract and organize issues from the log?" "y"; then
                                    sleep 1
                                    print_info "Starting Copilot CLI session for issue extraction..."
                                    copilot -p "$extract_prompt" --allow-all-tools
                                    
                                    # Collect organized issues using reusable function
                                    local organized_issues
                                    organized_issues=$(collect_ai_output "Please copy the organized issues from Copilot output." "multi")
                                    
                                    if [[ -n "$organized_issues" ]]; then
                                        save_step_issues "6" "Test_Generation" "$organized_issues"
                                        print_success "Issues extracted from log and saved to backlog"
                                    else
                                        print_warning "No organized issues provided - skipping backlog save"
                                    fi
                                else
                                    print_warning "Skipped issue extraction - no backlog file created"
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    else
        print_warning "GitHub Copilot CLI not found - using manual approach"
        print_info "Install from: https://github.com/github/gh-copilot"
        print_info "For test generation, use the prompt above manually with Copilot"
    fi
    
    # Summary
    echo ""
    
    # Always save backlog file (even when no issues found)
    local step_issues=""
    if [[ $untested_count -eq 0 ]]; then
        print_success "Test coverage is complete ✅"
        save_step_summary "6" "Test_Generation" "All modules have test coverage. No new test generation required." "✅"
        
        # Save success status to backlog
        step_issues="### Test Generation Summary

**Untested Modules:** 0
**Tests Generated:** ${tests_generated}
**Edge Case Gaps:** ${edge_case_gaps}
**Status:** ✅ All Checks Passed

All modules have test coverage. No new test generation required.
"
    else
        if [[ $tests_generated -gt 0 ]]; then
            print_success "Generated tests for untested code ✅"
            save_step_summary "6" "Test_Generation" "Generated ${tests_generated} new test files for previously untested modules. Review and integrate new tests." "✅"
        else
            print_warning "Test generation skipped - $untested_count files remain untested"
            save_step_summary "6" "Test_Generation" "${untested_count} modules remain untested. Test generation recommended for complete coverage." "⚠️"
        fi
        
        # Save to backlog
        step_issues="### Test Generation Summary

**Untested Modules:** ${untested_count}
**Tests Generated:** ${tests_generated}
**Edge Case Gaps:** ${edge_case_gaps}

"
        if [[ -f "$generation_log_file" && -s "$generation_log_file" ]]; then
            step_issues+="### Untested Modules

\`\`\`
$(cat "$generation_log_file")
\`\`\`
"
        fi
    fi
    
    # Always save backlog file
    save_step_issues "6" "Test_Generation" "$step_issues"
    
    cd "$PROJECT_ROOT" || return 1
    update_workflow_status "step6" "✅"
}

# Export step function
export -f step6_generate_new_tests
