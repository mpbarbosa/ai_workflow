#!/bin/bash
################################################################################
# Step 2: AI-Powered Documentation Consistency Analysis
# Purpose: Check documentation for broken references and consistency issues
# Part of: Tests & Documentation Workflow Automation v2.0.0
# Version: 2.0.0
################################################################################

# Module version information
readonly STEP2_VERSION="2.0.0"
readonly STEP2_VERSION_MAJOR=2
readonly STEP2_VERSION_MINOR=0
readonly STEP2_VERSION_PATCH=0

# Validates semantic version format (MAJOR.MINOR.PATCH)
# Arguments: $1 - version string to validate
# Returns: 0 if valid semver, 1 if invalid
validate_semver() {
    local version="$1"
    
    # Semantic versioning regex: MAJOR.MINOR.PATCH (optional v prefix)
    if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Extracts version numbers from documentation files
# Arguments: $1 - file path
# Returns: Array of version strings found
extract_versions_from_file() {
    local file="$1"
    
    # Extract version patterns: v1.2.3 or 1.2.3
    grep -oP 'v?[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | sort -u || true
}

# Checks version consistency across documentation
# Returns: 0 if consistent, 1 if inconsistencies found
check_version_consistency() {
    local inconsistencies=0
    local version_map_file
    version_map_file=$(mktemp)
    TEMP_FILES+=("$version_map_file")
    
    print_info "Checking semantic version consistency across documentation..."
    
    # Find all markdown files
    while IFS= read -r md_file; do
        local versions
        versions=$(extract_versions_from_file "$md_file")
        
        while IFS= read -r version; do
            [[ -z "$version" ]] && continue
            
            # Validate semver format
            if ! validate_semver "$version"; then
                print_warning "Invalid semantic version format in $md_file: $version"
                echo "$md_file: $version (INVALID FORMAT)" >> "$version_map_file"
                ((inconsistencies++))
            else
                echo "$md_file: $version" >> "$version_map_file"
            fi
        done <<< "$versions"
    done < <(find . -name "*.md" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null || true)
    
    # Check package.json version if exists
    if [[ -f "src/package.json" ]]; then
        local pkg_version
        pkg_version=$(grep -oP '"version":\s*"\K[^"]+' "src/package.json" 2>/dev/null || true)
        
        if [[ -n "$pkg_version" ]]; then
            if ! validate_semver "$pkg_version"; then
                print_warning "Invalid semantic version in package.json: $pkg_version"
                echo "package.json: $pkg_version (INVALID FORMAT)" >> "$version_map_file"
                ((inconsistencies++))
            else
                echo "package.json: $pkg_version" >> "$version_map_file"
            fi
        fi
    fi
    
    # Display version map
    if [[ -s "$version_map_file" ]]; then
        local total_versions
        total_versions=$(wc -l < "$version_map_file")
        print_info "Found $total_versions version reference(s)"
        
        if [[ $inconsistencies -gt 0 ]]; then
            print_warning "Version format issues detected:"
            cat "$version_map_file"
        fi
    fi
    
    return $inconsistencies
}

# Creates comprehensive consistency issue report and saves to backlog
# Arguments: 
#   $1 - issues_found count
#   $2 - broken_refs_file path
#   $3 - version_issues count
#   $4 - metrics_issues count
#   $5 - doc_count
# Returns: 0 for success
create_consistency_issue_report() {
    local issues_found="$1"
    local broken_refs_file="$2"
    local version_issues="$3"
    local metrics_issues="$4"
    local doc_count="$5"
    
    # Only create report if issues were found
    if [[ "$issues_found" -eq 0 ]]; then
        return 0
    fi
    
    local report="## Documentation Consistency Issues\n\n"
    report+="**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S')\n"
    report+="**Documentation Files Checked**: ${doc_count}\n"
    report+="**Total Issues Found**: ${issues_found}\n\n"
    
    # Add broken references section if any found
    if [[ -s "$broken_refs_file" ]]; then
        local broken_count
        broken_count=$(wc -l < "$broken_refs_file")
        report+="### Broken References (${broken_count} found)\n\n"
        
        while IFS=': ' read -r source_file broken_path; do
            [[ -z "$source_file" ]] && continue
            report+="⚠️  **BROKEN LINK**: \`${source_file}\` references missing file\n"
            report+="   - Reference: \`${broken_path}\`\n"
            report+="   - Action: Update reference or restore missing file\n\n"
        done < "$broken_refs_file"
    fi
    
    # Add version inconsistencies section if any found
    if [[ "$version_issues" -gt 0 ]]; then
        report+="### Version Inconsistencies (${version_issues} found)\n\n"
        report+="⚠️  **VERSION MISMATCH**: Files contain inconsistent version formats\n"
        report+="   - Check semantic versioning compliance (MAJOR.MINOR.PATCH)\n"
        report+="   - Action: Standardize all version numbers to valid semver format\n"
        report+="   - Review version_map output for details\n\n"
    fi
    
    # Add metrics validation section if any found
    if [[ "$metrics_issues" -gt 0 ]]; then
        report+="### Metrics Validation (${metrics_issues} found)\n\n"
        report+="⚠️  **METRICS MISMATCH**: Cross-document metrics inconsistency detected\n"
        report+="   - Action: Reconcile metrics across documentation\n"
        report+="   - Review metrics validation output for specific discrepancies\n\n"
    fi
    
    # Add recommended actions
    report+="### Recommended Actions\n\n"
    if [[ -s "$broken_refs_file" ]]; then
        report+="1. **Fix Broken References**: Update paths or restore missing files\n"
    fi
    if [[ "$version_issues" -gt 0 ]]; then
        report+="2. **Standardize Versions**: Ensure all version numbers follow semantic versioning\n"
    fi
    if [[ "$metrics_issues" -gt 0 ]]; then
        report+="3. **Validate Metrics**: Cross-check and update metrics for consistency\n"
    fi
    report+="4. **Re-run Consistency Check**: Verify all issues are resolved\n"
    
    # Automatically save report to backlog
    save_step_issues "2" "Consistency_Analysis" "$(echo -e "$report")"
    print_info "Consistency issues report saved to backlog"
    
    return 0
}

# Main step function - validates documentation consistency with AI assistance
# Returns: 0 for success, 1 for failure
step2_check_consistency() {
    print_step "2" "Check Documentation Consistency"
    
    cd "$PROJECT_ROOT" || return 1
    
    local issues_found=0
    local version_issues=0
    local metrics_issues=0
    local broken_refs_file
    broken_refs_file=$(mktemp)
    TEMP_FILES+=("$broken_refs_file")
    
    # PHASE 1: Automated broken link detection
    print_info "Phase 1: Automated broken link detection..."
    
    # Check semantic version consistency
    check_version_consistency || version_issues=$?
    if [[ $version_issues -gt 0 ]]; then
        print_warning "Found $version_issues semantic versioning issue(s)"
        ((issues_found += version_issues))
    else
        print_success "All version numbers follow semantic versioning format ✅"
    fi
    
    # Check metrics consistency across documentation
    print_info "Checking workflow metrics consistency..."
    
    # Source metrics validation library
    if [[ -f "$PROJECT_ROOT/shell_scripts/workflow/lib/metrics_validation.sh" ]]; then
        # shellcheck source=shell_scripts/workflow/lib/metrics_validation.sh
        source "$PROJECT_ROOT/shell_scripts/workflow/lib/metrics_validation.sh"
        
        # Run metrics validation
        if ! validate_all_documentation_metrics; then
            print_warning "Documentation metrics inconsistencies detected"
            metrics_issues=1
            ((issues_found++)) || true
        else
            print_success "All documentation metrics are consistent ✅"
        fi
    else
        print_warning "Metrics validation library not found - skipping metrics check"
    fi
    
    # Check docs directory for broken references
    while IFS= read -r md_file; do
        # Extract file paths using regex (paths starting with /)
        local refs
        refs=$(grep -oP '(?<=\()(/[^)]+)(?=\))' "$md_file" 2>/dev/null || true)
        
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            # Extract file paths using regex (paths starting with /)
            local full_path="${PROJECT_ROOT}${ref}"
            if [[ ! -e "$full_path" ]]; then
                print_warning "Broken reference in $md_file: $ref"
                echo "$md_file: $ref" >> "$broken_refs_file"
                ((issues_found++)) || true
            fi
        done <<< "$refs"
    done < <(fast_find "docs" "*.md" 5)
    
    # Check README.md
    if [[ -f "README.md" ]]; then
        local refs
        # Extract file paths using regex (paths starting with /)
        refs=$(grep -oP '(?<=\()(/[^)]+)(?=\))' "README.md" 2>/dev/null || true)
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            # Extract file paths using regex (paths starting with /)
            local full_path="${PROJECT_ROOT}${ref}"
            if [[ ! -e "$full_path" ]]; then
                print_warning "Broken reference in README.md: $ref"
                echo "README.md: $ref" >> "$broken_refs_file"
                ((issues_found++)) || true
            fi
        done <<< "$refs"
    fi
    
    # Check .github/copilot-instructions.md (critical for CI/CD)
    if [[ -f ".github/copilot-instructions.md" ]]; then
        local refs
        # Extract file paths using regex (paths starting with /)
        refs=$(grep -oP '(?<=\()(/[^)]+)(?=\))' ".github/copilot-instructions.md" 2>/dev/null || true)
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            # Extract file paths using regex (paths starting with /)
            local full_path="${PROJECT_ROOT}${ref}"
            if [[ ! -e "$full_path" ]]; then
                print_warning "Broken reference in .github/copilot-instructions.md: $ref"
                echo ".github/copilot-instructions.md: $ref" >> "$broken_refs_file"
                ((issues_found++)) || true
            fi
        done <<< "$refs"
    fi
    
    # Gather documentation inventory for AI analysis
    local doc_files
    doc_files=$(fast_find "." "*.md" 5 "node_modules" ".git" "coverage" | sort)
    local doc_count
    doc_count=$(echo "$doc_files" | wc -l)
    
    # Build AI prompt using helper function
    local broken_refs_content
    broken_refs_content=$(cat "$broken_refs_file" 2>/dev/null || echo "   No broken references detected")
    
    # Create comprehensive consistency prompt using AI helper function
    local copilot_prompt
    copilot_prompt=$(build_step2_consistency_prompt \
        "$doc_count" \
        "${CHANGE_SCOPE}" \
        "${ANALYSIS_MODIFIED}" \
        "$broken_refs_content" \
        "$doc_files")

    echo ""
    echo -e "${CYAN}GitHub Copilot CLI Consistency Analysis Prompt:${NC}"
    echo -e "${YELLOW}${copilot_prompt}${NC}\n"
    
    # PHASE 2: Execute AI analysis with manual issue tracking
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would invoke: copilot -p with consistency analysis prompt"
    else
        if confirm_action "Run GitHub Copilot CLI to analyze documentation consistency?" "y"; then
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
            local log_file="${LOGS_RUN_DIR}/step2_copilot_consistency_analysis_${log_timestamp}.log"
            print_info "Logging output to: $log_file"
            
            # Execute Copilot prompt
            execute_copilot_prompt "$copilot_prompt" "$log_file"
            
            print_success "GitHub Copilot CLI session completed"
            print_info "Full session log saved to: $log_file"
            
            # Extract and save issues using library function
            extract_and_save_issues_from_log "2" "Consistency_Analysis" "$log_file"
        else
            print_warning "Skipped GitHub Copilot CLI - using manual review"
        fi
    fi
    
    # Generate comprehensive consistency issue report if issues found
    if [[ "$issues_found" -gt 0 ]]; then
        print_info "Generating comprehensive consistency issue report..."
        create_consistency_issue_report "$issues_found" "$broken_refs_file" "$version_issues" "$metrics_issues" "$doc_count"
        print_warning "Found ${issues_found} consistency issue(s) - review backlog for details"
    else
        print_success "No consistency issues detected ✅"
    fi
    
    # Save step results using shared library
    save_step_results \
        "2" \
        "Consistency_Analysis" \
        "$issues_found" \
        "No consistency issues found in automated checks" \
        "Found ${issues_found} consistency issue(s) requiring attention. Review backlog report for details." \
        "$broken_refs_file" \
        "$doc_count"
    
    update_workflow_status "step2" "✅"
}

# Export step function and helper functions
export -f step2_check_consistency
export -f validate_semver
export -f extract_versions_from_file
export -f check_version_consistency
export -f create_consistency_issue_report
