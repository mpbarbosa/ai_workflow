#!/bin/bash
################################################################################
# Step 8: AI-Powered Dependency Validation
# Purpose: Validate npm dependencies and environment configuration
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
################################################################################

# Module version information
readonly STEP8_VERSION="2.0.0"
readonly STEP8_VERSION_MAJOR=2
readonly STEP8_VERSION_MINOR=0
readonly STEP8_VERSION_PATCH=0

# Main step function - validates dependencies with AI assistance
# Returns: 0 for success, 1 for failure
step8_validate_dependencies() {
    print_step "8" "Validate Dependencies & Environment"
    
    cd "$SRC_DIR" || return 1
    
    local issues=0
    local dependency_report
    dependency_report=$(mktemp)
    TEMP_FILES+=("$dependency_report")
    
    # PHASE 1: Automated dependency analysis
    print_info "Phase 1: Automated dependency analysis..."
    
    # Check 1: Verify package.json exists and is valid
    print_info "Validating package.json..."
    if [[ ! -f "package.json" ]]; then
        print_error "package.json not found!"
        echo "CRITICAL: Missing package.json" >> "$dependency_report"
        ((issues++))
        
        # Save error to backlog before returning
        local step_issues="### Dependency Validation - CRITICAL ERROR

**Total Issues:** ${issues}
**Status:** ❌ FAILED

CRITICAL: Missing package.json file. Cannot validate dependencies.
"
        save_step_issues "8" "Dependency_Validation" "$step_issues"
        save_step_summary "8" "Dependency_Validation" "CRITICAL: Missing package.json file." "❌"
        
        cd "$PROJECT_ROOT" || return 1
        update_workflow_status "step8" "❌"
        return 1
    else
        # Validate JSON syntax
        if jq empty package.json &>/dev/null; then
            print_success "package.json is valid JSON"
        else
            print_error "package.json contains invalid JSON"
            echo "CRITICAL: Invalid package.json syntax" >> "$dependency_report"
            ((issues++))
            
            # Save error to backlog before returning
            local step_issues="### Dependency Validation - CRITICAL ERROR

**Total Issues:** ${issues}
**Status:** ❌ FAILED

CRITICAL: Invalid package.json syntax. Cannot validate dependencies.
"
            save_step_issues "8" "Dependency_Validation" "$step_issues"
            save_step_summary "8" "Dependency_Validation" "CRITICAL: Invalid package.json syntax." "❌"
            
            cd "$PROJECT_ROOT" || return 1
            update_workflow_status "step8" "❌"
            return 1
        fi
    fi
    # Check 2: Run npm audit for security vulnerabilities
    print_info "Running npm audit for security vulnerabilities..."
    local audit_output
    audit_output=$(mktemp)
    TEMP_FILES+=("$audit_output")
    
    local vuln_count=0
    if npm audit --json > "$audit_output" 2>&1; then
        print_success "No security vulnerabilities found"
    else
        local vulnerabilities
        vulnerabilities=$(jq -r '.metadata.vulnerabilities | to_entries[] | "\(.key): \(.value)"' "$audit_output" 2>/dev/null || echo "Unable to parse")
        vuln_count=$(echo "$vulnerabilities" | grep -c ":" || echo "0")
        print_warning "Security vulnerabilities detected"
        echo "Security vulnerabilities:" >> "$dependency_report"
        echo "$vulnerabilities" >> "$dependency_report"
        ((issues++))
    fi
    
    print_info "Checking for outdated packages..."
    local outdated_output
    outdated_output=$(mktemp)
    TEMP_FILES+=("$outdated_output")
    
    local outdated_count=0
    if npm outdated --json > "$outdated_output" 2>&1; then
        print_success "All packages are up to date"
    else
        outdated_count=$(jq 'length' "$outdated_output" 2>/dev/null || echo "0")
        if [[ $outdated_count -gt 0 ]]; then
            print_warning "$outdated_count packages are outdated"
            echo "Outdated packages: $outdated_count" >> "$dependency_report"
            jq -r 'to_entries[] | "\(.key): \(.value.current) -> \(.value.latest)"' "$outdated_output" >> "$dependency_report" 2>/dev/null
        fi
    fi
    
    # Check 4: Verify lockfile integrity
    print_info "Verifying package-lock.json integrity..."
    if [[ -f "package-lock.json" ]]; then
        if npm ls &>/dev/null; then
            print_success "Lockfile integrity verified"
        else
            print_warning "Dependency tree has issues - may need npm install"
            echo "Lockfile issues: Dependency tree inconsistent" >> "$dependency_report"
            ((issues++))
        fi
    else
        print_warning "package-lock.json not found"
        echo "Missing lockfile: Recommended to commit package-lock.json" >> "$dependency_report"
    fi
    
    # Check 5: Verify Node.js and npm versions
    print_info "Checking Node.js and npm versions..."
    local node_version
    local npm_version
    node_version=$(node --version 2>/dev/null || echo "not installed")
    npm_version=$(npm --version 2>/dev/null || echo "not installed")
    
    print_info "Node.js: $node_version, npm: $npm_version"
    echo "Environment: Node.js $node_version, npm $npm_version" >> "$dependency_report"
    
    # Check 6: Analyze dependency count and size
    print_info "Analyzing dependency footprint..."
    local dep_count
    dep_count=$(jq -r '.dependencies // {} | length' package.json 2>/dev/null || echo "0")
    local dev_dep_count
    dev_dep_count=$(jq -r '.devDependencies // {} | length' package.json 2>/dev/null || echo "0")
    local total_deps=$((dep_count + dev_dep_count))
    
    print_info "Dependencies: $dep_count, DevDependencies: $dev_dep_count (Total: $total_deps)"
    echo "Dependency count: $dep_count prod, $dev_dep_count dev, $total_deps total" >> "$dependency_report"
    
    # PHASE 2: AI-powered dependency strategy analysis
    print_info "Phase 2: Preparing AI-powered dependency analysis..."
    
    # Build dependency summary
    local dependency_summary
    dependency_summary="Dependency Analysis Summary:
- Production Dependencies: $dep_count
- Development Dependencies: $dev_dep_count
- Total Packages: $total_deps
- Node.js Version: $node_version
- npm Version: $npm_version
- Security Issues: $(grep -c "Security" "$dependency_report" 2>/dev/null || echo "0")
- Outdated Packages: $(grep -c "Outdated" "$dependency_report" 2>/dev/null || echo "0")"
    
    # Extract actual dependencies
    local prod_deps
    # Increased from 20 to 50 lines (Dec 15, 2025) for comprehensive dependency analysis
    prod_deps=$(jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value)"' package.json 2>/dev/null | head -50)
    local dev_deps
    dev_deps=$(jq -r '.devDependencies // {} | to_entries[] | "\(.key)@\(.value)"' package.json 2>/dev/null)
    
    local dependency_report_content
    dependency_report_content=$(cat "$dependency_report" 2>/dev/null || echo "   No critical issues detected")
    local audit_summary
    audit_summary=$(cat "$audit_output" 2>/dev/null | jq -r '.metadata // "No data"' || echo "Unable to parse audit results")
    local outdated_list
    # Increased from 10 to 20 lines (Dec 15, 2025) for better outdated package visibility
    outdated_list=$(cat "$outdated_output" 2>/dev/null | jq -r 'to_entries[] | "\(.key): \(.value.current) -> \(.value.latest) (wanted: \(.value.wanted))"' | head -20 || echo "None or unable to parse")
    
    # Build comprehensive dependency analysis prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step8_dependencies_prompt \
        "$node_version" \
        "$npm_version" \
        "$dep_count" \
        "$dev_dep_count" \
        "$total_deps" \
        "$dependency_summary" \
        "$dependency_report_content" \
        "$prod_deps" \
        "$dev_deps" \
        "$audit_summary" \
        "$outdated_list")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Dependency Analysis Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with dependency analysis prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to analyze dependencies?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step8_copilot_dependency_analysis_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "8" "Dependency_Validation" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Handle critical dependency issues
    if [[ $issues -gt 0 ]]; then
        if confirm_action "Critical dependency issues found - continue workflow?"; then
            print_warning "Continuing despite dependency issues"
        else
            print_error "Workflow paused - resolve dependency issues first"
            cd "$PROJECT_ROOT"
            return 1
        fi
    fi
    
    # Save step results using shared library
    save_step_results \
        "8" \
        "Dependency_Validation" \
        "$issues" \
        "Dependency validation passed ($total_deps packages healthy)" \
        "Found ${issues} dependency issues. Review vulnerabilities and outdated packages." \
        "$audit_output" \
        "$total_deps"
    
    cd "$PROJECT_ROOT" || return 1
    update_workflow_status "step8" "✅"
}

# Export step function
export -f step8_validate_dependencies
