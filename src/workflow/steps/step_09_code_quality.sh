#!/bin/bash
set -euo pipefail

################################################################################
# Step 9: AI-Powered Code Quality Validation
# Purpose: Validate code quality, detect anti-patterns, assess maintainability (adaptive)
# Part of: Tests & Documentation Workflow Automation v2.3.1
# Version: 2.1.0 (Phase 3 - Adaptive)
################################################################################

# Module version information
readonly STEP9_VERSION="2.1.0"
readonly STEP9_VERSION_MAJOR=2
readonly STEP9_VERSION_MINOR=1
readonly STEP9_VERSION_PATCH=0

# Main step function - validates code quality with AI assistance
# Returns: 0 for success, 1 for failure
step9_code_quality_validation() {
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
    
    # Count file types for summary
    local js_files=$(find . -type f \( -name "*.js" -o -name "*.mjs" \) ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local html_files=$(find . -type f -name "*.html" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local css_files=$(find . -type f -name "*.css" ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null | wc -l)
    local total_files=$((js_files + html_files + css_files))
    
    # Find JavaScript files over 300 lines (cache results for reuse)
    local all_js_files=$(fast_find "." "*.js" 10 "node_modules" ".git" "coverage" && fast_find "." "*.mjs" 10 "node_modules" ".git" "coverage")
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local line_count=$(wc -l < "$file" 2>/dev/null || echo 0)
        if [[ $line_count -gt 300 ]]; then
            ((large_files_count++))
            large_files_list+="  - $file ($line_count lines)\n"
            echo "Large file: $file ($line_count lines)" >> "$quality_report"
        fi
    done <<< "$all_js_files"
    
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
    if command -v grep &> /dev/null; then
        # Count function declarations
        local function_count=$(grep -r "^function\|^const.*=.*function\|^export function" . --include="*.js" --include="*.mjs" 2>/dev/null | wc -l)
        echo "Function declarations: $function_count" >> "$quality_report"
        
        # Basic check: if too many functions in small codebase
        if [[ $function_count -gt 100 ]] && [[ $js_files -lt 10 ]]; then
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
    copilot_prompt=$(build_step9_code_quality_prompt \
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
            local log_file="${LOGS_RUN_DIR}/step9_copilot_code_quality_review_${log_timestamp}.log"
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

# Export step function
export -f step9_code_quality_validation
