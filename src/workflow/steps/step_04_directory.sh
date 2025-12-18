#!/bin/bash
################################################################################
# Step 4: AI-Powered Directory Structure Validation
# Purpose: Validate project directory structure and architectural organization
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
################################################################################

# Module version information
readonly STEP4_VERSION="2.0.0"
readonly STEP4_VERSION_MAJOR=2
readonly STEP4_VERSION_MINOR=0
readonly STEP4_VERSION_PATCH=0

# Main step function - validates directory structure with AI assistance
# Returns: 0 for success, 1 for failure
step4_validate_directory_structure() {
    print_step "4" "Validate Directory Structure"
    
    cd "$PROJECT_ROOT" || return 1
    
    local issues=0
    local structure_issues_file
    structure_issues_file=$(mktemp)
    TEMP_FILES+=("$structure_issues_file")
    
    # PHASE 1: Automated directory structure detection
    print_info "Phase 1: Automated directory structure detection..."
    
    # Check 1: Generate current directory structure
    print_info "Generating directory inventory..."
    local dir_tree=""
    if command -v tree &> /dev/null; then
        dir_tree=$(tree -d -L 3 -I 'node_modules|.git|coverage' --noreport 2>/dev/null || true)
    else
        # Fallback: use find if tree is not available
        dir_tree=$(find . -maxdepth 3 -type d ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" | sort)
    fi
    
    # Check 2: Validate expected critical directories exist
    print_info "Validating critical directories..."
    local critical_dirs=("src" "docs" "shell_scripts" ".github" "public")
    local missing_critical=0
    
    for dir in "${critical_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_warning "Critical directory missing: $dir"
            echo "Missing critical: $dir" >> "$structure_issues_file"
            ((missing_critical++))
            ((issues++))
        fi
    done
    
    # Check 3: Identify undocumented directories
    print_info "Checking for undocumented directories..."
    local undocumented_dirs=0
    
    # Check if directories are mentioned in documentation
    if [[ -f "README.md" ]] || [[ -f ".github/copilot-instructions.md" ]]; then
        while IFS= read -r dir; do
            [[ -z "$dir" || "$dir" == "." ]] && continue
            local dir_name
            dir_name=$(basename "$dir")
            
            # Skip common/expected directories
            [[ "$dir_name" =~ ^(node_modules|\.git|coverage|\.vscode)$ ]] && continue
            
            # Check if directory is documented
            local is_documented=false
            if [[ -f "README.md" ]] && grep -q "$dir_name" "README.md" 2>/dev/null; then
                is_documented=true
            fi
            if [[ -f ".github/copilot-instructions.md" ]] && grep -q "$dir_name" ".github/copilot-instructions.md" 2>/dev/null; then
                is_documented=true
            fi
            
            if [[ "$is_documented" == false ]]; then
                print_warning "Undocumented directory: $dir"
                echo "Undocumented: $dir" >> "$structure_issues_file"
                ((undocumented_dirs++))
                ((issues++))
            fi
        done < <(find . -maxdepth 2 -type d ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" ! -path "*/.vscode" | tail -n +2)
    fi
    
    # Check 4: Validate structure consistency with documented structure
    print_info "Validating structure against documentation..."
    local doc_structure_mismatch=0
    
    # Extract directory structure from copilot-instructions if it exists
    if [[ -f ".github/copilot-instructions.md" ]]; then
        # Look for directory structure documentation
        if grep -q "directory structure\|Directory Structure\|File Structure" ".github/copilot-instructions.md" 2>/dev/null; then
            # Basic check: are the key directories mentioned?
            local key_dirs=("src" "docs" "shell_scripts" "public")
            for dir in "${key_dirs[@]}"; do
                if grep -q "$dir" ".github/copilot-instructions.md" 2>/dev/null; then
                    if [[ ! -d "$dir" ]]; then
                        print_warning "Documented directory not found: $dir"
                        echo "Doc mismatch: $dir (documented but missing)" >> "$structure_issues_file"
                        ((doc_structure_mismatch++))
                        ((issues++))
                    fi
                fi
            done
        fi
    fi
    
    # PHASE 2: AI-powered architectural analysis
    print_info "Phase 2: Preparing AI-powered architectural analysis..."
    
    # Gather directory metadata
    local dir_count
    dir_count=$(find . -maxdepth 3 -type d ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/coverage/*" | wc -l)
    local structure_issues_content
    structure_issues_content=$(cat "$structure_issues_file" 2>/dev/null || echo "   No automated issues detected")
    
    # Get directory tree for AI analysis
    local dir_tree
    dir_tree=$(tree -L 3 -d -I 'node_modules|.git|coverage' 2>/dev/null || find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/coverage/*' | head -50)
    
    # Build comprehensive architectural analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step4_directory_prompt \
        "$dir_count" \
        "${CHANGE_SCOPE}" \
        "$missing_critical" \
        "$undocumented_dirs" \
        "$doc_structure_mismatch" \
        "$structure_issues_content" \
        "$dir_tree")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Directory Structure Validation Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with directory structure validation prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to validate directory structure?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step4_copilot_directory_validation_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "4" "Directory_Structure_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Save step results using shared library
    # Handle critical directory failures specially
    if [[ $missing_critical -gt 0 ]]; then
        print_error "Critical: $missing_critical critical directories missing!"
        local failure_msg="CRITICAL: ${missing_critical} critical directories missing. Found ${issues} total structural issues requiring immediate attention."
        save_step_summary "4" "Directory_Structure_Validation" "$failure_msg" "❌"
        
        # Build detailed critical issues
        local step_issues="### Directory Structure Issues Found

**Total Issues:** ${issues}
**Missing Critical Directories:** ${missing_critical}

"
        if [[ -f "$structure_issues_file" && -s "$structure_issues_file" ]]; then
            step_issues+="### Details

\`\`\`
$(cat "$structure_issues_file")
\`\`\`
"
        fi
        save_step_issues "4" "Directory_Structure_Validation" "$step_issues"
    else
        save_step_results \
            "4" \
            "Directory_Structure_Validation" \
            "$issues" \
            "Directory structure valid in automated checks" \
            "Found ${issues} structural issues. Review missing or misorganized directories." \
            "$structure_issues_file" \
            "$dir_count"
    fi
    
    update_workflow_status "step4" "✅"
}

# Export step function
export -f step4_validate_directory_structure
