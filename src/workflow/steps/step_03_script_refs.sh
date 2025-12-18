#!/bin/bash
################################################################################
# Step 3: AI-Powered Script Reference Validation
# Purpose: Validate shell script references and documentation accuracy
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
################################################################################

# Module version information
readonly STEP3_VERSION="2.0.0"
readonly STEP3_VERSION_MAJOR=2
readonly STEP3_VERSION_MINOR=0
readonly STEP3_VERSION_PATCH=0

# Creates comprehensive script issue report and saves to backlog
# Arguments: 
#   $1 - issues_found count
#   $2 - script_issues_file path
#   $3 - missing_refs count
#   $4 - permission_issues count
#   $5 - undocumented count
#   $6 - script_count
# Returns: 0 for success
create_script_issue_report() {
    local issues_found="$1"
    local script_issues_file="$2"
    local missing_refs="$3"
    local permission_issues="$4"
    local undocumented="$5"
    local script_count="$6"
    
    # Only create report if issues were found
    if [[ "$issues_found" -eq 0 ]]; then
        return 0
    fi
    
    local report="## Script Reference Validation Issues\n\n"
    report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
    report+="**Total Scripts Checked**: ${script_count}\n"
    report+="**Total Issues Found**: ${issues_found}\n\n"
    
    # Parse issues file and categorize
    local missing_refs_section=""
    local permission_section=""
    local undocumented_section=""
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^Missing\ script\ reference:\ (.+)$ ]]; then
            local script_path="${BASH_REMATCH[1]}"
            missing_refs_section+="⚠️  **BROKEN REFERENCE**: Documentation references non-existent script\n"
            missing_refs_section+="   - Reference: \`${script_path}\`\n"
            missing_refs_section+="   - Source: \`shell_scripts/README.md\`\n"
            missing_refs_section+="   - Action: Remove reference or restore missing script\n\n"
        elif [[ "$line" =~ ^Non-executable:\ (.+)$ ]]; then
            local script_path="${BASH_REMATCH[1]}"
            permission_section+="⚠️  **NON-EXECUTABLE**: Script lacks executable permission\n"
            permission_section+="   - Script: \`${script_path}\`\n"
            permission_section+="   - Action: Run \`chmod +x ${script_path}\`\n\n"
        elif [[ "$line" =~ ^Undocumented:\ (.+)$ ]]; then
            local script_path="${BASH_REMATCH[1]}"
            undocumented_section+="⚠️  **MISSING DOCUMENTATION**: Script not documented in README\n"
            undocumented_section+="   - Script: \`${script_path}\`\n"
            undocumented_section+="   - Action: Add documentation to \`shell_scripts/README.md\`\n\n"
        fi
    done < "$script_issues_file"
    
    # Add missing references section if any found
    if [[ "$missing_refs" -gt 0 ]]; then
        report+="### Missing Script References (${missing_refs} found)\n\n"
        report+="$missing_refs_section"
    fi
    
    # Add permission issues section if any found
    if [[ "$permission_issues" -gt 0 ]]; then
        report+="### Permission Issues (${permission_issues} found)\n\n"
        report+="$permission_section"
    fi
    
    # Add undocumented scripts section if any found
    if [[ "$undocumented" -gt 0 ]]; then
        report+="### Undocumented Scripts (${undocumented} found)\n\n"
        report+="$undocumented_section"
    fi
    
    # Add recommended actions
    report+="### Recommended Actions\n\n"
    if [[ "$missing_refs" -gt 0 ]]; then
        report+="1. **Remove or Update Broken References**: Update documentation or restore missing scripts\n"
    fi
    if [[ "$permission_issues" -gt 0 ]]; then
        report+="2. **Fix Executable Permissions**: Run \`chmod +x [script_path]\` for each affected script\n"
    fi
    if [[ "$undocumented" -gt 0 ]]; then
        report+="3. **Document Scripts**: Add descriptions to \`shell_scripts/README.md\`\n"
    fi
    report+="4. **Re-run Validation**: Verify all issues are resolved\n"
    
    # Automatically save report to backlog
    save_step_issues "3" "Script_Reference_Validation" "$(echo -e "$report")"
    print_info "Script validation issues report saved to backlog"
    
    return 0
}

