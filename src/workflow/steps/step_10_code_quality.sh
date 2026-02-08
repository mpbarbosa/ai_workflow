#!/bin/bash
set -euo pipefail

################################################################################
# Step 10: AI-Powered Code Quality Validation
# Purpose: Validate code quality, detect anti-patterns, assess maintainability (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.3.9
# Version: 2.1.0 (Phase 3 - Adaptive)
################################################################################

# Module version information
readonly STEP10_VERSION="2.1.0"
readonly STEP10_VERSION_MAJOR=2
readonly STEP10_VERSION_MINOR=1
readonly STEP10_VERSION_PATCH=0

# Main step function - validates code quality with AI assistance
# Returns: 0 for success, 1 for failure
step10_code_quality_validation() {
    print_step "9" "Code Quality Validation"
    
    cd "$SRC_DIR"
    
    local quality_issues=0
    local quality_report=$(mktemp)
    TEMP_FILES+=("$quality_report")
    
    # PHASE 1: Automated code quality checks (ADAPTIVE - Phase 3)
    local language="${PRIMARY_LANGUAGE:-javascript}"
    local lint_cmd=""
    
    # Get lint command from tech stack (Phase 3 integration)
    if command -v get_lint_command &>/dev/null; then
        lint_cmd=$(get_lint_command)
    else
        # Fallback to LINT_COMMAND variable
        lint_cmd="${LINT_COMMAND:-npm run lint}"
    fi
    
    print_info "Phase 1: Automated code quality analysis (${language})..."
    
    # Check for code changes optimization (v2.7.0)
    # Use incremental code quality checks if available
    local incremental_success=false
    if [[ "${CODE_CHANGES_OPTIMIZATION:-false}" == "true" ]] && [[ "${CODE_CHANGES_STRATEGY:-}" == "incremental" ]]; then
        print_info "Attempting incremental code quality checks..."
        
        if type -t execute_incremental_code_quality > /dev/null 2>&1; then
            if execute_incremental_code_quality; then
                incremental_success=true
                print_success "Incremental code quality checks passed"
                save_step_summary "9" "Code_Quality" "Incremental checks passed (code changes optimization)" "✅"
                return 0
            else
                print_info "Incremental checks completed with warnings - proceeding with full analysis"
            fi
        fi
    fi
    
    if [[ -n "$lint_cmd" ]]; then
        print_info "Linter command: $lint_cmd"
    else
        print_info "No linter configured for ${language}"
    fi
    
    # Check 1: Enumerate code files (adaptive)
    print_info "Enumerating ${language} code files..."
    local source_files_list=""
    if command -v find_source_files &>/dev/null; then
        source_files_list=$(find_source_files 2>/dev/null || echo "")
    else
        # Fallback to generic find
        source_files_list=$(find . -type f -name "*.${language}" 2>/dev/null | grep -v node_modules | head -100 || echo "")
    fi
    local source_file_count=$(echo "$source_files_list" | grep -v "^$" | wc -l)
    
    print_info "Source files: $source_file_count"
    echo "File count: $source_file_count ${language} files" >> "$quality_report"
    
    # Check 1.5: Run language-specific linter (ADAPTIVE)
    if [[ -n "$lint_cmd" ]]; then
        print_info "Running ${language} linter..."
        local lint_output=$(mktemp)
        TEMP_FILES+=("$lint_output")
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would execute: $lint_cmd"
        else
            # Use execute_language_command if available (Phase 3)
            local lint_result=0
            if command -v execute_language_command &>/dev/null; then
                execute_language_command "$lint_cmd" "Linting" > "$lint_output" 2>&1 || lint_result=$?
            else
                eval "$lint_cmd" > "$lint_output" 2>&1 || lint_result=$?
            fi
            
            if [[ $lint_result -eq 0 ]]; then
                print_success "Linter passed with no issues"
            else
                print_warning "Linter found issues"
                local lint_issue_count=$(wc -l < "$lint_output" 2>/dev/null || echo 0)
                echo "Linter issues: $lint_issue_count" >> "$quality_report"
                head -20 "$lint_output" >> "$quality_report" 2>/dev/null
                ((quality_issues++))
            fi
        fi
    else
        print_info "No linter configured for ${language} - skipping lint check"
    fi
    
    # Check 2: Analyze file sizes and complexity
    print_info "Analyzing code complexity..."
    local large_files_count=0
    local large_files_list=""
    
    # NEW: Shell script complexity analysis with shellmetrics (v3.1.0)
    if [[ "$language" == "bash" ]] && command -v shellmetrics >/dev/null 2>&1; then
        print_info "Running shellmetrics for bash script complexity analysis..."
        local shellmetrics_output=$(mktemp)
        TEMP_FILES+=("$shellmetrics_output")
        
        # Find all shell scripts
        local shell_scripts=$(find . -type f -name "*.sh" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null)
        
        if [[ -n "$shell_scripts" ]]; then
            # Run shellmetrics and capture output
            echo "$shell_scripts" | xargs shellmetrics --no-color 2>/dev/null > "$shellmetrics_output" || true
            
            if [[ -s "$shellmetrics_output" ]]; then
                print_success "Shellmetrics analysis complete"
                
                # Extract key metrics
                local total_functions=$(grep "function(s) analyzed" "$shellmetrics_output" | grep -o '[0-9]\+ function' | cut -d' ' -f1)
                local avg_ccn=$(tail -3 "$shellmetrics_output" | grep -o 'CCN.*avg' | awk '{print $2}' | head -1)
                local avg_lloc=$(tail -3 "$shellmetrics_output" | grep -o 'LLOC.*avg' | awk '{print $2}' | head -1)
                
                echo "Shell Script Complexity Metrics:" >> "$quality_report"
                echo "  Total functions: ${total_functions:-0}" >> "$quality_report"
                echo "  Average CCN (Cyclomatic Complexity): ${avg_ccn:-N/A}" >> "$quality_report"
                echo "  Average LLOC (Logical Lines of Code): ${avg_lloc:-N/A}" >> "$quality_report"
                
                # Check for high complexity functions (CCN > 10 or LLOC > 100)
                local high_complexity=$(awk '/LLOC  CCN  Location/,/^-+$/ {if ($2 > 10 || $1 > 100) print}' "$shellmetrics_output" | grep -v "^-" | grep -v "LLOC  CCN")
                if [[ -n "$high_complexity" ]]; then
                    print_warning "Found functions with high complexity (CCN>10 or LLOC>100)"
                    echo "" >> "$quality_report"
                    echo "High Complexity Functions:" >> "$quality_report"
                    echo "$high_complexity" >> "$quality_report"
                    ((quality_issues++))
                else
                    print_success "All functions have acceptable complexity"
                fi
                
                # Append full shellmetrics report
                echo "" >> "$quality_report"
                echo "=== Full Shellmetrics Report ===" >> "$quality_report"
                cat "$shellmetrics_output" >> "$quality_report"
            fi
        else
            print_info "No shell scripts found for complexity analysis"
        fi
    elif [[ "$language" == "bash" ]]; then
        print_warning "shellmetrics not found - install from https://github.com/ko1nksm/shellmetrics"
        print_info "Falling back to basic line counting..."
    fi
    
    # Count file types for summary
    local js_files=$(find . -type f \( -name "*.js" -o -name "*.mjs" \) ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local html_files=$(find . -type f -name "*.html" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local css_files=$(find . -type f -name "*.css" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local sh_files=$(find . -type f -name "*.sh" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local total_files=$((js_files + html_files + css_files + sh_files))
    
    
    # Find JavaScript/Shell files over 300 lines (cache results for reuse)
    if [[ "$language" == "bash" ]]; then
        # For shell scripts
        local all_source_files=$(fast_find "." "*.sh" 10 "node_modules" ".git" "coverage")
    else
        # For JavaScript
        local all_source_files=$(fast_find "." "*.js" 10 "node_modules" ".git" "coverage" && fast_find "." "*.mjs" 10 "node_modules" ".git" "coverage")
    fi
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local line_count=$(wc -l < "$file" 2>/dev/null || echo 0)
        if [[ $line_count -gt 300 ]]; then
            ((large_files_count++))
            large_files_list+="  - $file ($line_count lines)\n"
            echo "Large file: $file ($line_count lines)" >> "$quality_report"
        fi
    done <<< "$all_source_files"
    
    if [[ $large_files_count -gt 0 ]]; then
        print_warning "Found $large_files_count large files (>300 lines) - may need refactoring"
        ((quality_issues++))
    else
        print_success "All files are reasonably sized"
    fi
    
    # Check 3: Naming convention validation
    print_info "Validating naming conventions..."
    local naming_issues=0
    
    # Check for non-kebab-case HTML files
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local basename=$(basename "$file")
        if [[ "$basename" =~ [A-Z_] ]]; then
            ((naming_issues++))
            echo "Naming issue: $file (not kebab-case)" >> "$quality_report"
        fi
    done < <(find . -name "*.html" 2>/dev/null)
    
    if [[ $naming_issues -gt 0 ]]; then
        print_warning "Found $naming_issues naming convention issues"
        ((quality_issues++))
    else
        print_success "Naming conventions followed"
    fi
    
    # Check 4: Detect potential code duplication
    print_info "Checking for potential code duplication..."
    local duplicate_patterns=0
    
    # Look for common duplicate patterns
    if [[ "$language" == "javascript" ]]; then
        # Count function declarations (JavaScript-specific)
        local function_count=$(grep -r "^function\|^const.*=.*function\|^export function" . --include="*.js" --include="*.mjs" 2>/dev/null | wc -l)
        echo "Function declarations: $function_count" >> "$quality_report"
        
        # Basic check: if too many functions in small codebase
        if [[ $function_count -gt 100 ]] && [[ $js_files -lt 10 ]]; then
            print_warning "High function count relative to file count - check for duplication"
            ((duplicate_patterns++))
        fi
    elif [[ "$language" == "bash" ]] && [[ -s "${shellmetrics_output:-}" ]]; then
        # Use shellmetrics data for bash projects
        local function_count=$(grep "function(s) analyzed" "$shellmetrics_output" 2>/dev/null | grep -o '[0-9]\+ function' | cut -d' ' -f1)
        echo "Function count (from shellmetrics): ${function_count:-0}" >> "$quality_report"
        
        # Check function count relative to file count
        if [[ ${function_count:-0} -gt 100 ]] && [[ $sh_files -lt 10 ]]; then
            print_warning "High function count relative to file count - check for duplication"
            ((duplicate_patterns++))
        fi
    fi
    
    # Check 5: Validate ES Module patterns
    print_info "Validating ES Module usage..."
    local module_issues=0
    
    # Check for proper import/export usage
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Check if file uses modern ES modules
        if grep -q "^import\|^export" "$file" 2>/dev/null; then
            # Good - using ES modules
            :
        elif grep -q "require(" "$file" 2>/dev/null; then
            # Found CommonJS pattern
            echo "Module issue: $file uses require() instead of import" >> "$quality_report"
            ((module_issues++))
        fi
    done < <(find . -name "*.js" -o -name "*.mjs" 2>/dev/null | grep -v node_modules | grep -v vendor)
    
    if [[ $module_issues -gt 0 ]]; then
        print_warning "Found $module_issues files using CommonJS instead of ES modules"
        ((quality_issues++))
    fi
    
    # Check 6: Code organization assessment
    print_info "Assessing code organization..."
    local dirs_with_js=$(find . -type f \( -name "*.js" -o -name "*.mjs" \) -exec dirname {} \; 2>/dev/null | sort -u | wc -l)
    
    echo "Code organization: JavaScript files spread across $dirs_with_js directories" >> "$quality_report"
    
    # PHASE 2: AI-powered code quality review
    print_info "Phase 2: Preparing AI-powered code quality review..."
    
    # Build quality summary
    local quality_summary="Code Quality Analysis Summary:
- Total Files: $total_files ($js_files JS, $html_files HTML, $css_files CSS)
- Large Files (>300 lines): $large_files_count
- Naming Convention Issues: $naming_issues
- Module Pattern Issues: $module_issues
- Code Organization: $dirs_with_js directories
- Quality Issues: $quality_issues"
    
    # Sample problematic files for review
    local sample_files=$(find . -name "*.js" -o -name "*.mjs" 2>/dev/null | grep -v node_modules | head -5)
    local sample_code=""
    
    for file in $sample_files; do
        [[ -z "$file" ]] && continue
        sample_code+="
File: $file
Lines: $(wc -l < "$file" 2>/dev/null || echo 0)
Preview:
$(head -50 "$file" 2>/dev/null)  # Increased from 30 lines (Dec 15, 2025) for better file preview
---
"
    done
    
    local quality_report_content=$(cat "$quality_report" 2>/dev/null || echo "   No critical issues detected")
    
    # Build comprehensive code quality prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step10_code_quality_prompt \
        "$total_files" \
        "$js_files" \
        "$html_files" \
        "$css_files" \
        "$quality_summary" \
        "$quality_report_content" \
        "$large_files_list" \
        "$sample_code")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Code Quality Review Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with code quality review prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to review code quality?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step10_copilot_code_quality_review_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file" "step09" "code_quality_engineer"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "9" "Code_Quality_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Handle critical quality issues
    if [[ $quality_issues -gt 3 ]]; then
        if confirm_action "Multiple code quality issues found - continue workflow?"; then
            print_warning "Continuing despite quality issues - address in future iterations"
        else
            print_error "Workflow paused - improve code quality first"
            cd "$PROJECT_ROOT"
            return 1
        fi
    fi
    
    # Save step results using shared library
    save_step_results \
        "9" \
        "Code_Quality_Validation" \
        "$quality_issues" \
        "Code quality validation passed ($total_files files analyzed)" \
        "Found ${quality_issues} code quality improvements needed across ${total_files} files. Review and apply quality enhancements." \
        "$quality_report" \
        "$total_files"
    
    cd "$PROJECT_ROOT"
    update_workflow_status "step9" "✅"
}

# Alias for backward compatibility (main script calls step9_code_quality_validation)
step9_code_quality_validation() {
    step10_code_quality_validation "$@"
}

# Export step function
export -f step10_code_quality_validation step9_code_quality_validation
