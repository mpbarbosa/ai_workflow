#!/bin/bash
set -euo pipefail

################################################################################
# Step 12: Markdown Linting Validation
# Purpose: Validate markdown formatting with mdl and catch errors before commit
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
# Tool: mdl (markdownlint Ruby gem) - https://github.com/markdownlint/markdownlint
################################################################################

# Module version information
readonly STEP12_VERSION="2.1.0"
readonly STEP12_VERSION_MAJOR=2
readonly STEP12_VERSION_MINOR=1
readonly STEP12_VERSION_PATCH=0

# Main step function - validates markdown files with mdl linting
# Returns: 0 for success, 1 for failure
step12_markdown_linting() {
    print_step "12" "Markdown Linting"
    
    cd "$PROJECT_ROOT"
    
    local lint_issues=0
    local lint_report=$(mktemp)
    TEMP_FILES+=("$lint_report")
    
    # PHASE 1: Automated markdown linting with mdl
    print_info "Phase 1: Markdown linting analysis with mdl..."
    
    # Check 1: Enumerate markdown files
    print_info "Enumerating markdown files..."
    local md_files_count=$(fast_find "." "*.md" 5 "node_modules" "coverage" ".git" | wc -l)
    
    print_info "Found $md_files_count markdown files to lint"
    echo "Markdown files found: $md_files_count" >> "$lint_report"
    
    # Check 2: Verify mdl is installed
    print_info "Checking for mdl (markdownlint)..."
    if command -v mdl &> /dev/null; then
        local mdl_version=$(mdl --version 2>&1)
        print_success "mdl is installed: $mdl_version"
        echo "mdl version: $mdl_version" >> "$lint_report"
    else
        print_error "mdl not found - install with: gem install mdl"
        ((lint_issues++))
        save_step_issues "12" "Markdown_Linting" "❌ mdl not installed. Install with: gem install mdl"
        save_step_summary "12" "Markdown_Linting" "❌ FAIL" "mdl linter not installed"
        WORKFLOW_STATUS[step12]="❌ FAIL - mdl not installed"
        return 1
    fi
    
    # Check 3: Run mdl on all markdown files
    print_info "Running mdl on all markdown files..."
    
    # Create temporary file for mdl output
    local mdl_output=$(mktemp)
    TEMP_FILES+=("$mdl_output")
    
    # Run mdl and capture output
    if [[ "$DRY_RUN" == false ]]; then
        # mdl options:
        # --git-recurse: Only check files tracked by git
        # --ignore-front-matter: Ignore YAML front matter
        mdl --git-recurse --ignore-front-matter . > "$mdl_output" 2>&1 || true
        
        local lint_error_count=$(wc -l < "$mdl_output" 2>/dev/null || echo 0)
        
        if [[ $lint_error_count -eq 0 ]]; then
            print_success "✅ No markdown linting errors found"
            echo "✅ All markdown files pass mdl linting" >> "$lint_report"
        else
            print_warning "Found $lint_error_count markdown linting violations"
            ((lint_issues++))
            
            # Add detailed output to report
            echo "" >> "$lint_report"
            echo "## mdl Linting Violations" >> "$lint_report"
            echo "" >> "$lint_report"
            cat "$mdl_output" >> "$lint_report"
            
            # Show summary
            print_info "Markdown linting violations:"
            head -50 "$mdl_output" | while read -r line; do
                echo "  $line"
            done
            
            if [[ $lint_error_count -gt 20 ]]; then
                print_info "... and $((lint_error_count - 20)) more (see backlog report)"
            fi
        fi
    else
        print_info "Dry run - skipping mdl execution"
    fi
    
    # Check 4: Validate specific critical files
    print_info "Validating critical markdown files..."
    local critical_files=(
        "README.md"
        ".github/copilot-instructions.md"
        "shell_scripts/README.md"
        "docs/MARKDOWN_BEST_PRACTICES.md"
    )
    
    local missing_files=0
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            print_warning "Critical file missing: $file"
            ((missing_files++))
            echo "⚠️ Missing critical file: $file" >> "$lint_report"
        fi
    done
    
    if [[ $missing_files -eq 0 ]]; then
        print_success "All critical markdown files present"
    else
        ((lint_issues++))
    fi
    
    # Check 5: Check for common markdown anti-patterns
    print_info "Checking for common markdown anti-patterns..."
    local antipattern_count=0
    
    # Check for missing spaces after hash symbols
    local missing_space_files=$(grep -l "^#[^# ]" $(find . -name "*.md" -not -path "*/node_modules/*" 2>/dev/null) 2>/dev/null | wc -l)
    if [[ $missing_space_files -gt 0 ]]; then
        print_warning "Found $missing_space_files files with missing spaces after #"
        ((antipattern_count++))
        echo "⚠️ $missing_space_files files with missing spaces after # (heading syntax)" >> "$lint_report"
    fi
    
    # Check for malformed bold text (single asterisk before double)
    local malformed_bold=$(grep -r "\s\*[^\*].*\*\*:" $(find . -name "*.md" -not -path "*/node_modules/*" 2>/dev/null) 2>/dev/null | wc -l)
    if [[ $malformed_bold -gt 0 ]]; then
        print_warning "Found potential malformed bold formatting"
        ((antipattern_count++))
        echo "⚠️ Potential malformed bold formatting patterns detected" >> "$lint_report"
    fi
    
    if [[ $antipattern_count -eq 0 ]]; then
        print_success "No common anti-patterns detected"
    else
        ((lint_issues++))
    fi
    
    # PHASE 2: AI-powered markdown review (if in interactive mode)
    if [[ "$INTERACTIVE_MODE" == true ]] && command -v copilot &> /dev/null; then
        print_info ""
        print_info "Phase 2: AI-powered markdown quality review..."
        print_info "Preparing AI analysis request..."
        
        local ai_prompt_file=$(mktemp)
        TEMP_FILES+=("$ai_prompt_file")
        
        cat > "$ai_prompt_file" << 'EOF'
You are a Technical Documentation Specialist with expertise in markdown best practices.

# Your Task
Review the markdown linting results and provide recommendations for improving documentation quality.

# Markdown Linting Results
$(cat "$lint_report")

# Git Context
Branch: $(get_git_current_branch)
Modified markdown files: $(get_git_status_short_output | grep "\.md$" | wc -l)

# Analysis Request
Please provide:
1. **Severity Assessment**: Rate the overall markdown quality (Excellent/Good/Needs Improvement/Poor)
2. **Critical Issues**: Identify must-fix issues that affect rendering or accessibility
3. **Style Issues**: Note formatting inconsistencies that should be addressed
4. **Best Practice Recommendations**: Suggest improvements based on markdownguide.org standards
5. **Quick Fixes**: Provide specific sed/awk commands or manual fixes for common issues

# Output Format
Provide a concise analysis (200-300 words) focusing on actionable recommendations.
EOF
        
        print_info "Triggering AI analysis..."
        print_info "${CYAN}Please review the markdown linting results and provide recommendations.${NC}"
        print_info ""
        
        if [[ "$AUTO_MODE" == false ]]; then
            print_info "Opening GitHub Copilot for interactive review..."
            print_info "Copy the analysis from Copilot and save it to improve documentation."
            copilot -p "$(cat "$ai_prompt_file")" || print_warning "Copilot interaction skipped or failed"
        else
            print_info "Auto mode: Skipping interactive AI review"
        fi
    fi
    
    # Generate step backlog report
    generate_step_backlog "12" "Markdown Linting" "$lint_report" "$lint_issues"
    
    # Generate step summary
    local summary_status="✅ PASS"
    [[ $lint_issues -gt 0 ]] && summary_status="⚠️ WARNINGS"
    
    generate_step_summary "12" "Markdown Linting" "$summary_status" \
        "Linted $md_files_count files" \
        "Found $lint_issues issue categories" \
        "markdownlint integration complete"
    
    # Update workflow status
    if [[ $lint_issues -eq 0 ]]; then
        WORKFLOW_STATUS[step12]="✅ PASS - No linting issues"
        print_success "Markdown linting validation passed"
        return 0
    else
        WORKFLOW_STATUS[step12]="⚠️ WARNINGS - $lint_issues issue categories"
        print_warning "Markdown linting completed with warnings"
        return 0  # Non-blocking - warnings don't fail the workflow
    fi
}