# Main step function - validates script references with AI assistance
# Returns: 0 for success, 1 for failure
step3_validate_script_references() {
    print_step "3" "Validate Script References"
    
    cd "$PROJECT_ROOT" || return 1
    
    local issues=0
    local missing_refs=0
    local permission_issues=0
    local undocumented=0
    local script_issues_file
    script_issues_file=$(mktemp)
    TEMP_FILES+=("$script_issues_file")
    
    # PHASE 1: Automated script reference validation
    print_info "Phase 1: Automated script reference validation..."
    
    # Check 1: Script reference checks - validate documented scripts exist
    if [[ -f "shell_scripts/README.md" ]]; then
        local script_refs
        script_refs=$(grep -oP '(?<=`\./)shell_scripts/[^`]+\.sh' "shell_scripts/README.md" 2>/dev/null || true)
        
        while IFS= read -r script; do
            [[ -z "$script" ]] && continue
            
            if [[ ! -f "$script" ]]; then
                print_warning "Referenced script not found: $script"
                echo "Missing script reference: $script" >> "$script_issues_file"
                ((missing_refs++))
                ((issues++))
            fi
        done <<< "$script_refs"
    fi
    
    # Check 2: Executable permission validation
    print_info "Checking executable permissions..."
    local non_executable
    non_executable=$(fast_find "shell_scripts" "*.sh" 5 "node_modules" ".git" | while read -r f; do [[ ! -x "$f" ]] && echo "$f"; done)
    
    if [[ -n "$non_executable" ]]; then
        print_warning "Non-executable scripts found:"
        echo "$non_executable"
        while IFS= read -r script; do
            [[ -z "$script" ]] && continue
            echo "Non-executable: $script" >> "$script_issues_file"
            ((permission_issues++))
        done <<< "$non_executable"
        ((issues++))
    fi
    
    # Check 3: Script inventory gathering
    print_info "Gathering script inventory..."
    local all_scripts
    all_scripts=$(fast_find "shell_scripts" "*.sh" 5 "node_modules" ".git" | sort)
    local script_count
    script_count=$(echo "$all_scripts" | wc -l)
    
    # Check 4: Undocumented script detection
    print_info "Checking for undocumented scripts..."
    while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        local script_name
        script_name=$(basename "$script")
        
        # Check if script is mentioned in shell_scripts/README.md
        if [[ -f "shell_scripts/README.md" ]]; then
            if ! grep -q "$script_name" "shell_scripts/README.md" 2>/dev/null; then
                print_warning "Undocumented script: $script"
                echo "Undocumented: $script" >> "$script_issues_file"
                ((undocumented++))
                ((issues++))
            fi
        fi
    done <<< "$all_scripts"
    
    # PHASE 2: AI-powered script reference validation
    print_info "Phase 2: Preparing AI-powered script reference analysis..."
    
    local script_issues_content
    script_issues_content=$(cat "$script_issues_file" 2>/dev/null || echo "   No automated issues detected")
    
    # Gather all scripts for AI analysis (reuse cached result)
    # all_scripts already populated above
    
    # Build comprehensive script validation prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step3_script_refs_prompt \
        "$script_count" \
        "${CHANGE_SCOPE}" \
        "$issues" \
        "$script_issues_content" \
        "$all_scripts")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Script Reference Validation Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with script reference validation prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to validate script references?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step3_copilot_script_validation_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "3" "Script_Reference_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Generate comprehensive script issue report if issues found
    if [[ "$issues" -gt 0 ]]; then
        print_info "Generating comprehensive script validation issue report..."
        create_script_issue_report "$issues" "$script_issues_file" "$missing_refs" "$permission_issues" "$undocumented" "$script_count"
        print_warning "Found ${issues} script validation issue(s) - review backlog for details"
    else
        print_success "No script validation issues detected ✅"
    fi
    
    # Save step results using shared library
    save_step_results \
        "3" \
        "Script_Reference_Validation" \
        "$issues" \
        "All script references valid in automated checks" \
        "Found ${issues} script validation issue(s). Review missing scripts, permission problems, or documentation gaps." \
        "$script_issues_file" \
        "$script_count"
    
    update_workflow_status "step3" "✅"
}

# Export step function and helper functions
export -f step3_validate_script_references
export -f create_script_issue_report
